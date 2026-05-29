--
-- Scripts de Simulación de Escenarios Big Data e IoT
-- Red Social Estudiantil Pascualina
-- Tarea 6 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--
-- Contexto: El Gobierno Nacional solicitó expandir la Red Pascualina
-- a todas las universidades del país. Se simula la ingesta masiva
-- de usuarios con datos de salud IoT (sensores de campus inteligente).
--

SET search_path TO pascualina2;

-- ============================================================
-- 1. CREAR TABLA usuario_test
-- Campos básicos de usuario + campo JSON con datos de salud IoT
-- ============================================================

DROP TABLE IF EXISTS usuario_test;

CREATE TABLE usuario_test (
    id_test         SERIAL          NOT NULL,
    codigo_usuario  VARCHAR(20)     NOT NULL,
    nombres         VARCHAR(80)     NOT NULL,
    correo          VARCHAR(120)    NOT NULL,
    ciudad          VARCHAR(80)     NULL,
    activo          BOOLEAN         NOT NULL    DEFAULT TRUE,
    fecha_registro  TIMESTAMP       NOT NULL    DEFAULT NOW(),
    datos_salud     JSON            NULL,
    CONSTRAINT pk_usuario_test PRIMARY KEY (id_test)
);

-- ============================================================
-- 2. FUNCIÓN DE GENERACIÓN DE REGISTROS ALEATORIOS
-- Genera N usuarios con datos de salud IoT en formato JSON.
-- Cada registro simula una lectura de sensor de campus
-- inteligente (pulsera de bienestar estudiantil).
-- ============================================================

CREATE OR REPLACE FUNCTION generar_usuarios_test(n INT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO usuario_test (codigo_usuario, nombres, correo, ciudad, activo, datos_salud)
    SELECT
        'TST' || LPAD(gs::TEXT, 8, '0'),
        (ARRAY['Carlos','María','Julián','Sara','Andrés','Luisa','Felipe','Ana',
               'Diego','Natalia','Simón','Valentina','Pablo','Sofía','Mateo']
        )[(gs % 15) + 1]
        || ' ' ||
        (ARRAY['García','Martínez','López','González','Rodríguez','Pérez',
               'Sánchez','Ramírez','Torres','Flores','Rivera','Gómez']
        )[(gs % 12) + 1],
        'test' || gs || '@pascualina.edu.co',
        (ARRAY['Medellín','Bogotá','Cali','Barranquilla','Bucaramanga',
               'Manizales','Pereira','Cartagena','Cúcuta','Ibagué']
        )[(gs % 10) + 1],
        TRUE,
        json_build_object(
            'presion_sanguinea', json_build_object(
                'sistolica',  110 + (gs % 40),
                'diastolica',  70 + (gs % 20),
                'unidad',     'mmHg'
            ),
            'temperatura_corporal', json_build_object(
                'valor', ROUND((36.0 + (gs % 30) * 0.05)::NUMERIC, 1),
                'unidad', 'Celsius'
            ),
            'grupo_sanguineo', (ARRAY['A+','A-','B+','B-','AB+','AB-','O+','O-'])[(gs % 8) + 1],
            'nivel_azucar', json_build_object(
                'valor',  80 + (gs % 60),
                'unidad', 'mg/dL',
                'estado', CASE WHEN (80 + gs % 60) < 100 THEN 'normal'
                               WHEN (80 + gs % 60) < 126 THEN 'prediabetes'
                               ELSE 'alto' END
            ),
            'fecha_medicion', TO_CHAR(NOW() - (gs % 365 || ' days')::INTERVAL, 'YYYY-MM-DD'),
            'hora_medicion',  TO_CHAR(NOW() - (gs % 1440 || ' minutes')::INTERVAL, 'HH24:MI:SS')
        )
    FROM generate_series(1, n) AS gs;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 3. SIMULACIONES DE INGESTA MASIVA CON EXPLAIN ANALYZE
-- EN CADA SIMULACIÓN:
-- a. Ejecutar inserción con EXPLAIN ANALYZE
-- b. Registrar tiempos en el informe
-- c. Calcular tamaño de la tabla
-- d. TRUNCATE para limpiar
-- ============================================================

-- ── SIMULACIÓN 1: 1.000 registros ──────────────────────────
EXPLAIN ANALYZE SELECT generar_usuarios_test(1000);

SELECT ROUND(pg_total_relation_size('pascualina2.usuario_test') / 1024.0 / 1024.0, 2)
    AS tamano_mb_1000;

TRUNCATE TABLE usuario_test RESTART IDENTITY;

-- ── SIMULACIÓN 2: 10.000 registros ─────────────────────────
EXPLAIN ANALYZE SELECT generar_usuarios_test(10000);

SELECT ROUND(pg_total_relation_size('pascualina2.usuario_test') / 1024.0 / 1024.0, 2)
    AS tamano_mb_10000;

TRUNCATE TABLE usuario_test RESTART IDENTITY;

-- ── SIMULACIÓN 3: 100.000 registros ────────────────────────
EXPLAIN ANALYZE SELECT generar_usuarios_test(100000);

SELECT ROUND(pg_total_relation_size('pascualina2.usuario_test') / 1024.0 / 1024.0, 2)
    AS tamano_mb_100000;

TRUNCATE TABLE usuario_test RESTART IDENTITY;

-- ── SIMULACIÓN 4: 1.000.000 registros ──────────────────────
-- NOTA: Esta simulación puede tardar varios minutos.
-- Se recomienda ejecutarla cuando no haya otras cargas en el servidor.
EXPLAIN ANALYZE SELECT generar_usuarios_test(1000000);

SELECT ROUND(pg_total_relation_size('pascualina2.usuario_test') / 1024.0 / 1024.0, 2)
    AS tamano_mb_1000000;

TRUNCATE TABLE usuario_test RESTART IDENTITY;

-- ── SIMULACIÓN 5: 10.000.000 registros ─────────────────────
-- NOTA: Esta simulación es la más intensiva.
-- Puede requerir 30-60 minutos dependiendo del hardware.
-- El tamaño estimado de la tabla es de ~5-8 GB.
EXPLAIN ANALYZE SELECT generar_usuarios_test(10000000);

SELECT ROUND(pg_total_relation_size('pascualina2.usuario_test') / 1024.0 / 1024.0, 2)
    AS tamano_mb_10000000;

TRUNCATE TABLE usuario_test RESTART IDENTITY;

-- ============================================================
-- 4. TABLA CONSOLIDADA DE RESULTADOS
-- Completar con los valores obtenidos del EXPLAIN ANALYZE
-- ============================================================
-- | Sim | Registros   | Escrit. Prep (ms) | Escrit. Ejec (ms) | Tamaño MB |
-- |-----|-------------|-------------------|-------------------|-----------|
-- |  1  |       1.000 | ___               | ___               | ___       |
-- |  2  |      10.000 | ___               | ___               | ___       |
-- |  3  |     100.000 | ___               | ___               | ___       |
-- |  4  |   1.000.000 | ___               | ___               | ___       |
-- |  5  |  10.000.000 | ___               | ___               | ___       |
