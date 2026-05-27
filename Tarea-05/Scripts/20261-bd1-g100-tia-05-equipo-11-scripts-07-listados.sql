--
-- Scripts de LISTADOS (SELECT) de la Base de Datos - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 5 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
-- NOTA: No se usa el wildcard "*" en ninguna consulta
--

SET search_path TO pascualina;

-- ============================================================
-- CONSULTA #1 — Sin JOIN
-- Pregunta de negocio: ¿Cuál es el listado completo de usuarios
-- registrados en la Red Social Pascualina con su información
-- personal, fecha de nacimiento y fecha de ingreso?
-- ============================================================
SELECT
    u.codigo_usuario                            AS codigo,
    u.nombres                                   AS nombres,
    u.apellidos                                 AS apellidos,
    u.correo                                    AS correo_electronico,
    u.direccion                                 AS direccion,
    u.fecha_nacimiento                          AS fecha_nacimiento,
    u.fecha_registro                            AS fecha_hora_ingreso_red,
    u.activo                                    AS cuenta_activa
FROM usuario u
ORDER BY u.fecha_registro DESC;

-- ============================================================
-- CONSULTA #2 — 1 JOIN
-- Pregunta de negocio: ¿Cuál es el listado de todos los eventos
-- publicados en la Red Social ordenados por fecha descendiente,
-- incluyendo el nombre del usuario que generó cada evento?
-- ============================================================
SELECT
    e.codigo_evento                             AS codigo_evento,
    e.nombre                                    AS nombre_evento,
    e.descripcion                               AS descripcion_evento,
    e.direccion                                 AS lugar,
    e.fecha_evento                              AS fecha_evento,
    e.fecha_registro                            AS fecha_publicacion,
    e.activo                                    AS activo,
    u.codigo_usuario                            AS codigo_promotor,
    u.nombres || ' ' || u.apellidos            AS nombre_promotor
FROM evento e
    INNER JOIN usuario u ON u.id_usuario = e.id_usuario
ORDER BY e.fecha_evento DESC;

-- ============================================================
-- CONSULTA #3 — 2 JOIN
-- Pregunta de negocio: ¿Cuáles son todos los eventos con su
-- tipo de evento, de un usuario específico (USR0031), junto con
-- los usuarios que se suscribieron a cada uno de sus eventos?
-- ============================================================
SELECT
    u_promotor.codigo_usuario                   AS codigo_promotor,
    u_promotor.nombres || ' ' || u_promotor.apellidos AS nombre_promotor,
    et.nombre                                   AS tipo_evento,
    e.codigo_evento                             AS codigo_evento,
    e.nombre                                    AS nombre_evento,
    e.fecha_evento                              AS fecha_evento,
    u_suscrito.codigo_usuario                   AS codigo_suscrito,
    u_suscrito.nombres || ' ' || u_suscrito.apellidos AS nombre_suscrito,
    eu.fecha_suscripcion                        AS fecha_suscripcion
FROM evento e
    INNER JOIN usuario       u_promotor ON u_promotor.id_usuario  = e.id_usuario
    INNER JOIN evento_tipo   et         ON et.id_evento_tipo       = e.id_evento_tipo
    INNER JOIN evento_usuarios eu       ON eu.id_evento             = e.id_evento
    INNER JOIN usuario       u_suscrito ON u_suscrito.id_usuario   = eu.id_usuario
WHERE u_promotor.codigo_usuario = 'USR0031'
ORDER BY e.fecha_evento DESC, u_suscrito.apellidos ASC;

-- ============================================================
-- CONSULTA #4 — 3 JOIN
-- Pregunta de negocio: ¿Cuáles son los productos vendidos en
-- el último mes, con la fecha de venta, número de transacción,
-- nombre del producto, precio y nombre del vendedor?
-- ============================================================
SELECT
    pu.numero_transaccion                       AS numero_transaccion,
    pu.fecha_compra                             AS fecha_venta,
    pt.nombre                                   AS tipo_producto,
    p.codigo_producto                           AS codigo_producto,
    p.nombre                                    AS nombre_producto,
    pu.precio_venta                             AS precio_venta,
    u_vendedor.codigo_usuario                   AS codigo_vendedor,
    u_vendedor.nombres || ' ' || u_vendedor.apellidos AS nombre_vendedor
