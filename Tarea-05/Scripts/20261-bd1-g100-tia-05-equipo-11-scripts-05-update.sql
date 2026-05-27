--
-- Scripts de UPDATE de la Base de Datos - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 5 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--

SET search_path TO pascualina;

-- ============================================================
-- 1. Actualización de dirección de un usuario
-- ============================================================
-- Pregunta de negocio: ¿Cómo se actualiza la dirección de un usuario
-- que cambió de residencia?
UPDATE usuario
SET    direccion = 'Cra 43A # 18-10 Apt 302, El Poblado, Medellín'
WHERE  codigo_usuario = 'USR0021';

-- Verificación
SELECT id_usuario, codigo_usuario, nombres, apellidos, direccion
FROM   usuario
WHERE  codigo_usuario = 'USR0021';

-- ============================================================
-- 2. Actualización de dirección de un evento
-- ============================================================
-- Pregunta de negocio: ¿Cómo se actualiza el lugar de un evento
-- que cambió de sede por razones logísticas?
UPDATE evento
SET    direccion = 'Centro de Convenciones Plaza Mayor, Medellín'
WHERE  codigo_evento = 'EVT0001';

-- Verificación
SELECT id_evento, codigo_evento, nombre, direccion
FROM   evento
WHERE  codigo_evento = 'EVT0001';

-- ============================================================
-- 3. Actualización de precio del producto 1
-- ============================================================
-- Pregunta de negocio: ¿Cómo se actualiza el precio de un producto
-- cuyo vendedor decidió hacer un descuento?
UPDATE producto
SET    precio = 38000
WHERE  codigo_producto = 'PRD0001';

-- Verificación
SELECT id_producto, codigo_producto, nombre, precio
FROM   producto
WHERE  codigo_producto = 'PRD0001';

-- ============================================================
-- 4. Actualización de precio del producto 2
-- ============================================================
UPDATE producto
SET    precio = 2950000
WHERE  codigo_producto = 'PRD0002';

-- Verificación
SELECT id_producto, codigo_producto, nombre, precio
FROM   producto
WHERE  codigo_producto = 'PRD0002';

-- ============================================================
-- 5. Actualización de precio del producto 3
-- ============================================================
UPDATE producto
SET    precio = 75000
WHERE  codigo_producto = 'PRD0006';

-- Verificación
SELECT id_producto, codigo_producto, nombre, precio
FROM   producto
WHERE  codigo_producto = 'PRD0006';

-- ============================================================
-- 6. Actualización de fecha del evento 1
-- ============================================================
-- Pregunta de negocio: ¿Cómo se pospone la fecha de un evento
-- que fue reprogramado por el organizador?
UPDATE evento
SET    fecha_evento = '2026-06-15 09:00:00'
WHERE  codigo_evento = 'EVT0003';

-- Verificación
SELECT id_evento, codigo_evento, nombre, fecha_evento
FROM   evento
WHERE  codigo_evento = 'EVT0003';

-- ============================================================
-- 7. Actualización de fecha del evento 2
-- ============================================================
UPDATE evento
SET    fecha_evento = '2026-07-20 14:00:00'
WHERE  codigo_evento = 'EVT0005';

-- Verificación
SELECT id_evento, codigo_evento, nombre, fecha_evento
FROM   evento
WHERE  codigo_evento = 'EVT0005';
