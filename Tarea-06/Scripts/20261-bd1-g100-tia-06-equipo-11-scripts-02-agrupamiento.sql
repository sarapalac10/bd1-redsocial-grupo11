--
-- Scripts de Consultas con Agrupamientos y Funciones de Agregación
-- Red Social Estudiantil Pascualina
-- Tarea 6 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--

SET search_path TO pascualina2;

-- ============================================================
-- CONSULTA #1: Grupos con cantidad de miembros
-- Pregunta: ¿Cuántos miembros tiene cada grupo, quién lo creó
-- y cuándo fue creado? Ordenado alfabéticamente por nombre.
-- ============================================================
SELECT
    g.id_grupo                                          AS id_grupo,
    g.codigo_grupo                                      AS codigo_grupo,
    g.nombre                                            AS nombre_grupo,
    g.fecha_creacion                                    AS fecha_creacion,
    u.codigo_usuario                                    AS codigo_creador,
    u.nombres || ' ' || u.apellidos                     AS nombre_creador,
    COUNT(gu.id_usuario)                                AS cantidad_miembros
FROM grupo g
    INNER JOIN usuario       u  ON u.id_usuario  = g.id_usuario
    INNER JOIN grupo_usuarios gu ON gu.id_grupo  = g.id_grupo
WHERE g.activo = TRUE
  AND gu.activo = TRUE
GROUP BY
    g.id_grupo,
    g.codigo_grupo,
    g.nombre,
    g.fecha_creacion,
    u.codigo_usuario,
    u.nombres,
    u.apellidos
ORDER BY g.nombre ASC;

-- ============================================================
-- CONSULTA #2: Eventos con cantidad de usuarios registrados
-- Pregunta: ¿Cuántos usuarios se suscribieron a cada evento,
-- quién lo promovió y cuál es el tipo de evento?
-- Ordenado de mayor a menor fecha del evento.
-- ============================================================
SELECT
    et.id_evento_tipo                                   AS id_tipo_evento,
    et.nombre                                           AS tipo_evento,
    e.codigo_evento                                     AS codigo_evento,
    e.nombre                                            AS nombre_evento,
    e.descripcion                                       AS descripcion_evento,
    e.fecha_evento                                      AS fecha_evento,
    u.codigo_usuario                                    AS codigo_promotor,
    u.nombres || ' ' || u.apellidos                     AS nombre_promotor,
    COUNT(eu.id_usuario)                                AS cantidad_suscritos,
    SUM(CASE WHEN eu.asistio = TRUE THEN 1 ELSE 0 END)  AS cantidad_asistentes
FROM evento e
    INNER JOIN evento_tipo     et ON et.id_evento_tipo  = e.id_evento_tipo
    INNER JOIN usuario         u  ON u.id_usuario       = e.id_usuario
    INNER JOIN evento_usuarios eu ON eu.id_evento       = e.id_evento
WHERE e.activo = TRUE
GROUP BY
    et.id_evento_tipo,
    et.nombre,
    e.codigo_evento,
    e.nombre,
    e.descripcion,
    e.fecha_evento,
    u.codigo_usuario,
    u.nombres,
    u.apellidos
ORDER BY e.fecha_evento DESC;

-- ============================================================
-- CONSULTA #3: Tipos de servicio con cantidad de consumidores
-- Pregunta: ¿Cuáles tipos de servicio son más demandados
-- en los últimos 3 meses?
-- Ordenado de mayor a menor por cantidad de usuarios.
-- ============================================================
SELECT
    st.id_servicio_tipo                                 AS id_tipo_servicio,
    st.nombre                                           AS tipo_servicio,
    COUNT(DISTINCT su.id_usuario)                       AS cantidad_consumidores_unicos,
    COUNT(su.id_servicio_usuario)                       AS total_consumos,
    ROUND(AVG(su.calificacion), 2)                      AS calificacion_promedio
FROM servicio_usuarios su
    INNER JOIN servicio      s  ON s.id_servicio        = su.id_servicio
    INNER JOIN servicio_tipo st ON st.id_servicio_tipo  = s.id_servicio_tipo
WHERE su.fecha_consumo >= NOW() - INTERVAL '3 months'
GROUP BY
    st.id_servicio_tipo,
    st.nombre
ORDER BY cantidad_consumidores_unicos DESC;

