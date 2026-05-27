--
-- Scripts de Poblamiento de la Base de Datos - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 5 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--
-- Todas las instrucciones se DEBEN EJECUTAR EN SECUENCIA SIN ERRORES
-- NOTA: Primero las tablas independientes y después las dependientes
--

SET search_path TO pascualina;

-- ============================================================
-- 1. ROL (4 registros — Anexo A)
-- ============================================================
INSERT INTO rol (nombre_rol, descripcion) VALUES
('administrador', 'Tiene acceso a todos los elementos de la base de datos de manera irrestricta'),
('auxiliar',      'Tiene acceso al BackOffice de manera limitada'),
('miembro',       'Es miembro de la Red Social. Puede publicar, generar eventos, vender y comprar'),
('visitante',     'Puede acceder a la Red Social pero no puede interactuar de ninguna forma');

-- ============================================================
-- 2. TIPO_USUARIO (9 registros — Anexo A)
-- ============================================================
INSERT INTO tipo_usuario (nombre_tipo_usuario, descripcion) VALUES
('estudiante',    'Estudiante activo de la institución'),
('docente',       'Profesor vinculado a la institución'),
('egresado',      'Graduado de la institución'),
('empleado',      'Personal administrativo u operativo'),
('empresario',    'Empresario aliado de la Red Social'),
('ex_empleado',   'Ex empleado de la institución'),
('ex_estudiante', 'Ex estudiante de la institución'),
('ex_docente',    'Ex docente de la institución'),
('guess',         'Usuario amigo de la Red Social con algunas limitaciones');

-- ============================================================
-- 3. SERVICIO_TIPO (20 registros — Anexo B)
-- ============================================================
INSERT INTO servicio_tipo (nombre, descripcion) VALUES
('Asesoría académica',         'Apoyo en materias académicas'),
('Asesoría Laboral',           'Orientación profesional y laboral'),
('Curso Tecnológico',          'Cursos de tecnología y programación'),
('Mantenimiento Moto',         'Servicio de mantenimiento de motocicletas'),
('Reparación artículo electrónico', 'Reparación de dispositivos electrónicos'),
('Corte de Cabello',           'Servicio de barbería y peluquería'),
('Manicure y Pedicure',        'Servicio de cuidado de uñas'),
('Reparación PC',              'Reparación de computadores y portátiles'),
('Masaje terapéutico',         'Servicio de masajes y terapias corporales'),
('Declaración de impuestos',   'Asesoría tributaria y declaración de renta'),
('Asesoría Trabajo de Grado',  'Apoyo en proyectos de grado'),
('Viaje turístico',            'Organización de planes turísticos'),
('Transporte',                 'Servicio de transporte urbano e intermunicipal'),
('Elaboración de Dulces',      'Producción y venta de dulces artesanales'),
('Reparación de Calzado',      'Servicio de zapatería y arreglo de calzado'),
('Confección vestimenta',      'Diseño y confección de ropa a medida'),
('Organización evento',        'Planeación y logística de eventos'),
('Fotografía profesional',     'Servicio de fotografía para eventos y retratos'),
('Diseño gráfico',             'Creación de piezas gráficas y branding'),
('Clases de idiomas',          'Enseñanza de inglés, portugués y otros idiomas');

-- ============================================================
-- 4. PRODUCTO_TIPO (20 registros — Anexo C)
-- ============================================================
INSERT INTO producto_tipo (nombre, descripcion) VALUES
('Libro',               'Libros físicos y digitales'),
('Motocicleta',         'Motocicletas y repuestos'),
('Vehículo',            'Carros y vehículos automotores'),
('Almuerzo',            'Comidas del mediodía preparadas'),
('Desayuno',            'Desayunos preparados'),
('Ropa',                'Prendas de vestir'),
('Cosméticos',          'Productos de belleza y cuidado personal'),
('Ticket de Concierto', 'Entradas para conciertos y shows'),
('Bolso',               'Bolsos, mochilas y maletas'),
('Zapato',              'Calzado deportivo y formal'),
('Postres',             'Postres artesanales y repostería'),
('Dulces',              'Dulces y confites artesanales'),
('Patineta Eléctrica',  'Patinetas y scooters eléctricos'),
('Teléfono móvil',      'Smartphones y accesorios'),
('Computador',          'Portátiles y equipos de escritorio'),
('Artículo Deportivo',  'Implementos para deportes'),
('Alimentos',           'Arroz, pasta y alimentos no perecederos'),
('Electrodoméstico',    'Neveras, lavadoras y pequeños electrodomésticos'),
('Instrumento musical', 'Guitarras, teclados y accesorios musicales'),
('Juguete',             'Juguetes y artículos para niños');

