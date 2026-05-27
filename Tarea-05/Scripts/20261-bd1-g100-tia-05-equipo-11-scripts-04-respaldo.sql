--
-- Scripts de RESPALDO de la Base de Datos - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 5 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--
-- Este script contiene los INSERTs de respaldo de las tablas principales.
-- Generado con estructura equivalente a pg_dump para verificación docente.
-- Ejecutar DESPUÉS del script de creación (scripts-02-creacion.sql)
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path TO pascualina;

-- ============================================================
-- RESPALDO: rol
-- ============================================================
INSERT INTO rol (id_rol, nombre_rol, descripcion) VALUES
(1, 'administrador', 'Tiene acceso a todos los elementos de la base de datos de manera irrestricta'),
(2, 'auxiliar',      'Tiene acceso al BackOffice de manera limitada'),
(3, 'miembro',       'Es miembro de la Red Social. Puede publicar, generar eventos, vender y comprar'),
(4, 'visitante',     'Puede acceder a la Red Social pero no puede interactuar de ninguna forma')
ON CONFLICT (id_rol) DO NOTHING;

-- ============================================================
-- RESPALDO: tipo_usuario
-- ============================================================
INSERT INTO tipo_usuario (id_tipo_usuario, nombre_tipo_usuario, descripcion) VALUES
(1, 'estudiante',    'Estudiante activo de la institución'),
(2, 'docente',       'Profesor vinculado a la institución'),
(3, 'egresado',      'Graduado de la institución'),
(4, 'empleado',      'Personal administrativo u operativo'),
(5, 'empresario',    'Empresario aliado de la Red Social'),
(6, 'ex_empleado',   'Ex empleado de la institución'),
(7, 'ex_estudiante', 'Ex estudiante de la institución'),
(8, 'ex_docente',    'Ex docente de la institución'),
(9, 'guess',         'Usuario amigo de la Red Social con algunas limitaciones')
ON CONFLICT (id_tipo_usuario) DO NOTHING;

-- ============================================================
-- RESPALDO: servicio_tipo (primeros 10 registros)
-- ============================================================
INSERT INTO servicio_tipo (id_servicio_tipo, nombre, descripcion) VALUES
(1,  'Asesoría académica',          'Apoyo en materias académicas'),
(2,  'Asesoría Laboral',            'Orientación profesional y laboral'),
(3,  'Curso Tecnológico',           'Cursos de tecnología y programación'),
(4,  'Mantenimiento Moto',          'Servicio de mantenimiento de motocicletas'),
(5,  'Reparación artículo electrónico', 'Reparación de dispositivos electrónicos'),
(6,  'Corte de Cabello',            'Servicio de barbería y peluquería'),
(7,  'Manicure y Pedicure',         'Servicio de cuidado de uñas'),
(8,  'Reparación PC',               'Reparación de computadores y portátiles'),
(9,  'Masaje terapéutico',          'Servicio de masajes y terapias corporales'),
(10, 'Declaración de impuestos',    'Asesoría tributaria y declaración de renta')
ON CONFLICT (id_servicio_tipo) DO NOTHING;

-- ============================================================
-- RESPALDO: evento_tipo (primeros 10 registros)
-- ============================================================
INSERT INTO evento_tipo (id_evento_tipo, nombre, descripcion) VALUES
(1,  'Congreso',              'Evento académico o científico de gran envergadura'),
(2,  'Conferencia',           'Charla o ponencia de un experto'),
(3,  'Taller',                'Actividad práctica de aprendizaje'),
(4,  'Baile',                 'Evento social de baile y entretenimiento'),
(5,  'Fiesta',                'Celebración social'),
(6,  'Conformación de Grupo', 'Evento para formar grupos de trabajo o estudio'),
(7,  'Viaje Turístico',       'Excursión o viaje organizado'),
(8,  'Concierto musical',     'Presentación musical en vivo'),
(9,  'Reunión Semillero',     'Reunión de semillero de investigación'),
(10, 'Feria de comida',       'Feria gastronómica')
ON CONFLICT (id_evento_tipo) DO NOTHING;

