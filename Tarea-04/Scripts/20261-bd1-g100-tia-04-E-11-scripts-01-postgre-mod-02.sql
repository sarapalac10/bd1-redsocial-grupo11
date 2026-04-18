--
-- Scripts de Modificación de la Base de Datos - SGBD PostgreSQL
-- Datos Semi-estructurados (NoSQL / Big Data / IoT)
-- Red Social Estudiantil Pascualina
-- Tarea 4 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--
-- Todas las instrucciones se deben realizar en secuencia sin errores
--

SET search_path TO pascualina;

-- ============================================================
-- 1. DATOS SEMI-ESTRUCTURADOS: perfil_extendido en usuario
--
-- Propósito:
--   La tabla 'usuario' almacena datos estructurados fijos,
--   pero cada tipo de usuario (estudiante, docente, egresado,
--   público general) puede tener atributos de perfil altamente
--   variables: links a portfolios, certificaciones, redes sociales,
--   idiomas, disponibilidad horaria, preferencias de contacto, etc.
--   Usar JSONB permite almacenar esta información sin alterar el
--   esquema relacional cada vez que se agrega un nuevo atributo.
--
-- Caso de uso Big Data / IoT:
--   En un contexto de Big Data, este campo puede alimentar motores
--   de recomendación (matching de mentores con estudiantes) y
--   análisis de perfiles a escala sin necesidad de JOINs costosos.
--   Los datos no estructurados del perfil se pueden indexar con
--   operadores GIN de PostgreSQL para búsquedas eficientes.
-- ============================================================

-- 1.1 Agregar el campo JSONB

ALTER TABLE usuario
    ADD COLUMN IF NOT EXISTS perfil_extendido JSONB NULL;

-- 1.2 Agregar índice GIN para consultas eficientes sobre el JSON

CREATE INDEX IF NOT EXISTS idx_usuario_perfil_gin
    ON usuario USING GIN (perfil_extendido);

-- 1.3 Insertar registros de ejemplo
--     Primero insertamos usuarios base, luego actualizamos el JSONB.

INSERT INTO usuario (nombre, apellido, email, hash_contrasena, estado)
VALUES
    ('Sara',   'Palacio',   'sara.palacio@pascualina.edu.co',   'hash_abc123', 'activo'),
    ('Julian', 'Velasquez', 'julian.velasquez@pascualina.edu.co','hash_xyz789', 'activo');

UPDATE usuario
SET perfil_extendido = '{
    "redes_sociales": {
        "linkedin": "linkedin.com/in/sara-palacio",
        "github":   "github.com/sarapalacio"
    },
    "idiomas":        ["Español", "Inglés B2"],
    "certificaciones": ["AWS Cloud Practitioner", "Scrum Foundation"],
    "disponibilidad": "tardes",
    "intereses_mentoria": ["Bases de datos", "Analítica de datos"]
}'::JSONB
WHERE email = 'sara.palacio@pascualina.edu.co';

UPDATE usuario
SET perfil_extendido = '{
    "redes_sociales": {
        "linkedin": "linkedin.com/in/julian-velasquez",
        "github":   "github.com/juliandev"
    },
    "idiomas":        ["Español", "Inglés B1", "Portugués A2"],
    "certificaciones": ["Google Data Analytics"],
    "disponibilidad": "mañanas y tardes",
    "intereses_mentoria": ["SQL", "Desarrollo backend"]
}'::JSONB
WHERE email = 'julian.velasquez@pascualina.edu.co';

-- 1.4 Consultas sobre el campo JSONB

-- Consulta 1: Ver perfil extendido completo de todos los usuarios
SELECT
    id_usuario,
    nombre,
    apellido,
    perfil_extendido
FROM usuario
WHERE perfil_extendido IS NOT NULL;

-- Consulta 2: Filtrar usuarios con LinkedIn registrado
SELECT
    nombre,
    apellido,
    perfil_extendido -> 'redes_sociales' ->> 'linkedin' AS linkedin
FROM usuario
WHERE perfil_extendido ? 'redes_sociales'
  AND perfil_extendido -> 'redes_sociales' ? 'linkedin';

-- Consulta 3: Buscar usuarios con disponibilidad en "tardes"
SELECT
    nombre,
    apellido,
    perfil_extendido ->> 'disponibilidad' AS disponibilidad
FROM usuario
WHERE perfil_extendido ->> 'disponibilidad' ILIKE '%tardes%';

-- Consulta 4: Usuarios interesados en mentoría de "Bases de datos"
SELECT
    nombre,
    apellido,
    perfil_extendido -> 'intereses_mentoria' AS intereses
FROM usuario
WHERE perfil_extendido -> 'intereses_mentoria' ? 'Bases de datos';