-- ============================================================
-- 5. EVENTO_TIPO (20 registros — Anexo D)
-- ============================================================
INSERT INTO evento_tipo (nombre, descripcion) VALUES
('Congreso',              'Evento académico o científico de gran envergadura'),
('Conferencia',           'Charla o ponencia de un experto'),
('Taller',                'Actividad práctica de aprendizaje'),
('Baile',                 'Evento social de baile y entretenimiento'),
('Fiesta',                'Celebración social'),
('Conformación de Grupo', 'Evento para formar grupos de trabajo o estudio'),
('Viaje Turístico',       'Excursión o viaje organizado'),
('Concierto musical',     'Presentación musical en vivo'),
('Reunión Semillero',     'Reunión de semillero de investigación'),
('Feria de comida',       'Feria gastronómica'),
('Feria de ropa',         'Feria de moda y venta de ropa'),
('Paseo en moto',         'Recorrido organizado en motocicleta'),
('Feria Tecnológica',     'Exposición de proyectos y productos tecnológicos'),
('Cine - Película',       'Proyección de película o ciclo de cine'),
('Reunión grupo interés', 'Encuentro de un grupo de interés común'),
('Entrevista laboral',    'Proceso de selección de personal'),
('Matrimonio',            'Celebración de matrimonio'),
('Hackaton',              'Competencia de desarrollo de software'),
('Webinar',               'Seminario web en línea'),
('Torneo deportivo',      'Competencia deportiva organizada');

-- ============================================================
-- 6. USUARIO (500 registros)
--    Distribución según Anexo A:
--    - administrador (rol 1): 10 usuarios
--    - auxiliar      (rol 2): 20 usuarios
--    - miembro       (rol 3): 420 usuarios
--    - visitante     (rol 4): 50 usuarios
--    Tipo usuario:
--    - estudiante (1): 300 | docente (2): 70 | egresado (3): 30
--    - empleado (4): 20 | empresario (5): 15 | ex_empleado (6): 5
--    - ex_estudiante (7): 5 | ex_docente (8): 5 | guess (9): 50
-- ============================================================

-- Administradores (rol=1) — 10 usuarios tipo variado
INSERT INTO usuario (codigo_usuario, nombres, apellidos, correo, direccion, fecha_nacimiento, id_rol, id_tipo_usuario) VALUES
('USR0001','Valentina','Restrepo Gómez','valentina.restrepo@pascualina.edu.co','Calle 10 # 20-30, Medellín','1990-03-15',1,2),
('USR0002','Andrés','Montoya Zapata','andres.montoya@pascualina.edu.co','Carrera 45 # 12-10, Bello','1988-07-22',1,2),
('USR0003','Catalina','Herrera Ríos','catalina.herrera@pascualina.edu.co','Calle 80 # 33-45, Medellín','1992-01-10',1,8),
('USR0004','Felipe','Ospina Cárdenas','felipe.ospina@pascualina.edu.co','Cra 65 # 48-20, Itagüí','1985-11-05',1,4),
('USR0005','Daniela','Castro Vargas','daniela.castro@pascualina.edu.co','Av El Poblado # 1-20, Medellín','1991-06-18',1,2),
('USR0006','Sebastián','Arango Patiño','sebastian.arango@pascualina.edu.co','Calle 30 # 80-15, Envigado','1987-09-30',1,3),
('USR0007','Camila','Bedoya Ortiz','camila.bedoya@pascualina.edu.co','Cra 34 # 65-40, Sabaneta','1993-04-25',1,4),
('USR0008','Nicolás','Díaz Moreno','nicolas.diaz@pascualina.edu.co','Calle 55 # 43-12, Medellín','1986-12-07',1,2),
('USR0009','Laura','González Pérez','laura.gonzalez@pascualina.edu.co','Cra 70 # 22-33, Bello','1994-08-14',1,2),
('USR0010','Esteban','Ramírez Torres','esteban.ramirez@pascualina.edu.co','Calle 44 # 28-50, Medellín','1989-02-28',1,4);

