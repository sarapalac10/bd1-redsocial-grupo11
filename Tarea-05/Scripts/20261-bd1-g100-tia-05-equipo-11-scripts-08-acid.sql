--
-- Script de Verificación de Propiedades ACID - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 5 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--

SET search_path TO pascualina;

-- ============================================================
-- PROPIEDAD 1: ATOMICIDAD
-- Definición: Una transacción se ejecuta completamente
-- o no se ejecuta en absoluto. "O todo o nada."
--
-- Escenario: Un usuario actualiza su dirección y al mismo
-- tiempo se registra un nuevo evento. Se usa ROLLBACK para
-- demostrar que NINGUNA de las dos operaciones se aplicó.
-- ============================================================

-- PASO 1: Ver estado ANTES de la transacción
SELECT id_usuario, codigo_usuario, nombres, direccion
FROM   usuario
WHERE  codigo_usuario = 'USR0031';

SELECT id_evento, codigo_evento, nombre, direccion
FROM   evento
WHERE  codigo_evento = 'EVT0001';

-- PASO 2: Iniciar transacción y ejecutar cambios
BEGIN;

    UPDATE usuario
    SET    direccion = 'DIRECCIÓN TEMPORAL - TRANSACCIÓN INCOMPLETA'
    WHERE  codigo_usuario = 'USR0031';

    UPDATE evento
    SET    direccion = 'LUGAR TEMPORAL - TRANSACCIÓN INCOMPLETA'
    WHERE  codigo_evento = 'EVT0001';

-- PASO 3: Revertir — ningún cambio se aplica
ROLLBACK;

-- PASO 4: Verificar DESPUÉS del ROLLBACK
-- Los datos deben ser idénticos al estado inicial
SELECT id_usuario, codigo_usuario, nombres, direccion
FROM   usuario
WHERE  codigo_usuario = 'USR0031';

SELECT id_evento, codigo_evento, nombre, direccion
FROM   evento
WHERE  codigo_evento = 'EVT0001';

-- Resultado esperado: las direcciones NO cambiaron → ATOMICIDAD verificada

-- ============================================================
-- PROPIEDAD 2: CONSISTENCIA
-- Definición: La base de datos siempre pasa de un estado
-- válido a otro válido. Se respetan PKs, FKs, CHECKs y tipos.
--
-- Se demuestran 3 operaciones que violan restricciones:
-- ============================================================

-- 2.1 INSERT con PK duplicada → debe fallar
-- Intento: insertar un rol con id_rol=1 que ya existe
INSERT INTO rol (id_rol, nombre_rol, descripcion)
VALUES (1, 'administrador_duplicado', 'Este registro no debería crearse');
-- Resultado esperado: ERROR - duplicate key value violates unique constraint
-- La base de datos mantiene su estado consistente

-- 2.2 UPDATE que viola un CHECK → debe fallar
-- Intento: actualizar una calificación con valor 10 (fuera del rango 1-5)
UPDATE servicio_usuarios
SET    calificacion = 10
WHERE  id_servicio_usuario = 1;
-- Resultado esperado: ERROR - new row for relation violates check constraint
-- La restricción ck_su_calificacion CHECK (calificacion BETWEEN 1 AND 5) protege el dato

-- 2.3 DELETE de un registro padre con hijos → debe fallar
-- Intento: eliminar un rol que tienen usuarios asignados
DELETE FROM rol
WHERE  id_rol = 3;
-- Resultado esperado: ERROR - update or delete on table "rol" violates foreign key constraint
-- La FK fk_usuario_rol ON DELETE RESTRICT protege la integridad referencial

-- ============================================================
-- PROPIEDAD 3: AISLAMIENTO
-- Definición: Las transacciones concurrentes no se interfieren
-- entre sí. Cada transacción ve su propia versión de los datos
-- hasta hacer COMMIT.
--
-- Caso hipotético (no ejecutable en una sola sesión):
-- ============================================================

-- CASO HIPOTÉTICO — Simulación conceptual:
-- Sesión A (usuario administrador actualizando precios):
--   BEGIN;
--   UPDATE producto SET precio = 999999 WHERE codigo_producto = 'PRD0001';
--   -- En este punto Sesión B NO ve el precio 999999, ve el precio original
--   -- PostgreSQL usa MVCC (Multi-Version Concurrency Control)
--   COMMIT;
--   -- Solo DESPUÉS del COMMIT Sesión B ve el nuevo precio

-- El nivel de aislamiento por defecto en PostgreSQL es READ COMMITTED:
-- evita lecturas sucias (dirty reads) garantizando que cada consulta
-- solo ve datos confirmados por otras transacciones.
SELECT current_setting('transaction_isolation') AS nivel_aislamiento_actual;

-- ============================================================
-- PROPIEDAD 4: DURABILIDAD
-- Definición: Una vez confirmada con COMMIT, la transacción
-- persiste aunque el sistema falle o se reinicie.
--
-- Escenario: Insertar un nuevo tipo de evento y confirmar.
-- Verificar con SELECT antes y después del COMMIT.
-- ============================================================

-- PASO 1: Verificar estado ANTES
SELECT id_evento_tipo, nombre
FROM   evento_tipo
WHERE  nombre = 'Prueba Durabilidad ACID';

-- PASO 2: Iniciar transacción y confirmar
BEGIN;

    INSERT INTO evento_tipo (nombre, descripcion)
    VALUES ('Prueba Durabilidad ACID',
            'Registro creado para verificar la propiedad de Durabilidad ACID');

COMMIT;

-- PASO 3: Verificar estado DESPUÉS del COMMIT
-- El registro debe aparecer y persistir permanentemente
SELECT id_evento_tipo, nombre, descripcion
FROM   evento_tipo
WHERE  nombre = 'Prueba Durabilidad ACID';

-- Resultado esperado: el registro aparece y no desaparecerá
-- aunque se reinicie el servidor → DURABILIDAD verificada
