--
-- Scripts de Manipulación de dato (campo) JSONB
-- Tabla: "perfil" de la Base de Datos - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 6 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
--
-- Campo nuevo: "actividad_academica_b" (JSONB)
-- Estructura IDÉNTICA al campo JSON del ítem anterior.
-- Nombre diferente para poder comparar el rendimiento.
--

SET search_path TO pascualina2;

-- ============================================================
-- ALTER TABLE: agregar campo JSONB a la tabla perfil
-- ============================================================
ALTER TABLE perfil
    ADD COLUMN IF NOT EXISTS actividad_academica_b JSONB NULL;

-- Índice GIN para optimizar consultas sobre JSONB
CREATE INDEX IF NOT EXISTS idx_perfil_actividad_b_gin
    ON perfil USING GIN (actividad_academica_b);

-- Verificación
SELECT column_name, data_type
FROM   information_schema.columns
WHERE  table_schema = 'pascualina2'
  AND  table_name   = 'perfil'
  AND  column_name  = 'actividad_academica_b';

-- ============================================================
-- 1. INSERCIÓN del dato semiestructurado en campo JSONB
-- (misma estructura que el campo JSON del ítem anterior)
-- ============================================================

UPDATE perfil
SET actividad_academica_b = '{
    "semestre_activo": 6,
    "promedio_acumulado": 4.2,
    "materias_cursadas": [
        {"codigo": "BD101", "nombre": "Bases de Datos I",      "nota": 4.5, "estado": "aprobada"},
        {"codigo": "PG201", "nombre": "Programación II",       "nota": 3.8, "estado": "aprobada"},
        {"codigo": "RE301", "nombre": "Redes y Comunicaciones","nota": 4.1, "estado": "aprobada"}
    ],
    "logros": ["Mejor promedio del semestre", "Monitor de BD"],
    "modalidad": "presencial",
    "fecha_ultimo_registro": "2026-05-01"
}'::JSONB
WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo_usuario = 'USR0021');

UPDATE perfil
SET actividad_academica_b = '{
    "semestre_activo": 5,
    "promedio_acumulado": 3.9,
    "materias_cursadas": [
        {"codigo": "BD101", "nombre": "Bases de Datos I",   "nota": 4.2, "estado": "aprobada"},
        {"codigo": "SO401", "nombre": "Sistemas Operativos","nota": 3.6, "estado": "aprobada"},
        {"codigo": "CA501", "nombre": "Cálculo Avanzado",   "nota": 3.5, "estado": "aprobada"}
    ],
    "logros": ["Ganador Hackaton 2025"],
    "modalidad": "virtual",
    "fecha_ultimo_registro": "2026-05-01"
}'::JSONB
WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo_usuario = 'USR0020');

-- Insertar datos para rango de usuarios
UPDATE perfil
SET actividad_academica_b = jsonb_build_object(
    'semestre_activo',     (id_usuario % 10) + 1,
    'promedio_acumulado',  ROUND((3.0 + (id_usuario % 20) * 0.1)::NUMERIC, 1),
    'materias_cursadas',   jsonb_build_array(
        jsonb_build_object('codigo', 'BD101', 'nombre', 'Bases de Datos I',
                           'nota', ROUND((3.5 + (id_usuario % 15) * 0.1)::NUMERIC, 1),
                           'estado', 'aprobada')
    ),
    'logros',              jsonb_build_array(),
    'modalidad',           CASE WHEN id_usuario % 2 = 0 THEN 'presencial' ELSE 'virtual' END,
    'fecha_ultimo_registro', '2026-05-01'
)
WHERE id_usuario BETWEEN 31 AND 80
  AND actividad_academica_b IS NULL;

-- ============================================================
-- 2. CONSULTA de los datos del campo JSONB
-- ============================================================

-- Consulta 1: Ver actividad académica JSONB completa
SELECT
    p.id_perfil,
    u.codigo_usuario,
    u.nombres || ' ' || u.apellidos         AS nombre_usuario,
    p.actividad_academica_b
FROM perfil p
    INNER JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE p.actividad_academica_b IS NOT NULL
ORDER BY p.id_perfil
LIMIT 10;

-- Consulta 2: Extraer campos específicos del JSONB
-- A diferencia del JSON, JSONB permite búsquedas con índice GIN
SELECT
    u.codigo_usuario,
    u.nombres || ' ' || u.apellidos                                 AS nombre_usuario,
    (p.actividad_academica_b->>'semestre_activo')::INT              AS semestre_activo,
    (p.actividad_academica_b->>'promedio_acumulado')::NUMERIC       AS promedio_acumulado,
    p.actividad_academica_b->>'modalidad'                           AS modalidad
FROM perfil p
    INNER JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE p.actividad_academica_b IS NOT NULL
ORDER BY (p.actividad_academica_b->>'promedio_acumulado')::NUMERIC DESC
LIMIT 10;

-- Consulta 3: Búsqueda con operador @> (contiene) — exclusivo de JSONB
-- Buscar usuarios con modalidad presencial — esto usa el índice GIN
SELECT
    u.codigo_usuario,
    u.nombres || ' ' || u.apellidos         AS nombre_usuario,
    p.actividad_academica_b->>'modalidad'   AS modalidad,
    p.actividad_academica_b->>'semestre_activo' AS semestre
FROM perfil p
    INNER JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE p.actividad_academica_b @> '{"modalidad": "presencial"}'::JSONB;

-- ============================================================
-- 3. MODIFICACIÓN de un dato dentro del campo JSONB
-- ============================================================
-- JSONB permite modificación parcial con el operador ||
-- (merge) o con jsonb_set() — ventaja clave sobre JSON.

-- Opción A: jsonb_set() para modificar un campo específico
UPDATE perfil
SET actividad_academica_b = jsonb_set(
    actividad_academica_b,
    '{semestre_activo}',
    '7'::JSONB
)
WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo_usuario = 'USR0021');

-- Opción B: operador || para agregar/actualizar múltiples campos
UPDATE perfil
SET actividad_academica_b = actividad_academica_b || '{
    "fecha_ultimo_registro": "2026-05-20",
    "promedio_acumulado": 4.3
}'::JSONB
WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo_usuario = 'USR0021');

-- Verificación
SELECT
    u.codigo_usuario,
    p.actividad_academica_b->>'semestre_activo'         AS semestre,
    p.actividad_academica_b->>'promedio_acumulado'      AS promedio,
    p.actividad_academica_b->>'fecha_ultimo_registro'   AS ultima_actualizacion
FROM perfil p
    INNER JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE u.codigo_usuario = 'USR0021';

-- ============================================================
-- 4. ELIMINACIÓN de un dato dentro del campo JSONB
-- ============================================================
-- JSONB permite eliminar una clave con el operador - (menos)
-- Ventaja importante sobre JSON que requiere reescribir todo.

UPDATE perfil
SET actividad_academica_b = actividad_academica_b - 'logros' - 'fecha_ultimo_registro'
WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo_usuario = 'USR0021');

-- Verificación: las claves 'logros' y 'fecha_ultimo_registro' ya no existen
SELECT
    u.codigo_usuario,
    p.actividad_academica_b
FROM perfil p
    INNER JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE u.codigo_usuario = 'USR0021';