-- Auxiliares (rol=2) — 20 usuarios
INSERT INTO usuario (codigo_usuario, nombres, apellidos, correo, direccion, fecha_nacimiento, id_rol, id_tipo_usuario) VALUES
('USR0011','María','López Henao','maria.lopez@pascualina.edu.co','Calle 11 # 14-20, Medellín','1995-05-03',2,1),
('USR0012','Juan','Martínez Salazar','juan.martinez@pascualina.edu.co','Cra 52 # 10-30, Bello','1993-09-17',2,1),
('USR0013','Luisa','Fernández García','luisa.fernandez@pascualina.edu.co','Calle 76 # 55-22, Medellín','1996-12-01',2,2),
('USR0014','Pablo','Agudelo Velásquez','pablo.agudelo@pascualina.edu.co','Cra 30 # 44-12, Itagüí','1994-03-25',2,1),
('USR0015','Sofía','Mejía Hoyos','sofia.mejia@pascualina.edu.co','Av 33 # 78-90, Medellín','1997-07-08',2,3),
('USR0016','Tomás','Cano Ríos','tomas.cano@pascualina.edu.co','Calle 92 # 20-14, Envigado','1992-10-20',2,4),
('USR0017','Isabella','Ruiz Vargas','isabella.ruiz@pascualina.edu.co','Cra 14 # 33-55, Medellín','1998-01-15',2,1),
('USR0018','Mateo','Sánchez Gómez','mateo.sanchez@pascualina.edu.co','Calle 25 # 67-30, Bello','1995-04-12',2,1),
('USR0019','Alejandra','Torres Patiño','alejandra.torres@pascualina.edu.co','Cra 80 # 11-20, Sabaneta','1996-06-28',2,1),
('USR0020','Julián','Velásquez Salas','julian.velasquez@pascualina.edu.co','Calle 48 # 22-45, Medellín','1997-11-03',2,1),
('USR0021','Sara','Palacio Zapata','sara.palacio@pascualina.edu.co','Cra 43A # 18-10, Medellín','1998-02-14',2,1),
('USR0022','Diego','Arias Montoya','diego.arias@pascualina.edu.co','Calle 60 # 34-22, Medellín','1994-08-07',2,2),
('USR0023','Manuela','Cardona Betancur','manuela.cardona@pascualina.edu.co','Cra 65 # 88-40, Bello','1997-03-19',2,1),
('USR0024','Simón','Ochoa Restrepo','simon.ochoa@pascualina.edu.co','Calle 33 # 55-18, Itagüí','1995-09-25',2,1),
('USR0025','Natalia','Zuluaga Cárdenas','natalia.zuluaga@pascualina.edu.co','Av El Poblado # 5-30, Medellín','1996-12-11',2,3),
('USR0026','Cristian','Mesa Hoyos','cristian.mesa@pascualina.edu.co','Cra 70 # 44-60, Envigado','1993-05-30',2,4),
('USR0027','Paola','Giraldo Ospina','paola.giraldo@pascualina.edu.co','Calle 80 # 12-34, Medellín','1998-07-22',2,1),
('USR0028','Ricardo','Álvarez Díaz','ricardo.alvarez@pascualina.edu.co','Cra 34 # 77-15, Sabaneta','1992-01-08',2,2),
('USR0029','Gabriela','Moreno Salazar','gabriela.moreno@pascualina.edu.co','Calle 50 # 33-88, Medellín','1997-04-16',2,1),
('USR0030','Andrés','Toro Zapata','andres.toro@pascualina.edu.co','Cra 48 # 22-70, Bello','1994-10-05',2,1);

-- Miembros (rol=3) — 420 usuarios (estudiantes principalmente)
-- Generamos bloques representativos de cada tipo
-- Estudiantes: 300 (USR0031-USR0330)
INSERT INTO usuario (codigo_usuario, nombres, apellidos, correo, direccion, fecha_nacimiento, id_rol, id_tipo_usuario)
SELECT
    'USR' || LPAD((30 + n)::TEXT, 4, '0'),
    (ARRAY['Carlos','Luis','Jorge','Miguel','Hernán','Camilo','Felipe','Arturo','Roberto','David',
           'Alejandro','Santiago','Daniel','Nicolás','Sebastián','Andrés','Pablo','Tomás','Mateo','Simón',
           'Valentina','María','Laura','Sofía','Isabella','Manuela','Natalia','Paola','Gabriela','Ana'])[((n-1) % 30) + 1],
    (ARRAY['García','Martínez','López','González','Rodríguez','Pérez','Sánchez','Ramírez','Torres','Flores',
           'Rivera','Gómez','Díaz','Reyes','Morales','Cruz','Ortega','Ramos','Herrera','Medina',
           'Vargas','Castro','Ruiz','Jiménez','Moreno','Muñoz','Alvarado','Ríos','Mendoza','Córdoba'])[((n-1) % 30) + 1],
    'usuario' || (30 + n) || '@pascualina.edu.co',
    'Calle ' || (n % 100 + 1) || ' # ' || (n % 50 + 1) || '-' || (n % 99 + 1) || ', Medellín',
    ('2000-01-01'::DATE + ((n % 3650) || ' days')::INTERVAL)::DATE,
    3, 1