FROM producto_usuarios pu
    INNER JOIN producto       p          ON p.id_producto          = pu.id_producto
    INNER JOIN producto_tipo  pt         ON pt.id_producto_tipo     = p.id_producto_tipo
    INNER JOIN usuario        u_vendedor ON u_vendedor.id_usuario   = p.id_usuario
WHERE pu.fecha_compra >= NOW() - INTERVAL '1 month'
ORDER BY pu.fecha_compra DESC;

-- ============================================================
-- CONSULTA #5 — 4 JOIN
-- Pregunta de negocio: ¿Cuáles son los servicios de "Asesoría
-- académica" consumidos en los últimos 3 meses, con fecha,
-- nombre del servicio, precio, vendedor y consumidor?
-- ============================================================
SELECT
    su.fecha_consumo                            AS fecha_consumo_servicio,
    st.nombre                                   AS tipo_servicio,
    s.codigo_servicio                           AS codigo_servicio,
    s.nombre                                    AS nombre_servicio,
    s.precio                                    AS precio_servicio,
    u_vendedor.codigo_usuario                   AS codigo_vendedor,
    u_vendedor.nombres || ' ' || u_vendedor.apellidos AS nombre_vendedor,
    u_comprador.codigo_usuario                  AS codigo_consumidor,
    u_comprador.nombres || ' ' || u_comprador.apellidos AS nombre_consumidor,
    su.calificacion                             AS calificacion_dada
FROM servicio_usuarios su
    INNER JOIN servicio       s           ON s.id_servicio          = su.id_servicio
    INNER JOIN servicio_tipo  st          ON st.id_servicio_tipo    = s.id_servicio_tipo
    INNER JOIN usuario        u_vendedor  ON u_vendedor.id_usuario  = s.id_usuario
    INNER JOIN usuario        u_comprador ON u_comprador.id_usuario = su.id_usuario
WHERE st.nombre = 'Asesoría académica'
  AND su.fecha_consumo >= NOW() - INTERVAL '3 months'
ORDER BY su.fecha_consumo DESC, u_vendedor.apellidos ASC;

-- ============================================================
-- CONSULTA #6 — 4 JOIN (INSIGHT propio)
-- Pregunta de negocio: ¿Cuáles son los grupos con mayor
-- participación, mostrando el nombre del grupo, el usuario
-- creador, la cantidad de miembros y los últimos usuarios
-- que se unieron en los últimos 30 días?
-- ============================================================
SELECT
    g.codigo_grupo                              AS codigo_grupo,
    g.nombre                                    AS nombre_grupo,
    g.descripcion                               AS descripcion_grupo,
    g.fecha_creacion                            AS fecha_creacion_grupo,
    u_creador.codigo_usuario                    AS codigo_creador,
    u_creador.nombres || ' ' || u_creador.apellidos AS nombre_creador,
    r.nombre_rol                                AS rol_creador,
    u_miembro.codigo_usuario                    AS codigo_miembro_nuevo,
    u_miembro.nombres || ' ' || u_miembro.apellidos AS nombre_miembro_nuevo,
    gu.fecha_ingreso                            AS fecha_ingreso_grupo
FROM grupo g
    INNER JOIN usuario        u_creador ON u_creador.id_usuario = g.id_usuario
    INNER JOIN rol            r         ON r.id_rol             = u_creador.id_rol
    INNER JOIN grupo_usuarios gu        ON gu.id_grupo          = g.id_grupo
    INNER JOIN usuario        u_miembro ON u_miembro.id_usuario = gu.id_usuario
WHERE gu.fecha_ingreso >= NOW() - INTERVAL '30 days'
  AND gu.activo = TRUE
ORDER BY g.nombre ASC, gu.fecha_ingreso DESC;
