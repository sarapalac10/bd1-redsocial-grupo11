--
-- Scripts de Creación de la Base de Datos - SGBD MS SQL Server 2019+
-- Red Social Estudiantil Pascualina
-- Tarea 4 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: Microsoft SQL Server
--
-- Todas las instrucciones se DEBEN EJECUTAR EN SECUENCIA SIN ERRORES
-- NOTA: Primero las tablas independientes y después las dependientes
--
-- Diferencias clave vs PostgreSQL:
--   - No hay SERIAL: se usa IDENTITY(1,1)
--   - No hay BOOLEAN: se usa BIT (0=false, 1=true)
--   - No hay SMALLINT autoincremental directo: SMALLINT es tipo de dato
--   - TEXT está deprecado: se usa NVARCHAR(MAX) o VARCHAR(MAX)
--   - Las restricciones CHECK se definen con CONSTRAINT o inline
--   - Los esquemas se crean con CREATE SCHEMA
--   - DEFAULT NOW() se reemplaza por DEFAULT GETDATE()
--   - ON UPDATE CASCADE tiene soporte limitado con FK ciclos
--   - NUMERIC y DECIMAL son equivalentes
--   - Se usa GO para separar lotes (batches) cuando es necesario
--

-- Crear la base de datos
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'pascualina')
    CREATE DATABASE pascualina;
GO

USE pascualina;
GO

-- Crear el esquema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'pascualina')
    EXEC('CREATE SCHEMA pascualina');
GO

-- ============================================================
-- TABLAS INDEPENDIENTES (sin claves foráneas)
-- ============================================================

CREATE TABLE pascualina.programa_academico (
    id_programa     INT             NOT NULL    IDENTITY(1,1),
    codigo          VARCHAR(20)     NOT NULL,
    nombre          VARCHAR(150)    NOT NULL,
    facultad        VARCHAR(100)    NULL,
    nivel           VARCHAR(50)     NULL,
    CONSTRAINT pk_programa_academico PRIMARY KEY (id_programa),
    CONSTRAINT uq_programa_codigo    UNIQUE (codigo)
);
GO

CREATE TABLE pascualina.habilidad (
    id_habilidad    INT             NOT NULL    IDENTITY(1,1),
    nombre          VARCHAR(100)    NOT NULL,
    categoria       VARCHAR(100)    NULL,
    CONSTRAINT pk_habilidad PRIMARY KEY (id_habilidad),
    CONSTRAINT uq_habilidad UNIQUE (nombre)
);
GO

CREATE TABLE pascualina.interes (
    id_interes      INT             NOT NULL    IDENTITY(1,1),
    nombre          VARCHAR(100)    NOT NULL,
    categoria       VARCHAR(100)    NULL,
    CONSTRAINT pk_interes PRIMARY KEY (id_interes),
    CONSTRAINT uq_interes UNIQUE (nombre)
);
GO

CREATE TABLE pascualina.empresa (
    id_empresa      INT             NOT NULL    IDENTITY(1,1),
    nombre          VARCHAR(150)    NOT NULL,
    descripcion     VARCHAR(MAX)    NULL,
    sitio_web       VARCHAR(255)    NULL,
    contacto        VARCHAR(150)    NULL,
    CONSTRAINT pk_empresa PRIMARY KEY (id_empresa)
);
GO

-- ============================================================
-- SUPERTIPO USUARIO
-- ============================================================

CREATE TABLE pascualina.usuario (
    id_usuario      INT             NOT NULL    IDENTITY(1,1),
    nombre          VARCHAR(100)    NULL,
    apellido        VARCHAR(100)    NULL,
    email           VARCHAR(150)    NOT NULL,
    hash_contrasena VARCHAR(255)    NULL,
    fecha_registro  DATETIME        NULL        DEFAULT GETDATE(),
    foto_perfil     VARCHAR(255)    NULL,
    biografia       VARCHAR(MAX)    NULL,
    estado          VARCHAR(20)     NULL        DEFAULT 'activo',
    CONSTRAINT pk_usuario        PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email  UNIQUE (email),
    CONSTRAINT ck_usuario_estado CHECK (estado IN ('activo', 'inactivo', 'suspendido'))
);
GO