FROM generate_series(1, 300) AS n;

-- Docentes: 70 (USR0331-USR0400)
INSERT INTO usuario (codigo_usuario, nombres, apellidos, correo, direccion, fecha_nacimiento, id_rol, id_tipo_usuario)
SELECT
    'USR' || LPAD((330 + n)::TEXT, 4, '0'),
    (ARRAY['Profesor','Doctora','Magíster','Ingeniero','Licenciado','Especialista','Arquitecto',
           'Economista','Psicóloga','Abogado'])[((n-1) % 10) + 1] || ' ' ||
    (ARRAY['Carlos','Luz','Jorge','Ana','Hernán','Carmen','Felipe','Rosa','Roberto','David'])[((n-1) % 10) + 1],
    (ARRAY['García Docente','Martínez Prof','López Cátedra','González Educ','Rodríguez Mag',
           'Pérez Doctor','Sánchez PhD','Ramírez MSc','Torres Esp','Flores Lic',
           'Rivera Ing','Gómez Arq','Díaz Econ','Reyes Psi','Morales Abg',
           'Cruz Adm','Ortega Cont','Ramos Fil','Herrera Soc','Medina His'])[((n-1) % 20) + 1],
    'docente' || (330 + n) || '@pascualina.edu.co',
    'Carrera ' || (n % 80 + 1) || ' # ' || (n % 40 + 1) || '-' || (n % 80 + 1) || ', Medellín',
    ('1970-01-01'::DATE + ((n % 7300) || ' days')::INTERVAL)::DATE,
    3, 2
FROM generate_series(1, 70) AS n;

-- Egresados: 30 (USR0401-USR0430)
INSERT INTO usuario (codigo_usuario, nombres, apellidos, correo, direccion, fecha_nacimiento, id_rol, id_tipo_usuario)
SELECT
    'USR' || LPAD((400 + n)::TEXT, 4, '0'),
    (ARRAY['Carlos','Luisa','Jorge','Ana','Hernán','Carmen','Felipe','Rosa','Roberto','David',
           'Alejandro','María','Laura','Sofía','Camilo','Natalia','Pablo','Paola','Mateo','Sandra',
           'Diego','Claudia','Simón','Gloria','Ricardo','Patricia','Andrés','Marcela','Julián','Beatriz'])[n],
    (ARRAY['Egresado García','Egresado López','Egresado Torres','Egresado Ríos','Egresado Vargas',
           'Egresado Castro','Egresado Ruiz','Egresado Moreno','Egresado Cruz','Egresado Ortega',
           'Egresado Ramos','Egresado Herrera','Egresado Medina','Egresado Flores','Egresado Rivera',
           'Egresado Gómez','Egresado Díaz','Egresado Reyes','Egresado Morales','Egresado Alvarado',
           'Egresado Mendoza','Egresado Córdoba','Egresado Delgado','Egresado Vega','Egresado Molina',
           'Egresado Guerrero','Egresado Romero','Egresado Navarro','Egresado Jiménez','Egresado Soto'])[n],
    'egresado' || (400 + n) || '@pascualina.edu.co',
    'Av ' || n || ' # ' || n || '-' || n || ', Medellín',
    ('1985-01-01'::DATE + ((n % 3650) || ' days')::INTERVAL)::DATE,
    3, 3
FROM generate_series(1, 30) AS n;

-- Empleados: 20 (USR0431-USR0450)
INSERT INTO usuario (codigo_usuario, nombres, apellidos, correo, direccion, fecha_nacimiento, id_rol, id_tipo_usuario)
SELECT
    'USR' || LPAD((430 + n)::TEXT, 4, '0'),
    (ARRAY['Carlos','Luisa','Jorge','Ana','Hernán','Carmen','Felipe','Rosa','Roberto','David',
           'Alejandro','María','Laura','Sofía','Camilo','Natalia','Pablo','Paola','Mateo','Sandra'])[n],
    'Empleado' || n || ' Apellido',
    'empleado' || (430 + n) || '@pascualina.edu.co',
    'Cra ' || n || ' # ' || n || '-' || n || ', Medellín',
    ('1980-01-01'::DATE + ((n % 5000) || ' days')::INTERVAL)::DATE,
    3, 4
