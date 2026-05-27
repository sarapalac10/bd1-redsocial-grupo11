--
-- Scripts de DELETE de la Base de Datos - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 5 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--

SET search_path TO pascualina;

-- ============================================================
-- 1. INSERT + DELETE de un producto (se cometió un error)
-- ============================================================
-- Contexto: Se publicó por error un producto que no se va
-- a comercializar todavía. Se inserta y se elimina.

INSERT INTO producto (id_usuario, id_producto_tipo, codigo_producto, nombre, descripcion, precio, stock)
VALUES (31, 1, 'PRD_ERROR_01', 'Producto Error - No Publicar',
        'Este producto fue ingresado por error y debe ser eliminado.', 0, 0);

-- Verificación antes de eliminar
SELECT id_producto, codigo_producto, nombre, precio
FROM   producto
WHERE  codigo_producto = 'PRD_ERROR_01';

-- Eliminación del producto erróneo
DELETE FROM producto
WHERE  codigo_producto = 'PRD_ERROR_01';

-- Verificación después de eliminar (debe retornar 0 filas)
SELECT id_producto, codigo_producto, nombre
FROM   producto
WHERE  codigo_producto = 'PRD_ERROR_01';

-- ============================================================
-- 2. INSERT + DELETE de un evento (se cometió un error)
-- ============================================================
-- Contexto: Se publicó un evento que fue cancelado antes
-- de su divulgación oficial.

INSERT INTO evento (id_usuario, id_evento_tipo, codigo_evento, nombre, descripcion, direccion, fecha_evento)
VALUES (32, 3, 'EVT_ERROR_01', 'Evento Error - Cancelado',
        'Evento creado por error. No se publicará en la Red.',
        'Por definir', '2026-12-31 00:00:00');

-- Verificación antes de eliminar
SELECT id_evento, codigo_evento, nombre, activo
FROM   evento
WHERE  codigo_evento = 'EVT_ERROR_01';

-- Primero eliminar suscripciones (por FK)
DELETE FROM evento_usuarios
WHERE  id_evento = (SELECT id_evento FROM evento WHERE codigo_evento = 'EVT_ERROR_01');

-- Luego eliminar el evento
DELETE FROM evento
WHERE  codigo_evento = 'EVT_ERROR_01';

-- Verificación después de eliminar (debe retornar 0 filas)
SELECT id_evento, codigo_evento, nombre
FROM   evento
WHERE  codigo_evento = 'EVT_ERROR_01';

-- ============================================================
-- 3. INSERT + DELETE de un servicio (se cometió un error)
-- ============================================================
-- Contexto: Un usuario publicó un servicio que ya no va a ofrecer.

INSERT INTO servicio (id_usuario, id_servicio_tipo, codigo_servicio, nombre, descripcion, precio, ubicacion)
VALUES (33, 1, 'SRV_ERROR_01', 'Servicio Error - No Ofrecer',
        'Servicio creado por error. Ya no se ofrecerá en la Red.',
        0, 'Sin ubicación');

-- Verificación antes de eliminar
SELECT id_servicio, codigo_servicio, nombre, precio
FROM   servicio
WHERE  codigo_servicio = 'SRV_ERROR_01';

-- Primero eliminar consumos relacionados (por FK)
DELETE FROM servicio_usuarios
WHERE  id_servicio = (SELECT id_servicio FROM servicio WHERE codigo_servicio = 'SRV_ERROR_01');

-- Luego eliminar el servicio
DELETE FROM servicio
WHERE  codigo_servicio = 'SRV_ERROR_01';

-- Verificación después de eliminar (debe retornar 0 filas)
SELECT id_servicio, codigo_servicio, nombre
FROM   servicio
WHERE  codigo_servicio = 'SRV_ERROR_01';