-- ============================================================
-- SUBTIPOS DE USUARIO
-- ============================================================

CREATE TABLE pascualina.estudiante (
    id_usuario          INT         NOT NULL,
    codigo_estudiante   VARCHAR(20) NULL,
    semestre            SMALLINT    NULL,
    id_programa         INT         NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_usuario),
    CONSTRAINT fk_estudiante_usuario
        FOREIGN KEY (id_usuario)  REFERENCES pascualina.usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_estudiante_programa
        FOREIGN KEY (id_programa) REFERENCES pascualina.programa_academico(id_programa)
        ON DELETE SET NULL,
    CONSTRAINT ck_estudiante_semestre CHECK (semestre BETWEEN 1 AND 10)
);
GO

CREATE TABLE pascualina.docente (
    id_usuario      INT             NOT NULL,
    codigo_docente  VARCHAR(20)     NULL,
    departamento    VARCHAR(100)    NULL,
    especialidad    VARCHAR(150)    NULL,
    CONSTRAINT pk_docente PRIMARY KEY (id_usuario),
    CONSTRAINT fk_docente_usuario
        FOREIGN KEY (id_usuario) REFERENCES pascualina.usuario(id_usuario)
        ON DELETE CASCADE
);
GO

CREATE TABLE pascualina.empleado (
    id_usuario      INT             NOT NULL,
    codigo_empleado VARCHAR(20)     NULL,
    cargo           VARCHAR(100)    NULL,
    dependencia     VARCHAR(150)    NULL,
    CONSTRAINT pk_empleado PRIMARY KEY (id_usuario),
    CONSTRAINT fk_empleado_usuario
        FOREIGN KEY (id_usuario) REFERENCES pascualina.usuario(id_usuario)
        ON DELETE CASCADE
);
GO

CREATE TABLE pascualina.egresado (
    id_usuario      INT             NOT NULL,
    anio_egreso     SMALLINT        NULL,
    cargo_actual    VARCHAR(100)    NULL,
    empresa_actual  VARCHAR(150)    NULL,
    id_programa     INT             NULL,
    CONSTRAINT pk_egresado PRIMARY KEY (id_usuario),
    CONSTRAINT fk_egresado_usuario
        FOREIGN KEY (id_usuario)  REFERENCES pascualina.usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_egresado_programa
        FOREIGN KEY (id_programa) REFERENCES pascualina.programa_academico(id_programa)
        ON DELETE SET NULL
);
GO

CREATE TABLE pascualina.publico_general (
    id_usuario      INT             NOT NULL,
    organizacion    VARCHAR(150)    NULL,
    tipo_vinculo    VARCHAR(100)    NULL,
    CONSTRAINT pk_publico_general PRIMARY KEY (id_usuario),
    CONSTRAINT fk_publico_gral_usuario
        FOREIGN KEY (id_usuario) REFERENCES pascualina.usuario(id_usuario)
        ON DELETE CASCADE
);
GO

-- ============================================================
-- RELACIONES N:M USUARIO <-> CATÁLOGOS
-- ============================================================

CREATE TABLE pascualina.usuario_habilidad (
    id_usuario      INT     NOT NULL,
    id_habilidad    INT     NOT NULL,
    CONSTRAINT pk_usuario_habilidad PRIMARY KEY (id_usuario, id_habilidad),
    CONSTRAINT fk_uh_usuario
        FOREIGN KEY (id_usuario)   REFERENCES pascualina.usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_uh_habilidad
        FOREIGN KEY (id_habilidad) REFERENCES pascualina.habilidad(id_habilidad)
        ON DELETE CASCADE
);
GO

