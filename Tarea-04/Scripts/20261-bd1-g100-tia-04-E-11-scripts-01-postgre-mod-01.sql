--
-- Scripts de Modificación de la Base de Datos - SGBD PostgreSQL
-- Datos Estructurados - Modificación de Tablas
-- Red Social Estudiantil Pascualina
-- Tarea 4 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--
-- Todas las instrucciones se deben realizar en secuencia sin errores
--

SET search_path TO pascualina;

-- ============================================================
-- Gestionar una tabla "nueva"
-- Tabla: etiqueta
-- Propósito: permite categorizar publicaciones con palabras
--            clave definidas por la comunidad (folksonomy).
-- ============================================================

-- 1. Crear la tabla nueva
--    Se crea la tabla 'etiqueta', que representa las palabras
--    clave o tags que los usuarios pueden asignar a publicaciones
--    para facilitar su descubrimiento y búsqueda en la plataforma.

CREATE TABLE etiqueta (
    nombre      VARCHAR(80)     NOT NULL,
    descripcion TEXT            NULL,
    icono_url   VARCHAR(255)    NULL
);


-- 2. Agregar clave primaria y 3 campos adicionales
--    PK: id_etiqueta (SERIAL autoincremental)
--    Campo texto: categoria (temática de la etiqueta)
--    Campo numérico: popularidad (conteo de usos)
--    Campo texto: color_hex (color para visualización en UI)

ALTER TABLE etiqueta
    ADD COLUMN id_etiqueta SERIAL NOT NULL;

ALTER TABLE etiqueta
    ADD CONSTRAINT pk_etiqueta PRIMARY KEY (id_etiqueta);

ALTER TABLE etiqueta
    ADD COLUMN IF NOT EXISTS categoria    VARCHAR(80)  NULL;

ALTER TABLE etiqueta
    ADD COLUMN IF NOT EXISTS popularidad  INT          NULL DEFAULT 0;

ALTER TABLE etiqueta
    ADD COLUMN IF NOT EXISTS color_hex    VARCHAR(7)   NULL DEFAULT '#2E75B6';


-- 3. Quitar uno de los campos
--    Se elimina 'icono_url' porque los íconos se gestionarán
--    a través del sistema de multimedia centralizado.

ALTER TABLE etiqueta
    DROP COLUMN IF EXISTS icono_url;


-- 4. Renombrar la tabla
--    Se renombra 'etiqueta' a 'tag' para alinear el nombre
--    con la terminología estándar usada en plataformas sociales.

ALTER TABLE etiqueta
    RENAME TO tag;


-- 5. Agregar campo único
--    Se agrega restricción UNIQUE en 'nombre' para garantizar
--    que no existan dos tags con el mismo texto en la plataforma.

ALTER TABLE tag
    ADD CONSTRAINT uq_tag_nombre UNIQUE (nombre);


-- 6. Agregar 2 fechas con control de orden
--    fecha_inicio: cuando el tag entra en vigencia.
--    fecha_fin: cuando el tag deja de sugerirse (campañas temporales).
--    Control: fecha_fin debe ser posterior a fecha_inicio.

ALTER TABLE tag
    ADD COLUMN IF NOT EXISTS fecha_inicio DATE NULL,
    ADD COLUMN IF NOT EXISTS fecha_fin    DATE NULL;

ALTER TABLE tag
    ADD CONSTRAINT ck_tag_fechas
        CHECK (fecha_fin IS NULL OR fecha_inicio IS NULL OR fecha_fin > fecha_inicio);


-- 7. Agregar campo entero con control de no negativo
--    'total_usos' registra cuántas publicaciones han usado este tag.

ALTER TABLE tag
    ADD COLUMN IF NOT EXISTS total_usos INT NOT NULL DEFAULT 0;

ALTER TABLE tag
    ADD CONSTRAINT ck_tag_total_usos
        CHECK (total_usos >= 0);


-- 8. Modificar tamaño de campo texto
--    Se amplía 'categoria' de VARCHAR(80) a VARCHAR(150)
--    para permitir categorías con descripciones más detalladas.

ALTER TABLE tag
    ALTER COLUMN categoria TYPE VARCHAR(150);


-- 9. Modificar campo numérico con control de rango
--    'popularidad' se restringe al rango 0-100000
--    para reflejar un índice de popularidad normalizado.

ALTER TABLE tag
    ADD CONSTRAINT ck_tag_popularidad
        CHECK (popularidad IS NULL OR popularidad BETWEEN 0 AND 100000);


-- 10. Agregar índice
--     Se crea índice sobre 'categoria' para acelerar búsquedas
--     y filtros por tipo de etiqueta en el explorador de tags.

CREATE INDEX IF NOT EXISTS idx_tag_categoria
    ON tag(categoria);


-- 11. Eliminar una de las fechas
--     Se elimina 'fecha_fin': los tags una vez activos
--     no caducan; solo tienen fecha de activación.

ALTER TABLE tag
    DROP COLUMN IF EXISTS fecha_fin;


-- 12. Borrar todos los datos sin dejar traza
--     TRUNCATE elimina todos los registros de forma inmediata.
--     RESTART IDENTITY reinicia los contadores SERIAL.
--     CASCADE propaga el truncado a tablas dependientes.

TRUNCATE TABLE tag RESTART IDENTITY CASCADE;