FROM generate_series(1, 20) AS n;

-- Empresarios: 15 (USR0451-USR0465)
INSERT INTO usuario (codigo_usuario, nombres, apellidos, correo, direccion, fecha_nacimiento, id_rol, id_tipo_usuario)
SELECT
    'USR' || LPAD((450 + n)::TEXT, 4, '0'),
    (ARRAY['Carlos','Luisa','Jorge','Ana','Hernán','Carmen','Felipe','Rosa','Roberto','David',
           'Alejandro','María','Laura','Sofía','Camilo'])[n],
    'Empresario' || n || ' Apellido',
    'empresario' || (450 + n) || '@pascualina.edu.co',
    'Calle ' || (n*5) || ' # ' || n || '-' || (n*2) || ', Medellín',
    ('1975-01-01'::DATE + ((n % 6000) || ' days')::INTERVAL)::DATE,
    3, 5
FROM generate_series(1, 15) AS n;

-- Ex-empleados: 5, Ex-estudiantes: 5, Ex-docentes: 5 (USR0466-USR0480)
INSERT INTO usuario (codigo_usuario, nombres, apellidos, correo, direccion, fecha_nacimiento, id_rol, id_tipo_usuario) VALUES
('USR0466','Carlos','Ex-Empleado Uno','exemp1@pascualina.edu.co','Medellín','1982-01-01',3,6),
('USR0467','Luisa','Ex-Empleado Dos','exemp2@pascualina.edu.co','Medellín','1983-02-02',3,6),
('USR0468','Jorge','Ex-Empleado Tres','exemp3@pascualina.edu.co','Medellín','1984-03-03',3,6),
('USR0469','Ana','Ex-Empleado Cuatro','exemp4@pascualina.edu.co','Medellín','1985-04-04',3,6),
('USR0470','Hernán','Ex-Empleado Cinco','exemp5@pascualina.edu.co','Medellín','1986-05-05',3,6),
('USR0471','Carmen','Ex-Estudiante Uno','exest1@pascualina.edu.co','Medellín','1998-01-01',3,7),
('USR0472','Felipe','Ex-Estudiante Dos','exest2@pascualina.edu.co','Medellín','1999-02-02',3,7),
('USR0473','Rosa','Ex-Estudiante Tres','exest3@pascualina.edu.co','Medellín','1997-03-03',3,7),
('USR0474','Roberto','Ex-Estudiante Cuatro','exest4@pascualina.edu.co','Medellín','2000-04-04',3,7),
('USR0475','David','Ex-Estudiante Cinco','exest5@pascualina.edu.co','Medellín','2001-05-05',3,7),
('USR0476','Alejandra','Ex-Docente Uno','exdoc1@pascualina.edu.co','Medellín','1972-01-01',3,8),
('USR0477','Simón','Ex-Docente Dos','exdoc2@pascualina.edu.co','Medellín','1968-02-02',3,8),
('USR0478','Natalia','Ex-Docente Tres','exdoc3@pascualina.edu.co','Medellín','1970-03-03',3,8),
('USR0479','Ricardo','Ex-Docente Cuatro','exdoc4@pascualina.edu.co','Medellín','1975-04-04',3,8),
('USR0480','Gabriela','Ex-Docente Cinco','exdoc5@pascualina.edu.co','Medellín','1973-05-05',3,8);

-- Visitantes (rol=4): 50 usuarios tipo guess (USR0481-USR0530)
INSERT INTO usuario (codigo_usuario, nombres, apellidos, correo, direccion, fecha_nacimiento, id_rol, id_tipo_usuario)
SELECT
    'USR' || LPAD((480 + n)::TEXT, 4, '0'),
    (ARRAY['Visitante','Guest','Invitado','Amigo','Externo'])[((n-1) % 5) + 1] || n,
    'Apellido' || n,
    'visitante' || (480 + n) || '@externos.co',
    'Dirección ' || n || ', Ciudad',
    ('1990-01-01'::DATE + ((n % 5000) || ' days')::INTERVAL)::DATE,
    4, 9
FROM generate_series(1, 50) AS n;

