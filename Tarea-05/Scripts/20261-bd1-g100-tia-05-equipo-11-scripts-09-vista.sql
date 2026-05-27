--
-- Script de VIEW de la Base de Datos - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 5 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--

SET search_path TO pascualina;

-- ============================================================
-- VISTA: vw_detalle_eventos
--
-- Objetivo:
--   Consolidar el detalle completo de los eventos de la Red
--   Social Pascualina: tipo de evento, datos del evento,
--   usuario promotor (con su rol) y usuarios participantes.
--   La Directiva usa esta vista para análisis de actividad,
--   reportes de participación y planificación de agenda.
--
-- Potencial analítico:
--   - Permite filtrar eventos por tipo, fecha o promotor sin
--     necesidad de reescribir los JOINs en cada consulta.
--   - Facilita reportes de participación por tipo de evento.
--   - Base para dashboards de actividad en la Red Social.
--   - Reutilizable en consultas de Business Intelligence.
--
-- Nota: La vista NO incluye el filtro de fechas (WHERE).
--       El filtro se aplica al CONSULTAR la vista (paso 2).
-- ============================================================

-- PASO 1: CREAR LA VISTA (sin filtro de fechas)
CREATE OR REPLACE VIEW vw_detalle_eventos AS
SELECT
    et.nombre                                           AS tipo_evento,
    et.descripcion                                      AS descripcion_tipo,
    e.codigo_evento                                     AS codigo_evento,
    e.nombre                                            AS nombre_evento,
    e.descripcion                                       AS descripcion_evento,
    e.direccion                                         AS lugar_evento,
    e.fecha_evento                                      AS fecha_evento,
    e.fecha_registro                                    AS fecha_publicacion,
    e.activo                                            AS evento_activo,
    u_promotor.codigo_usuario                           AS codigo_promotor,
    u_promotor.nombres || ' ' || u_promotor.apellidos  AS nombre_promotor,
    r.nombre_rol                                        AS rol_promotor,
    eu.fecha_suscripcion                                AS fecha_suscripcion,
    eu.asistio                                          AS asistio_al_evento,
    eu.calificacion                                     AS calificacion_evento,
    eu.comentario                                       AS comentario_evento,
    u_participante.codigo_usuario                       AS codigo_participante,
    u_participante.nombres || ' ' || u_participante.apellidos AS nombre_participante
FROM evento e
    INNER JOIN evento_tipo     et             ON et.id_evento_tipo       = e.id_evento_tipo
    INNER JOIN usuario         u_promotor     ON u_promotor.id_usuario   = e.id_usuario
    INNER JOIN rol             r              ON r.id_rol                 = u_promotor.id_rol
    INNER JOIN evento_usuarios eu             ON eu.id_evento             = e.id_evento
    INNER JOIN usuario         u_participante ON u_participante.id_usuario = eu.id_usuario
ORDER BY et.nombre ASC, e.fecha_evento DESC;

-- Verificación: mostrar estructura de la vista
SELECT column_name, data_type
FROM   information_schema.columns
WHERE  table_schema = 'pascualina'
  AND  table_name   = 'vw_detalle_eventos'
ORDER BY ordinal_position;

-- ============================================================
-- PASO 2: USAR LA VISTA con filtro de fechas
-- Consulta: listado de actividades de los últimos 3 meses
-- ordenado por tipo de evento y fecha descendiente
-- ============================================================
SELECT
    vde.tipo_evento                     AS tipo_evento,
    vde.codigo_evento                   AS codigo_evento,
    vde.nombre_evento                   AS nombre_evento,
    vde.descripcion_evento              AS descripcion,
    vde.lugar_evento                    AS lugar,
    vde.fecha_evento                    AS fecha_evento,
    vde.codigo_promotor                 AS codigo_promotor,
    vde.nombre_promotor                 AS promotor,
    vde.rol_promotor                    AS rol_promotor,
    vde.codigo_participante             AS codigo_participante,
    vde.nombre_participante             AS participante,
    vde.fecha_suscripcion               AS fecha_suscripcion,
    vde.calificacion_evento             AS calificacion,
    vde.comentario_evento               AS comentario
FROM vw_detalle_eventos vde
WHERE vde.fecha_evento >= NOW() - INTERVAL '3 months'
ORDER BY vde.tipo_evento ASC, vde.fecha_evento DESC;