-- ============================================================
-- CONSULTA #4: Top 20 productos con mayor monto de venta (último mes)
-- Pregunta: ¿Cuáles son los 20 productos con mayor monto
-- de ventas en el último mes?
-- Ordenado por monto vendido de mayor a menor.
-- ============================================================
SELECT
    pt.nombre                                           AS tipo_producto,
    p.codigo_producto                                   AS codigo_producto,
    p.nombre                                            AS nombre_producto,
    u.codigo_usuario                                    AS codigo_vendedor,
    u.nombres || ' ' || u.apellidos                     AS nombre_vendedor,
    COUNT(pu.id_producto_usuario)                       AS cantidad_ventas,
    SUM(pu.precio_venta)                                AS monto_total_vendido,
    ROUND(AVG(pu.precio_venta), 2)                      AS precio_promedio_venta
FROM producto_usuarios pu
    INNER JOIN producto      p  ON p.id_producto        = pu.id_producto
    INNER JOIN producto_tipo pt ON pt.id_producto_tipo  = p.id_producto_tipo
    INNER JOIN usuario       u  ON u.id_usuario         = p.id_usuario
WHERE pu.fecha_compra >= NOW() - INTERVAL '1 month'
GROUP BY
    pt.nombre,
    p.codigo_producto,
    p.nombre,
    u.codigo_usuario,
    u.nombres,
    u.apellidos
ORDER BY monto_total_vendido DESC
LIMIT 20;

-- ============================================================
-- CONSULTA #5: Tipos de producto con totales de venta (todos)
-- Pregunta: ¿Cuál es el desempeño de ventas por tipo de
-- producto considerando todos los registros?
-- Ordenado por monto total de venta de mayor a menor.
-- ============================================================
SELECT
    pt.nombre                                           AS tipo_producto,
    COUNT(DISTINCT p.id_usuario)                        AS total_vendedores,
    COUNT(DISTINCT pu.id_usuario)                       AS total_compradores,
    COUNT(pu.id_producto_usuario)                       AS total_transacciones,
    SUM(pu.precio_venta)                                AS monto_total_ventas,
    ROUND(AVG(pu.precio_venta), 2)                      AS promedio_venta,
    MAX(pu.precio_venta)                                AS venta_maxima,
    MIN(pu.precio_venta)                                AS venta_minima
FROM producto_usuarios pu
    INNER JOIN producto      p  ON p.id_producto        = pu.id_producto
    INNER JOIN producto_tipo pt ON pt.id_producto_tipo  = p.id_producto_tipo
GROUP BY
    pt.nombre
ORDER BY monto_total_ventas DESC;

-- ============================================================
-- CONSULTA #6: LIBRE — Usuarios más activos en la Red Social
-- Pregunta: ¿Cuáles son los usuarios miembros más activos
-- considerando publicaciones, eventos creados y servicios
-- ofrecidos? Incluye solo usuarios con actividad en al menos
-- 2 de las 3 dimensiones.
-- Tablas: usuario, publicacion, evento, servicio
-- ============================================================
SELECT
    u.codigo_usuario                                    AS codigo_usuario,
    u.nombres || ' ' || u.apellidos                     AS nombre_usuario,
    tu.nombre_tipo_usuario                              AS tipo_usuario,
    COUNT(DISTINCT pub.id_publicacion)                  AS total_publicaciones,
    COUNT(DISTINCT e.id_evento)                         AS total_eventos_creados,
    COUNT(DISTINCT s.id_servicio)                       AS total_servicios_ofrecidos,
    COUNT(DISTINCT pub.id_publicacion)
        + COUNT(DISTINCT e.id_evento)
        + COUNT(DISTINCT s.id_servicio)                 AS indice_actividad_total
FROM usuario u
    INNER JOIN tipo_usuario  tu  ON tu.id_tipo_usuario  = u.id_tipo_usuario
    LEFT  JOIN publicacion   pub ON pub.id_usuario      = u.id_usuario AND pub.activo = TRUE
    LEFT  JOIN evento        e   ON e.id_usuario        = u.id_usuario AND e.activo   = TRUE
    LEFT  JOIN servicio      s   ON s.id_usuario        = u.id_usuario AND s.activo   = TRUE
WHERE u.activo = TRUE
GROUP BY
    u.codigo_usuario,
    u.nombres,
    u.apellidos,
    tu.nombre_tipo_usuario
HAVING
    (COUNT(DISTINCT pub.id_publicacion) > 0)::INT
    + (COUNT(DISTINCT e.id_evento) > 0)::INT
    + (COUNT(DISTINCT s.id_servicio) > 0)::INT >= 2
ORDER BY indice_actividad_total DESC
LIMIT 30;