-- ============================================================
-- 7. PERFIL (500 registros — uno por usuario, con JSONB)
-- ============================================================
INSERT INTO perfil (id_usuario, informacion_perfil)
SELECT
    id_usuario,
    jsonb_build_object(
        'intereses',    ARRAY['Programación', 'Diseño', 'Deportes', 'Música', 'Fotografía',
                              'IoT', 'Big Data', 'SQL', 'Python', 'Marketing']
                        [1 : (id_usuario % 3 + 1)],
        'deportes',     ARRAY['Fútbol', 'Natación', 'Ciclismo', 'Baloncesto', 'Volleyball']
                        [1 : (id_usuario % 2 + 1)],
        'habilidades',  ARRAY['SQL', 'Python', 'Java', 'React', 'Excel', 'PowerBI']
                        [1 : (id_usuario % 3 + 1)],
        'disponibilidad', CASE WHEN id_usuario % 3 = 0 THEN 'mañanas'
                               WHEN id_usuario % 3 = 1 THEN 'tardes'
                               ELSE 'noches' END,
        'busca_mentoria', (id_usuario % 4 = 0)
    )
FROM usuario;

-- ============================================================
-- 8. PUBLICACION (100 registros)
-- ============================================================
INSERT INTO publicacion (id_usuario, titulo, contenido, fecha_publicacion)
SELECT
    (31 + (n % 420))::INT,
    'Publicación ' || n || ' - ' ||
    (ARRAY['Pregunta sobre BD','Recurso útil','Meme universitario','Noticia tecnológica',
           'Tarea colaborativa','Oportunidad laboral','Evento próximo','Consejo académico',
           'Tutorial SQL','Experiencia de pasantía'])[((n-1) % 10) + 1],
    'Contenido de la publicación número ' || n || '. ' ||
    (ARRAY['¿Alguien sabe cómo hacer un JOIN en SQL?',
           'Les comparto este recurso sobre Python que me ayudó mucho.',
           'Cuando el profe pregunta y nadie sabe la respuesta...',
           'Colombia lidera en adopción de tecnologías de IA en LATAM.',
           'Busco compañeros para proyecto de bases de datos.',
           'Empresa XYZ está contratando practicantes. ¡Apliquen ya!',
           'El próximo sábado hay hackaton en el campus. ¡Inscríbanse!',
           'Tip: usen índices en columnas que filtran frecuentemente.',
           'Tutorial básico de SELECT con JOIN en PostgreSQL.',
           'Mi experiencia en la pasantía fue increíble.'])[((n-1) % 10) + 1],
    NOW() - ((n * 2) || ' hours')::INTERVAL
FROM generate_series(1, 100) AS n;

-- ============================================================
-- 9. COMENTARIO (150 registros)
-- ============================================================
INSERT INTO comentario (id_publicacion, id_usuario_comentario, contenido, fecha_comentario)
SELECT
    (1 + (n % 100))::INT,
    (50 + (n % 400))::INT,
    (ARRAY['¡Excelente publicación!',
           'Muy interesante, gracias por compartir.',
           'Yo también tenía esa duda, gracias.',
           'Comparto tu punto de vista.',
           'Habría que investigar más sobre esto.',
           'Totalmente de acuerdo contigo.',
           '¿Tienes más recursos sobre el tema?',
           'Esto me ayudó mucho para mi tarea.',
           'Muy bien explicado, sigue así.',
           'Me parece un tema muy relevante hoy.'])[((n-1) % 10) + 1],
    NOW() - ((n * 3) || ' hours')::INTERVAL
FROM generate_series(1, 150) AS n;

-- ============================================================
-- 10. GRUPO (10 registros)
-- ============================================================
INSERT INTO grupo (id_usuario, codigo_grupo, nombre, descripcion, fecha_creacion) VALUES
(31, 'GRP001', 'Bases de Datos - Grupo 11',   'Grupo de estudio para la materia de Bases de Datos',        NOW() - '30 days'::INTERVAL),
(32, 'GRP002', 'Hackaton Squad 2026',          'Equipo para participar en el hackaton semestral',            NOW() - '25 days'::INTERVAL),
(33, 'GRP003', 'Python desde Cero',            'Grupo de aprendizaje de Python para principiantes',         NOW() - '20 days'::INTERVAL),
(34, 'GRP004', 'Comunidad IoT Pascualina',     'Entusiastas del Internet de las Cosas',                     NOW() - '18 days'::INTERVAL),
(35, 'GRP005', 'Emprendedores Universitarios', 'Red de estudiantes emprendedores',                          NOW() - '15 days'::INTERVAL),
(36, 'GRP006', 'Cinéfilos Pascualina',         'Amantes del cine y la cultura audiovisual',                 NOW() - '12 days'::INTERVAL),
(37, 'GRP007', 'Fútbol Interfacultades',       'Organización del torneo de fútbol interfacultades',         NOW() - '10 days'::INTERVAL),
(38, 'GRP008', 'Semillero de Investigación BD','Grupo de investigación en bases de datos avanzadas',        NOW() - '8 days'::INTERVAL),
(39, 'GRP009', 'Cambalache Store Oficial',     'Grupo oficial del mercado de intercambio Pascualina',       NOW() - '5 days'::INTERVAL),
(40, 'GRP010', 'Docentes Innovadores',         'Docentes que comparten experiencias pedagógicas innovadoras',NOW() - '3 days'::INTERVAL);