CREATE TABLE pascualina.usuario_interes (
    id_usuario      INT     NOT NULL,
    id_interes      INT     NOT NULL,
    CONSTRAINT pk_usuario_interes PRIMARY KEY (id_usuario, id_interes),
    CONSTRAINT fk_ui_usuario
        FOREIGN KEY (id_usuario)  REFERENCES pascualina.usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_ui_interes
        FOREIGN KEY (id_interes)  REFERENCES pascualina.interes(id_interes)
        ON DELETE CASCADE
);
GO

-- ============================================================
-- SEGUIMIENTO (RELACIÓN REFLEXIVA N:M)
-- Nota: SQL Server no permite ON DELETE CASCADE en relaciones
-- reflexivas (ciclo de FK). Se usa NO ACTION y se gestiona
-- la eliminación por lógica de aplicación o trigger.
-- ============================================================

CREATE TABLE pascualina.seguimiento (
    id_seguidor     INT         NOT NULL,
    id_seguido      INT         NOT NULL,
    fecha_ingreso   DATETIME    NULL    DEFAULT GETDATE(),
    CONSTRAINT pk_seguimiento PRIMARY KEY (id_seguidor, id_seguido),
    CONSTRAINT fk_seguimiento_seguidor
        FOREIGN KEY (id_seguidor) REFERENCES pascualina.usuario(id_usuario)
        ON DELETE NO ACTION,
    CONSTRAINT fk_seguimiento_seguido
        FOREIGN KEY (id_seguido)  REFERENCES pascualina.usuario(id_usuario)
        ON DELETE NO ACTION,
    CONSTRAINT ck_seguimiento_no_self CHECK (id_seguidor <> id_seguido)
);
GO

-- ============================================================
-- GRUPOS Y MEMBRESÍA
-- ============================================================

CREATE TABLE pascualina.grupo (
    id_grupo        INT             NOT NULL    IDENTITY(1,1),
    id_creador      INT             NOT NULL,
    nombre          VARCHAR(150)    NOT NULL,
    descripcion     VARCHAR(MAX)    NULL,
    tipo            VARCHAR(50)     NULL,
    fecha_creacion  DATETIME        NULL        DEFAULT GETDATE(),
    estado          VARCHAR(20)     NULL        DEFAULT 'activo',
    CONSTRAINT pk_grupo         PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_creador FOREIGN KEY (id_creador)
        REFERENCES pascualina.usuario(id_usuario) ON DELETE NO ACTION,
    CONSTRAINT ck_grupo_tipo    CHECK (tipo IN ('estudio', 'club', 'hackaton', 'proyecto', 'otro'))
);
GO

CREATE TABLE pascualina.miembro_grupo (
    id_usuario      INT         NOT NULL,
    id_grupo        INT         NOT NULL,
    rol             VARCHAR(50) NULL    DEFAULT 'miembro',
    fecha_ingreso   DATETIME    NULL    DEFAULT GETDATE(),
    estado          VARCHAR(20) NULL    DEFAULT 'activo',
    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_mg_usuario    FOREIGN KEY (id_usuario)
        REFERENCES pascualina.usuario(id_usuario) ON DELETE NO ACTION,
    CONSTRAINT fk_mg_grupo      FOREIGN KEY (id_grupo)
        REFERENCES pascualina.grupo(id_grupo)     ON DELETE CASCADE
);
GO

-- ============================================================
-- EVENTOS Y ASISTENCIA
-- ============================================================

CREATE TABLE pascualina.evento (
    id_evento       INT             NOT NULL    IDENTITY(1,1),
    id_creador      INT             NOT NULL,
    id_grupo        INT             NULL,
    nombre          VARCHAR(150)    NOT NULL,
    descripcion     VARCHAR(MAX)    NULL,
    fecha_evento    DATETIME        NULL,
    lugar           VARCHAR(200)    NULL,
    modalidad       VARCHAR(20)     NULL        DEFAULT 'presencial',
    estado          VARCHAR(20)     NULL        DEFAULT 'activo',
    CONSTRAINT pk_evento         PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_creador FOREIGN KEY (id_creador)
        REFERENCES pascualina.usuario(id_usuario) ON DELETE NO ACTION,
    CONSTRAINT fk_evento_grupo   FOREIGN KEY (id_grupo)
        REFERENCES pascualina.grupo(id_grupo)     ON DELETE SET NULL
);
GO

