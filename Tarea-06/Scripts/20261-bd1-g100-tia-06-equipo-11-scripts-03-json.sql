--
-- Scripts de Manipulación de dato (campo) JSON
-- Tabla: "perfil" de la Base de Datos - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 6 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
--
-- Campo nuevo: "actividad_academica" (JSON)
-- Propósito: almacena el historial académico del usuario —
-- materias cursadas, notas, semestre activo y logros.
-- Es diferente al campo "informacion_perfil" (JSONB) de la Tarea 5.
--

SET search_path TO pascualina2;

-- ============================================================
-- ALTER TABLE: agregar campo JSON a la tabla perfil
-- ============================================================
ALTER TABLE perfil
    ADD COLUMN IF NOT EXISTS actividad_academica JSON NULL;

-- Verificación
SELECT column_name, data_type
FROM   information_schema.columns
WHERE  table_schema = 'pascualina2'
  AND  table_name   = 'perfil'
  AND  column_name  = 'actividad_academica';

-- ============================================================
-- 1. INSERCIÓN del dato semiestructurado en campo JSON
-- ============================================================

-- Insertar actividad académica para los primeros 5 usuarios
UPDATE perfil
SET actividad_academica = '{
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
}'::JSON
WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo_usuario = 'USR0021');

UPDATE perfil
SET actividad_academica = '{
    "semestre_activo": 5,
    "promedio_acumulado": 3.9,
    "materias_cursadas": [
        {"codigo": "BD101", "nombre": "Bases de Datos I",  "nota": 4.2, "estado": "aprobada"},
        {"codigo": "SO401", "nombre": "Sistemas Operativos","nota": 3.6, "estado": "aprobada"},
        {"codigo": "CA501", "nombre": "Cálculo Avanzado",  "nota": 3.5, "estado": "aprobada"}
    ],
    "logros": ["Ganador Hackaton 2025"],
    "modalidad": "virtual",
    "fecha_ultimo_registro": "2026-05-01"
}'::JSON
WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo_usuario = 'USR0020');

-- Insertar datos básicos para los demás usuarios (muestra de 50)
UPDATE perfil
SET actividad_academica = json_build_object(
    'semestre_activo',     (id_usuario % 10) + 1,
    'promedio_acumulado',  ROUND((3.0 + (id_usuario % 20) * 0.1)::NUMERIC, 1),
    'materias_cursadas',   json_build_array(
        json_build_object('codigo', 'BD101', 'nombre', 'Bases de Datos I',
                          'nota', ROUND((3.5 + (id_usuario % 15) * 0.1)::NUMERIC, 1),
                          'estado', 'aprobada')
    ),
    'logros',              json_build_array(),
    'modalidad',           CASE WHEN id_usuario % 2 = 0 THEN 'presencial' ELSE 'virtual' END,
    'fecha_ultimo_registro', '2026-05-01'
)
WHERE id_usuario BETWEEN 31 AND 80
  AND actividad_academica IS NULL;

-- ============================================================
-- 2. CONSULTA de los datos del campo JSON
-- ============================================================

-- Consulta 1: Ver actividad académica completa
SELECT
    p.id_perfil,
    u.codigo_usuario,
    u.nombres || ' ' || u.apellidos         AS nombre_usuario,
    p.actividad_academica
FROM perfil p
    INNER JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE p.actividad_academica IS NOT NULL
ORDER BY p.id_perfil
LIMIT 10;

-- Consulta 2: Extraer campos específicos del JSON
SELECT
    u.codigo_usuario,
    u.nombres || ' ' || u.apellidos                             AS nombre_usuario,
    (p.actividad_academica->>'semestre_activo')::INT            AS semestre_activo,
    (p.actividad_academica->>'promedio_acumulado')::NUMERIC     AS promedio_acumulado,
    p.actividad_academica->>'modalidad'                         AS modalidad,
    p.actividad_academica->>'fecha_ultimo_registro'             AS fecha_registro
FROM perfil p
    INNER JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE p.actividad_academica IS NOT NULL
ORDER BY (p.actividad_academica->>'promedio_acumulado')::NUMERIC DESC
LIMIT 10;

-- Consulta 3: Usuarios por modalidad de estudio
SELECT
    p.actividad_academica->>'modalidad'     AS modalidad,
    COUNT(*)                                AS total_usuarios
FROM perfil p
WHERE p.actividad_academica IS NOT NULL
GROUP BY p.actividad_academica->>'modalidad'
ORDER BY total_usuarios DESC;

-- ============================================================
-- 3. MODIFICACIÓN de un dato dentro del campo JSON
-- ============================================================
-- Nota: JSON en PostgreSQL no permite modificación parcial directa.
-- Se debe reemplazar el campo completo con el valor actualizado.
-- Esta es una de las limitaciones de JSON vs JSONB.

UPDATE perfil
SET actividad_academica = json_build_object(
    'semestre_activo',      7,
    'promedio_acumulado',   4.3,
    'materias_cursadas',    actividad_academica->'materias_cursadas',
    'logros',               json_build_array('Mejor promedio', 'Monitor de BD', 'Liderazgo'),
    'modalidad',            'presencial',
    'fecha_ultimo_registro', '2026-05-20'
)
WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo_usuario = 'USR0021');

-- Verificación
SELECT
    u.codigo_usuario,
    p.actividad_academica->>'semestre_activo'       AS semestre,
    p.actividad_academica->>'promedio_acumulado'    AS promedio,
    p.actividad_academica->>'fecha_ultimo_registro' AS ultima_actualizacion
FROM perfil p
    INNER JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE u.codigo_usuario = 'USR0021';

-- ============================================================
-- 4. ELIMINACIÓN de un dato dentro del campo JSON
-- ============================================================
-- Para eliminar un campo específico del JSON se reemplaza
-- el objeto sin ese campo usando json_build_object.

UPDATE perfil
SET actividad_academica = (
    SELECT json_build_object(
        'semestre_activo',      actividad_academica->>'semestre_activo',
        'promedio_acumulado',   actividad_academica->>'promedio_acumulado',
        'materias_cursadas',    actividad_academica->'materias_cursadas',
        'modalidad',            actividad_academica->>'modalidad'
        -- Se omite 'logros' y 'fecha_ultimo_registro' para eliminarlos
    )
    FROM perfil
    WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo_usuario = 'USR0021')
)
WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo_usuario = 'USR0021');

-- Verificación: el campo 'logros' y 'fecha_ultimo_registro' ya no aparecen
SELECT
    u.codigo_usuario,
    p.actividad_academica
FROM perfil p
    INNER JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE u.codigo_usuario = 'USR0021';