-- ============================================================
-- 11. GRUPO_USUARIOS (120 registros)
-- ============================================================
INSERT INTO grupo_usuarios (id_grupo, id_usuario, fecha_ingreso)
SELECT
    (1 + (n % 10))::INT,
    (41 + (n % 400))::INT,
    NOW() - ((n * 6) || ' hours')::INTERVAL
FROM generate_series(1, 120) AS n
ON CONFLICT (id_grupo, id_usuario) DO NOTHING;

-- ============================================================
-- 12. SERVICIO (50 registros)
-- ============================================================
INSERT INTO servicio (id_usuario, id_servicio_tipo, codigo_servicio, nombre, descripcion, precio, duracion_horas, ubicacion)
SELECT
    (31 + (n % 420))::INT,
    (1 + (n % 20))::INT,
    'SRV' || LPAD(n::TEXT, 4, '0'),
    (ARRAY['Asesoría en SQL avanzado','Tutoría de cálculo','Clases de inglés conversacional',
           'Reparación de portátil','Corte y estilo de cabello','Masaje relajante 60min',
           'Declaración de renta personas naturales','Confección de camisa a medida',
           'Transporte Medellín-Rionegro','Fotografía para grado',
           'Diseño de logo empresarial','Asesoría en proyecto de grado',
           'Mantenimiento de motocicleta','Manicure completo','Elaboración de torta personalizada',
           'Viaje turístico al Oriente','Clase de guitarra','Organización de eventos sociales',
           'Reparación de celular','Asesoría laboral CV y entrevistas'])[((n-1) % 20) + 1],
    'Descripción detallada del servicio número ' || n,
    (ARRAY[25000,30000,40000,50000,60000,75000,80000,100000,120000,150000,
           20000,35000,45000,55000,65000,90000,110000,130000,160000,200000])[((n-1) % 20) + 1],
    (ARRAY[1.0,1.5,2.0,0.5,1.0,1.0,2.0,3.0,2.5,1.5,
           2.0,1.0,2.0,1.0,3.0,8.0,1.0,4.0,0.5,1.0])[((n-1) % 20) + 1],
    'Medellín, Antioquia'
FROM generate_series(1, 50) AS n;

-- ============================================================
-- 13. SERVICIO_USUARIOS (150 registros)
-- ============================================================
INSERT INTO servicio_usuarios (id_servicio, id_usuario, fecha_consumo, calificacion, comentario)
SELECT
    (1 + (n % 50))::INT,
    (51 + (n % 400))::INT,
    NOW() - ((n * 12) || ' hours')::INTERVAL,
    (1 + (n % 5))::SMALLINT,
    (ARRAY['Excelente servicio, lo recomiendo.',
           'Muy buen trabajo, cumplió con lo prometido.',
           'Servicio regular, puede mejorar.',
           'Increíble, superó mis expectativas.',
           'Buena atención y puntualidad.'])[((n-1) % 5) + 1]
FROM generate_series(1, 150) AS n;

-- ============================================================
-- 14. PRODUCTO (70 registros)
-- ============================================================
INSERT INTO producto (id_usuario, id_producto_tipo, codigo_producto, nombre, descripcion, precio, stock)
SELECT
    (31 + (n % 420))::INT,
    (1 + (n % 20))::INT,
    'PRD' || LPAD(n::TEXT, 4, '0'),
    (ARRAY['Libro Fundamentos de BD','Moto Honda CB125 2020','Carro Renault Kwid 2019',
           'Almuerzo ejecutivo bandeja paisa','Desayuno antioqueño completo',
           'Chaqueta denim talla M','Kit de maquillaje profesional',
           'Ticket concierto Carlos Vives','Mochila cuero genuino',
           'Zapatillas Nike Air Force','Cheesecake de maracuyá','Cocadas artesanales',
           'Patineta eléctrica Xiaomi','iPhone 13 128GB','MacBook Air M2',
           'Balón fútbol profesional','Arroz Diana 10kg','Nevera Samsung 360L',
           'Guitarra acústica Yamaha','Set de juguetes educativos'])[((n-1) % 20) + 1],
    'Descripción del producto número ' || n || '. Excelente estado y calidad garantizada.',
    (ARRAY[45000,3200000,28000000,15000,12000,80000,120000,150000,95000,220000,
           25000,8000,850000,2800000,4500000,65000,38000,1200000,380000,55000])[((n-1) % 20) + 1],
    (1 + (n % 10))::INT