CREATE TABLE pascualina.asistencia_evento (
    id_usuario      INT         NOT NULL,
    id_evento       INT         NOT NULL,
    estado          VARCHAR(20) NULL    DEFAULT 'confirmado',
    fecha_registro  DATETIME    NULL    DEFAULT GETDATE(),
    CONSTRAINT pk_asistencia_evento PRIMARY KEY (id_usuario, id_evento),
    CONSTRAINT fk_ae_usuario        FOREIGN KEY (id_usuario)
        REFERENCES pascualina.usuario(id_usuario) ON DELETE NO ACTION,
    CONSTRAINT fk_ae_evento         FOREIGN KEY (id_evento)
        REFERENCES pascualina.evento(id_evento)   ON DELETE CASCADE
);
GO

-- ============================================================
-- PUBLICACIONES, MULTIMEDIA, COMENTARIOS Y REACCIONES
-- ============================================================

CREATE TABLE pascualina.publicacion (
    id_publicacion  INT             NOT NULL    IDENTITY(1,1),
    id_usuario      INT             NOT NULL,
    id_grupo        INT             NULL,
    contenido       VARCHAR(MAX)    NULL,
    tipo            VARCHAR(50)     NULL        DEFAULT 'general',
    fecha_creacion  DATETIME        NULL        DEFAULT GETDATE(),
    estado          VARCHAR(20)     NULL        DEFAULT 'activo',
    CONSTRAINT pk_publicacion   PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_pub_usuario   FOREIGN KEY (id_usuario)
        REFERENCES pascualina.usuario(id_usuario) ON DELETE NO ACTION,
    CONSTRAINT fk_pub_grupo     FOREIGN KEY (id_grupo)
        REFERENCES pascualina.grupo(id_grupo)     ON DELETE SET NULL
);
GO

CREATE TABLE pascualina.publicacion_multimedia (
    id_multimedia   INT             NOT NULL    IDENTITY(1,1),
    id_publicacion  INT             NOT NULL,
    url             VARCHAR(255)    NOT NULL,
    tipo_archivo    VARCHAR(50)     NULL,
    CONSTRAINT pk_pub_multimedia  PRIMARY KEY (id_multimedia),
    CONSTRAINT fk_pm_publicacion  FOREIGN KEY (id_publicacion)
        REFERENCES pascualina.publicacion(id_publicacion) ON DELETE CASCADE
);
GO

CREATE TABLE pascualina.comentario (
    id_comentario   INT             NOT NULL    IDENTITY(1,1),
    id_usuario      INT             NOT NULL,
    id_publicacion  INT             NOT NULL,
    id_padre        INT             NULL,
    contenido       VARCHAR(MAX)    NOT NULL,
    fecha_creacion  DATETIME        NULL        DEFAULT GETDATE(),
    CONSTRAINT pk_comentario      PRIMARY KEY (id_comentario),
    CONSTRAINT fk_com_usuario     FOREIGN KEY (id_usuario)
        REFERENCES pascualina.usuario(id_usuario)         ON DELETE NO ACTION,
    CONSTRAINT fk_com_publicacion FOREIGN KEY (id_publicacion)
        REFERENCES pascualina.publicacion(id_publicacion) ON DELETE NO ACTION,
    CONSTRAINT fk_com_padre       FOREIGN KEY (id_padre)
        REFERENCES pascualina.comentario(id_comentario)   ON DELETE NO ACTION
);
GO