-- ============================================================
-- 2. DATOS SEMI-ESTRUCTURADOS: metricas_evento en evento
--
-- Propósito:
--   Los eventos en Pascualina generan datos de comportamiento
--   en tiempo real: check-ins por ubicación, encuestas de
--   satisfacción, interacciones en vivo (preguntas del chat,
--   reacciones), estadísticas de transmisión (viewers, duración
--   de visualización), datos de sensores IoT en eventos presenciales
--   (aforo, temperatura del auditorio, nivel de ruido).
--   Modelar estos datos en columnas relacionales fijas es impracticable
--   porque varían por tipo de evento y evolucionan con el tiempo.
--   JSONB permite capturar toda esta heterogeneidad en un solo campo.
--
-- Caso de uso Big Data / IoT:
--   En eventos presenciales con sensores IoT (pulseras NFC, beacons
--   Bluetooth, cámaras de aforo), cada dispositivo puede enviar
--   lecturas periódicas que se acumulan en este campo.
--   Herramientas de streaming como Apache Kafka pueden alimentar
--   este campo en tiempo real. El índice GIN permite consultas
--   analíticas sobre millones de registros de eventos sin mover
--   los datos a un almacén externo.
-- ============================================================

-- 2.1 Agregar el campo JSONB a la tabla evento

ALTER TABLE evento
    ADD COLUMN IF NOT EXISTS metricas_evento JSONB NULL;

-- 2.2 Agregar índice GIN

CREATE INDEX IF NOT EXISTS idx_evento_metricas_gin
    ON evento USING GIN (metricas_evento);

-- 2.3 Insertar eventos de ejemplo y agregar métricas

INSERT INTO usuario (nombre, apellido, email, hash_contrasena, estado)
VALUES ('Admin', 'Pascualina', 'admin@pascualina.edu.co', 'hash_admin01', 'activo');

INSERT INTO evento (id_creador, nombre, descripcion, fecha_evento, lugar, modalidad, estado)
VALUES
    (
        (SELECT id_usuario FROM usuario WHERE email = 'admin@pascualina.edu.co'),
        'Hackaton IA 2026',
        'Competencia de inteligencia artificial para estudiantes',
        '2026-05-10 08:00:00',
        'Auditorio Principal',
        'presencial',
        'activo'
    ),
    (
        (SELECT id_usuario FROM usuario WHERE email = 'admin@pascualina.edu.co'),
        'Webinar Bases de Datos NoSQL',
        'Introducción a MongoDB, Redis y Cassandra',
        '2026-05-20 16:00:00',
        'Virtual',
        'virtual',
        'activo'
    );

UPDATE evento
SET metricas_evento = '{
    "asistentes_confirmados": 120,
    "asistentes_reales":      98,
    "tasa_asistencia_pct":    81.7,
    "calificacion_promedio":  4.6,
    "sensores_iot": {
        "aforo_maximo":         150,
        "temperatura_celsius":  22.3,
        "nivel_ruido_db":       68,
        "lecturas_nfc":         94
    },
    "interacciones_chat": {
        "preguntas":    34,
        "respuestas":   29,
        "reacciones":  210
    },
    "hashtags_usados": ["#HackatonIA", "#PascualinaIA2026", "#DesarrolloIA"]
}'::JSONB
WHERE nombre = 'Hackaton IA 2026';

UPDATE evento
SET metricas_evento = '{
    "viewers_pico":            340,
    "viewers_promedio":        215,
    "duracion_promedio_min":   47,
    "tasa_retencion_pct":      63.2,
    "calificacion_promedio":   4.8,
    "plataforma_streaming":    "YouTube Live",
    "preguntas_recibidas":     52,
    "preguntas_respondidas":   38,
    "paises_conectados":       ["Colombia", "México", "Argentina", "Perú"],
    "dispositivos": {
        "movil_pct":    54,
        "desktop_pct":  38,
        "tablet_pct":    8
    }
}'::JSONB
WHERE nombre = 'Webinar Bases de Datos NoSQL';

-- 2.4 Consultas sobre el campo JSONB

-- Consulta 1: Ver métricas completas de todos los eventos
SELECT
    id_evento,
    nombre,
    modalidad,
    metricas_evento
FROM evento
WHERE metricas_evento IS NOT NULL;

-- Consulta 2: Eventos con calificación promedio mayor a 4.5
SELECT
    nombre,
    modalidad,
    (metricas_evento ->> 'calificacion_promedio')::NUMERIC AS calificacion
FROM evento
WHERE metricas_evento IS NOT NULL
  AND (metricas_evento ->> 'calificacion_promedio')::NUMERIC > 4.5;

-- Consulta 3: Datos de sensores IoT de eventos presenciales
SELECT
    nombre,
    metricas_evento -> 'sensores_iot' AS sensores
FROM evento
WHERE modalidad = 'presencial'
  AND metricas_evento ? 'sensores_iot';

-- Consulta 4: Eventos virtuales con más de 300 viewers pico
SELECT
    nombre,
    (metricas_evento ->> 'viewers_pico')::INT AS viewers_pico,
    metricas_evento -> 'paises_conectados' AS paises
FROM evento
WHERE modalidad = 'virtual'
  AND metricas_evento IS NOT NULL
  AND (metricas_evento ->> 'viewers_pico')::INT > 300;
