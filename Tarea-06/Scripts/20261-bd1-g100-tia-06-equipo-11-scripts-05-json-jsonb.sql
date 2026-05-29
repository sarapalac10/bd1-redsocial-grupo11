--
-- Scripts de Comparación de Rendimiento: JSON vs JSONB
-- Red Social Estudiantil Pascualina
-- Tarea 6 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--
-- Se usan los campos actividad_academica (JSON) y
-- actividad_academica_b (JSONB) ya creados en la tabla perfil.
-- Se realizan 500 operaciones de escritura y lectura en cada campo
-- con EXPLAIN ANALYZE para medir tiempos.
--

SET search_path TO pascualina2;

-- ============================================================
-- DATO SEMIESTRUCTURADO USADO EN AMBAS PRUEBAS
-- (misma estructura para comparación justa)
-- ============================================================
-- {
--   "semestre_activo": N,
--   "promedio_acumulado": X.X,
--   "materias_cursadas": [{"codigo":"BD101","nota":4.5}],
--   "logros": ["Monitor"],
--   "modalidad": "presencial",
--   "fecha_ultimo_registro": "2026-05-01"
-- }

-- ============================================================
-- PRUEBA 1: ESCRITURA en campo JSON (500 registros)
-- ============================================================

EXPLAIN ANALYZE
UPDATE perfil
SET actividad_academica = json_build_object(
    'semestre_activo',      (id_usuario % 10) + 1,
    'promedio_acumulado',   ROUND((3.0 + (id_usuario % 20) * 0.1)::NUMERIC, 1),
    'materias_cursadas',    json_build_array(
        json_build_object('codigo','BD101','nombre','Bases de Datos I',
                          'nota', ROUND((3.5 + (id_usuario % 15) * 0.1)::NUMERIC,1),
                          'estado','aprobada')
    ),
    'logros',               json_build_array('Monitor'),
    'modalidad',            CASE WHEN id_usuario % 2 = 0 THEN 'presencial' ELSE 'virtual' END,
    'fecha_ultimo_registro','2026-05-01'
)
WHERE id_usuario IN (SELECT id_usuario FROM usuario LIMIT 500);

-- ============================================================
-- PRUEBA 2: LECTURA en campo JSON (500 registros)
-- ============================================================

EXPLAIN ANALYZE
SELECT
    p.id_perfil,
    p.actividad_academica->>'semestre_activo'       AS semestre,
    p.actividad_academica->>'promedio_acumulado'    AS promedio,
    p.actividad_academica->>'modalidad'             AS modalidad
FROM perfil p
WHERE p.actividad_academica IS NOT NULL
LIMIT 500;

-- ============================================================
-- PRUEBA 3: ESCRITURA en campo JSONB (500 registros)
-- ============================================================

EXPLAIN ANALYZE
UPDATE perfil
SET actividad_academica_b = jsonb_build_object(
    'semestre_activo',      (id_usuario % 10) + 1,
    'promedio_acumulado',   ROUND((3.0 + (id_usuario % 20) * 0.1)::NUMERIC, 1),
    'materias_cursadas',    jsonb_build_array(
        jsonb_build_object('codigo','BD101','nombre','Bases de Datos I',
                           'nota', ROUND((3.5 + (id_usuario % 15) * 0.1)::NUMERIC,1),
                           'estado','aprobada')
    ),
    'logros',               jsonb_build_array('Monitor'),
    'modalidad',            CASE WHEN id_usuario % 2 = 0 THEN 'presencial' ELSE 'virtual' END,
    'fecha_ultimo_registro','2026-05-01'
)
WHERE id_usuario IN (SELECT id_usuario FROM usuario LIMIT 500);

-- ============================================================
-- PRUEBA 4: LECTURA en campo JSONB (500 registros)
-- ============================================================

EXPLAIN ANALYZE
SELECT
    p.id_perfil,
    p.actividad_academica_b->>'semestre_activo'     AS semestre,
    p.actividad_academica_b->>'promedio_acumulado'  AS promedio,
    p.actividad_academica_b->>'modalidad'           AS modalidad
FROM perfil p
WHERE p.actividad_academica_b IS NOT NULL
LIMIT 500;

-- ============================================================
-- PRUEBA 5: LECTURA JSONB con índice GIN (operador @>)
-- Esta consulta NO es posible con JSON — exclusiva de JSONB
-- ============================================================

EXPLAIN ANALYZE
SELECT
    p.id_perfil,
    p.actividad_academica_b->>'modalidad'   AS modalidad
FROM perfil p
WHERE p.actividad_academica_b @> '{"modalidad": "presencial"}'::JSONB;

-- ============================================================
-- TABLA DE RESULTADOS — completar con los valores del EXPLAIN ANALYZE
-- ============================================================
-- Registro los tiempos en el informe:
--
-- | Dato            | Tipo  | Operación | Preparación (ms) | Ejecución (ms) |
-- |-----------------|-------|-----------|-----------------|----------------|
-- | actividad_acad. | JSON  | Escritura | ___             | ___            |
-- | actividad_acad. | JSON  | Lectura   | ___             | ___            |
-- | actividad_acad. | JSONB | Escritura | ___             | ___            |
-- | actividad_acad. | JSONB | Lectura   | ___             | ___            |
-- | actividad_acad. | JSONB | Lectura@> | ___             | ___            |
--
-- DIFERENCIAS ESPERADAS:
-- Escritura: JSONB es más lento que JSON porque PostgreSQL
--   descompone y valida el binario al insertar.
-- Lectura simple: JSONB es ligeramente más rápido porque
--   ya está en formato binario, no requiere parsing.
-- Lectura con @>: JSONB con índice GIN es significativamente
--   más rápido — usa el índice directamente. JSON no soporta @>.