-- ============================================================
-- RESPALDO: usuario (primeros 30 registros para verificación)
-- ============================================================
INSERT INTO usuario (id_usuario, codigo_usuario, nombres, apellidos, correo, direccion, fecha_nacimiento, fecha_registro, activo, id_rol, id_tipo_usuario) VALUES
(1, 'USR0001','Valentina','Restrepo Gómez','valentina.restrepo@pascualina.edu.co','Calle 10 # 20-30, Medellín','1990-03-15','2026-05-01 08:00:00',TRUE,1,2),
(2, 'USR0002','Andrés','Montoya Zapata','andres.montoya@pascualina.edu.co','Carrera 45 # 12-10, Bello','1988-07-22','2026-05-01 08:05:00',TRUE,1,2),
(3, 'USR0003','Catalina','Herrera Ríos','catalina.herrera@pascualina.edu.co','Calle 80 # 33-45, Medellín','1992-01-10','2026-05-01 08:10:00',TRUE,1,8),
(4, 'USR0004','Felipe','Ospina Cárdenas','felipe.ospina@pascualina.edu.co','Cra 65 # 48-20, Itagüí','1985-11-05','2026-05-01 08:15:00',TRUE,1,4),
(5, 'USR0005','Daniela','Castro Vargas','daniela.castro@pascualina.edu.co','Av El Poblado # 1-20, Medellín','1991-06-18','2026-05-01 08:20:00',TRUE,1,2),
(20,'USR0020','Julián','Velásquez Salas','julian.velasquez@pascualina.edu.co','Calle 48 # 22-45, Medellín','1997-11-03','2026-05-01 09:35:00',TRUE,2,1),
(21,'USR0021','Sara','Palacio Zapata','sara.palacio@pascualina.edu.co','Cra 43A # 18-10, Medellín','1998-02-14','2026-05-01 09:40:00',TRUE,2,1)
ON CONFLICT (id_usuario) DO NOTHING;

-- ============================================================
-- RESPALDO: perfil (muestra con JSONB)
-- ============================================================
INSERT INTO perfil (id_usuario, informacion_perfil) VALUES
(1, '{"intereses": ["Gestión de BD", "Administración"], "deportes": ["Tenis"], "habilidades": ["SQL", "Excel", "PowerBI"], "disponibilidad": "mañanas", "busca_mentoria": false}'),
(20,'{"intereses": ["SQL", "Python", "IoT"], "deportes": ["Fútbol", "Ciclismo"], "habilidades": ["SQL", "Python", "Java"], "disponibilidad": "tardes", "busca_mentoria": false}'),
(21,'{"intereses": ["Big Data", "Analítica"], "deportes": ["Natación"], "habilidades": ["SQL", "PowerBI", "Excel"], "disponibilidad": "mañanas", "busca_mentoria": true}')
ON CONFLICT (id_usuario) DO NOTHING;

-- ============================================================
-- RESPALDO: evento (primeros 5 registros)
-- ============================================================
INSERT INTO evento (id_evento, id_usuario, id_evento_tipo, codigo_evento, nombre, descripcion, direccion, fecha_evento, fecha_registro, activo) VALUES
(1, 31, 1, 'EVT0001', 'Congreso Internacional de IA',   'Congreso sobre inteligencia artificial aplicada', 'Auditorio Principal Pascualina', '2026-04-15 09:00:00', '2026-04-01 10:00:00', TRUE),
(2, 32, 2, 'EVT0002', 'Conferencia Big Data LATAM',     'Conferencia regional de Big Data',                'Campus Norte, Salón 201',        '2026-04-20 14:00:00', '2026-04-05 10:00:00', TRUE),
(3, 33, 3, 'EVT0003', 'Taller SQL Avanzado',            'Taller práctico de SQL con casos reales',         'Hub de Innovación',              '2026-04-25 10:00:00', '2026-04-10 10:00:00', TRUE),
(4, 34, 4, 'EVT0004', 'Baile de Fin de Semestre',       'Celebración de fin de semestre académico',        'Plazoleta Central',             '2026-05-10 19:00:00', '2026-04-20 10:00:00', TRUE),
(5, 35, 5, 'EVT0005', 'Fiesta de Bienvenida 2026',      'Bienvenida a estudiantes nuevos 2026',            'Cancha Sintética Campus',        '2026-05-15 17:00:00', '2026-04-25 10:00:00', TRUE)
ON CONFLICT (id_evento) DO NOTHING;