CREATE TABLE pascualina.reaccion (
    id_reaccion     INT             NOT NULL    IDENTITY(1,1),
    id_usuario      INT             NOT NULL,
    id_publicacion  INT             NOT NULL,
    tipo            VARCHAR(20)     NOT NULL    DEFAULT 'like',
    fecha_creacion  DATETIME        NULL        DEFAULT GETDATE(),
    CONSTRAINT pk_reaccion          PRIMARY KEY (id_reaccion),
    CONSTRAINT uq_reaccion_usr_pub  UNIQUE (id_usuario, id_publicacion),
    CONSTRAINT fk_rea_usuario       FOREIGN KEY (id_usuario)
        REFERENCES pascualina.usuario(id_usuario)         ON DELETE NO ACTION,
    CONSTRAINT fk_rea_publicacion   FOREIGN KEY (id_publicacion)
        REFERENCES pascualina.publicacion(id_publicacion) ON DELETE NO ACTION,
    CONSTRAINT ck_reaccion_tipo     CHECK (tipo IN ('like', 'love', 'wow', 'sad', 'angry'))
);
GO

-- ============================================================
-- MARKETPLACE (CAMBALACHE STORE)
-- ============================================================

CREATE TABLE pascualina.producto (
    id_producto       INT             NOT NULL    IDENTITY(1,1),
    id_vendedor       INT             NOT NULL,
    nombre            VARCHAR(150)    NOT NULL,
    descripcion       VARCHAR(MAX)    NULL,
    precio            DECIMAL(10,2)   NULL,
    estado            VARCHAR(20)     NULL        DEFAULT 'disponible',
    fecha_publicacion DATETIME        NULL        DEFAULT GETDATE(),
    CONSTRAINT pk_producto      PRIMARY KEY (id_producto),
    CONSTRAINT fk_prod_vendedor FOREIGN KEY (id_vendedor)
        REFERENCES pascualina.usuario(id_usuario) ON DELETE NO ACTION
);
GO

CREATE TABLE pascualina.producto_foto (
    id_foto         INT             NOT NULL    IDENTITY(1,1),
    id_producto     INT             NOT NULL,
    url             VARCHAR(255)    NOT NULL,
    orden           SMALLINT        NULL        DEFAULT 1,
    CONSTRAINT pk_producto_foto PRIMARY KEY (id_foto),
    CONSTRAINT fk_pf_producto   FOREIGN KEY (id_producto)
        REFERENCES pascualina.producto(id_producto) ON DELETE CASCADE
);
GO

CREATE TABLE pascualina.intercambio (
    id_intercambio  INT             NOT NULL    IDENTITY(1,1),
    id_producto     INT             NOT NULL,
    id_comprador    INT             NOT NULL,
    fecha           DATETIME        NULL        DEFAULT GETDATE(),
    estado          VARCHAR(20)     NULL        DEFAULT 'pendiente',
    CONSTRAINT pk_intercambio   PRIMARY KEY (id_intercambio),
    CONSTRAINT fk_int_producto  FOREIGN KEY (id_producto)
        REFERENCES pascualina.producto(id_producto)  ON DELETE NO ACTION,
    CONSTRAINT fk_int_comprador FOREIGN KEY (id_comprador)
        REFERENCES pascualina.usuario(id_usuario)    ON DELETE NO ACTION
);
GO

-- ============================================================
-- BOLSA DE TRABAJO
-- ============================================================

CREATE TABLE pascualina.oferta_laboral (
    id_oferta           INT             NOT NULL    IDENTITY(1,1),
    id_empresa          INT             NOT NULL,
    titulo              VARCHAR(150)    NOT NULL,
    descripcion         VARCHAR(MAX)    NULL,
    modalidad           VARCHAR(50)     NULL,
    fecha_publicacion   DATETIME        NULL        DEFAULT GETDATE(),
    fecha_cierre        DATE            NULL,
    estado              VARCHAR(20)     NULL        DEFAULT 'activa',
    CONSTRAINT pk_oferta_laboral PRIMARY KEY (id_oferta),
    CONSTRAINT fk_ol_empresa     FOREIGN KEY (id_empresa)
        REFERENCES pascualina.empresa(id_empresa) ON DELETE NO ACTION
);
GO