FROM generate_series(1, 70) AS n;

-- ============================================================
-- 15. PRODUCTO_USUARIOS (50 registros — ventas del último mes y antes)
-- ============================================================
INSERT INTO producto_usuarios (id_producto, id_usuario, numero_transaccion, fecha_compra, precio_venta)
SELECT
    (1 + (n % 70))::INT,
    (60 + (n % 400))::INT,
    'TXN' || LPAD(n::TEXT, 6, '0'),
    CASE WHEN n <= 30
         THEN NOW() - ((n * 18) || ' hours')::INTERVAL
         ELSE NOW() - ((n + 30) || ' days')::INTERVAL
    END,
    (ARRAY[45000,3200000,28000000,15000,12000,80000,120000,150000,95000,220000,
           25000,8000,850000,2800000,4500000,65000,38000,1200000,380000,55000])[((n-1) % 20) + 1]
FROM generate_series(1, 50) AS n;

-- ============================================================
-- 16. EVENTO (50 registros)
-- ============================================================
INSERT INTO evento (id_usuario, id_evento_tipo, codigo_evento, nombre, descripcion, direccion, fecha_evento)
SELECT
    (31 + (n % 420))::INT,
    (1 + (n % 20))::INT,
    'EVT' || LPAD(n::TEXT, 4, '0'),
    (ARRAY['Congreso Internacional de IA','Conferencia Big Data LATAM','Taller SQL Avanzado',
           'Baile de Fin de Semestre','Fiesta de Bienvenida 2026','Hackaton Innovación Social',
           'Viaje Turístico Guatapé','Concierto Acústico Campus','Reunión Semillero BD',
           'Feria Gastronómica Pascualina','Feria de Ropa Sostenible','Paseo Moteros Antioquia',
           'Feria Tecnológica 2026','Cine al Aire Libre','Reunión Club Ajedrez',
           'Entrevista Laboral Google','Matrimonio Colectivo Simbólico','Hackaton Web3',
           'Webinar Seguridad Informática','Torneo Fútbol 5'])[((n-1) % 20) + 1],
    'Descripción del evento número ' || n || '. Evento organizado por la comunidad Pascualina.',
    (ARRAY['Auditorio Principal Pascualina','Campus Norte, Salón 201','Hub de Innovación',
           'Plazoleta Central','Cancha Sintética Campus','Centro de Convenciones',
           'Vereda El Peñol, Guatapé','Tarima Principal Campus','Sala de Conferencias B3',
           'Zona Verde Campus Sur'])[((n-1) % 10) + 1],
    CASE WHEN n <= 25
         THEN NOW() - ((n * 3) || ' days')::INTERVAL
         ELSE NOW() + ((n - 25) || ' days')::INTERVAL
    END
FROM generate_series(1, 50) AS n;

-- ============================================================
-- 17. EVENTO_USUARIOS (300 registros)
-- ============================================================
INSERT INTO evento_usuarios (id_evento, id_usuario, fecha_suscripcion, asistio, calificacion, comentario)
SELECT
    (1 + (n % 50))::INT,
    (31 + (n % 400))::INT,
    NOW() - ((n * 8) || ' hours')::INTERVAL,
    CASE WHEN n % 3 = 0 THEN TRUE
         WHEN n % 3 = 1 THEN FALSE
         ELSE NULL END,
    CASE WHEN n % 3 = 0 THEN (1 + (n % 5))::SMALLINT ELSE NULL END,
    CASE WHEN n % 3 = 0 THEN
        (ARRAY['Evento excelente, muy bien organizado.',
               'Me encantó la dinámica del evento.',
               'Muy buen ambiente y aprendizaje.',
               'Superó mis expectativas.',
               'Lo recomiendo a todos los estudiantes.'])[((n-1) % 5) + 1]
    ELSE NULL END
FROM generate_series(1, 300) AS n
ON CONFLICT (id_evento, id_usuario) DO NOTHING;
