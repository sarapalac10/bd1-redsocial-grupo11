--
-- Script de Consulta con Parámetros a partir de una Vista (VIEW)
-- Red Social Estudiantil Pascualina
-- Tarea 6 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--

SET search_path TO pascualina2;

-- ============================================================
-- PLANTEAMIENTO:
-- El Consejo de la Red necesita monitorear la actividad de
-- consumo de servicios por tipo, identificando cuáles tipos
-- de servicio tienen mayor demanda y cuántos usuarios únicos
-- los consumen, filtrando por tipo de servicio específico
-- y por un mínimo de consumidores (umbral de popularidad).
-- ============================================================

-- ============================================================
-- PASO 1: CREAR LA VISTA (sin WHERE, GROUP BY ni ORDER BY)
-- La vista consolida servicio_usuarios + servicio + servicio_tipo + usuario vendedor
-- para que sea reutilizable en múltiples consultas paramétricas.
-- ============================================================

CREATE OR REPLACE VIEW vw_consumo_servicios AS
SELECT
    st.id_servicio_tipo                                     AS id_tipo_servicio,
    st.nombre                                               AS tipo_servicio,
    s.id_servicio                                           AS id_servicio,
    s.codigo_servicio                                       AS codigo_servicio,
    s.nombre                                                AS nombre_servicio,
    s.precio                                                AS precio_servicio,
    u_vendedor.codigo_usuario                               AS codigo_vendedor,
    u_vendedor.nombres || ' ' || u_vendedor.apellidos       AS nombre_vendedor,
    su.id_usuario                                           AS id_consumidor,
    su.fecha_consumo                                        AS fecha_consumo,
    su.calificacion                                         AS calificacion
FROM servicio_usuarios su
    INNER JOIN servicio      s          ON s.id_servicio         = su.id_servicio
    INNER JOIN servicio_tipo st         ON st.id_servicio_tipo   = s.id_servicio_tipo
    INNER JOIN usuario       u_vendedor ON u_vendedor.id_usuario = s.id_usuario;

-- Verificación de la vista
SELECT column_name, data_type
FROM   information_schema.columns
WHERE  table_schema = 'pascualina2'
  AND  table_name   = 'vw_consumo_servicios'
ORDER BY ordinal_position;

-- ============================================================
-- PASO 2: PREPARAR LA CONSULTA CON PARÁMETROS
--
-- Parámetro $1 (WHERE):  nombre del tipo de servicio a filtrar
-- Parámetro $2 (HAVING): cantidad mínima de consumidores únicos
--
-- La consulta usa GROUP BY para agrupar por tipo de servicio
-- y función de agregación COUNT() para contar consumidores.
-- ============================================================

PREPARE consulta_consumo_servicios (TEXT, BIGINT) AS
SELECT
    vcs.tipo_servicio                   AS tipo_servicio,
    vcs.nombre_servicio                 AS nombre_servicio,
    vcs.nombre_vendedor                 AS vendedor,
    COUNT(DISTINCT vcs.id_consumidor)   AS total_consumidores_unicos,
    COUNT(*)                            AS total_consumos,
    ROUND(AVG(vcs.calificacion), 2)     AS calificacion_promedio,
    MIN(vcs.precio_servicio)            AS precio_minimo,
    MAX(vcs.precio_servicio)            AS precio_maximo
FROM vw_consumo_servicios vcs
WHERE vcs.tipo_servicio ILIKE '%' || $1 || '%'
GROUP BY
    vcs.tipo_servicio,
    vcs.nombre_servicio,
    vcs.nombre_vendedor
HAVING COUNT(DISTINCT vcs.id_consumidor) >= $2
ORDER BY total_consumidores_unicos DESC, vcs.tipo_servicio ASC;

-- ============================================================
-- PASO 3: EJECUTAR 3 CONSULTAS CON PARÁMETROS DIFERENTES
-- ============================================================

-- EXECUTE 1: Servicios de tipo 'Asesoría' con mínimo 1 consumidor único
EXECUTE consulta_consumo_servicios('Asesoría', 1);

-- EXECUTE 2: Servicios de tipo 'Reparación' con mínimo 1 consumidor único
EXECUTE consulta_consumo_servicios('Reparación', 1);

-- EXECUTE 3: Todos los tipos de servicio con mínimo 2 consumidores únicos
EXECUTE consulta_consumo_servicios('', 2);

-- ============================================================
-- PASO 4: IMPORTANCIA DE LAS CONSULTAS PARAMETRIZADAS
-- ============================================================
-- Las consultas con PREPARE/EXECUTE tienen las siguientes ventajas:
--
-- 1. RENDIMIENTO: PostgreSQL compila y optimiza el plan de
--    ejecución una sola vez (PREPARE), y lo reutiliza en cada
--    EXECUTE sin necesidad de replanificación. En entornos con
--    cientos de usuarios concurrentes esto reduce significativamente
--    la carga del motor.
--
-- 2. REUTILIZACIÓN: La misma consulta sirve para múltiples
--    escenarios simplemente cambiando los parámetros, evitando
--    duplicación de código SQL.
--
-- 3. SEGURIDAD: Al separar la estructura SQL de los valores
--    de entrada, se previenen ataques de inyección SQL (SQL Injection),
--    ya que los parámetros se tratan como datos literales, no como
--    fragmentos de código.
--
-- 4. MANTENIBILIDAD: Si la lógica de la consulta cambia, se
--    modifica en un solo lugar (la vista + el PREPARE), no en
--    múltiples lugares del código de aplicación.
--
-- En el contexto de la Red Social Pascualina, este patrón
-- permite que el equipo analítico filtre por cualquier tipo
-- de servicio y umbral de popularidad sin escribir SQL nuevo.