CREATE TABLE pascualina.oferta_requisito (
    id_requisito    INT             NOT NULL    IDENTITY(1,1),
    id_oferta       INT             NOT NULL,
    descripcion     VARCHAR(255)    NOT NULL,
    CONSTRAINT pk_oferta_requisito  PRIMARY KEY (id_requisito),
    CONSTRAINT fk_or_oferta         FOREIGN KEY (id_oferta)
        REFERENCES pascualina.oferta_laboral(id_oferta) ON DELETE CASCADE
);
GO

CREATE TABLE pascualina.postulacion (
    id_usuario      INT         NOT NULL,
    id_oferta       INT         NOT NULL,
    fecha           DATETIME    NULL    DEFAULT GETDATE(),
    estado          VARCHAR(20) NULL    DEFAULT 'enviada',
    CONSTRAINT pk_postulacion   PRIMARY KEY (id_usuario, id_oferta),
    CONSTRAINT fk_post_usuario  FOREIGN KEY (id_usuario)
        REFERENCES pascualina.usuario(id_usuario)       ON DELETE NO ACTION,
    CONSTRAINT fk_post_oferta   FOREIGN KEY (id_oferta)
        REFERENCES pascualina.oferta_laboral(id_oferta) ON DELETE NO ACTION
);
GO

-- ============================================================
-- MENSAJERÍA, NOTIFICACIONES Y REPORTES
-- ============================================================

CREATE TABLE pascualina.mensaje (
    id_mensaje      INT             NOT NULL    IDENTITY(1,1),
    id_emisor       INT             NOT NULL,
    id_receptor     INT             NOT NULL,
    contenido       VARCHAR(MAX)    NOT NULL,
    fecha_envio     DATETIME        NULL        DEFAULT GETDATE(),
    leido           BIT             NULL        DEFAULT 0,
    CONSTRAINT pk_mensaje         PRIMARY KEY (id_mensaje),
    CONSTRAINT fk_msg_emisor      FOREIGN KEY (id_emisor)
        REFERENCES pascualina.usuario(id_usuario) ON DELETE NO ACTION,
    CONSTRAINT fk_msg_receptor    FOREIGN KEY (id_receptor)
        REFERENCES pascualina.usuario(id_usuario) ON DELETE NO ACTION,
    CONSTRAINT ck_mensaje_no_self CHECK (id_emisor <> id_receptor)
);
GO

CREATE TABLE pascualina.notificacion (
    id_notificacion INT             NOT NULL    IDENTITY(1,1),
    id_usuario      INT             NOT NULL,
    tipo            VARCHAR(50)     NULL,
    contenido       VARCHAR(255)    NULL,
    fecha_creacion  DATETIME        NULL        DEFAULT GETDATE(),
    leida           BIT             NULL        DEFAULT 0,
    CONSTRAINT pk_notificacion  PRIMARY KEY (id_notificacion),
    CONSTRAINT fk_noti_usuario  FOREIGN KEY (id_usuario)
        REFERENCES pascualina.usuario(id_usuario) ON DELETE CASCADE
);
GO

CREATE TABLE pascualina.reporte (
    id_reporte      INT             NOT NULL    IDENTITY(1,1),
    id_reportante   INT             NOT NULL,
    tipo            VARCHAR(50)     NULL,
    id_referencia   INT             NULL,
    descripcion     VARCHAR(MAX)    NULL,
    fecha           DATETIME        NULL        DEFAULT GETDATE(),
    estado          VARCHAR(20)     NULL        DEFAULT 'pendiente',
    CONSTRAINT pk_reporte        PRIMARY KEY (id_reporte),
    CONSTRAINT fk_rep_reportante FOREIGN KEY (id_reportante)
        REFERENCES pascualina.usuario(id_usuario) ON DELETE NO ACTION
);
GO

-- ============================================================
-- Total de tablas: 30
-- ============================================================
