--
-- Scripts de Creación de la Base de Datos - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 4 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--
-- Todas las instrucciones se DEBEN EJECUTAR EN SECUENCIA SIN ERRORES
-- NOTA: Primero las tablas independientes y después las dependientes
--

CREATE SCHEMA IF NOT EXISTS pascualina;
SET search_path TO pascualina;

-- ============================================================
-- TABLAS INDEPENDIENTES (sin claves foráneas)
-- ============================================================

CREATE TABLE programa_academico (
    id_programa     SERIAL          NOT NULL,
    codigo          VARCHAR(20)     NOT NULL,
    nombre          VARCHAR(150)    NOT NULL,
    facultad        VARCHAR(100)    NULL,
    nivel           VARCHAR(50)     NULL,
    CONSTRAINT pk_programa_academico PRIMARY KEY (id_programa),
    CONSTRAINT uq_programa_codigo    UNIQUE (codigo)
);

CREATE TABLE habilidad (
    id_habilidad    SERIAL          NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    categoria       VARCHAR(100)    NULL,
    CONSTRAINT pk_habilidad PRIMARY KEY (id_habilidad),
    CONSTRAINT uq_habilidad UNIQUE (nombre)
);

CREATE TABLE interes (
    id_interes      SERIAL          NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    categoria       VARCHAR(100)    NULL,
    CONSTRAINT pk_interes PRIMARY KEY (id_interes),
    CONSTRAINT uq_interes UNIQUE (nombre)
);

CREATE TABLE empresa (
    id_empresa      SERIAL          NOT NULL,
    nombre          VARCHAR(150)    NOT NULL,
    descripcion     TEXT            NULL,
    sitio_web       VARCHAR(255)    NULL,
    contacto        VARCHAR(150)    NULL,
    CONSTRAINT pk_empresa PRIMARY KEY (id_empresa)
);

-- ============================================================
-- SUPERTIPO USUARIO
-- ============================================================

CREATE TABLE usuario (
    id_usuario      SERIAL          NOT NULL,
    nombre          VARCHAR(100)    NULL,
    apellido        VARCHAR(100)    NULL,
    email           VARCHAR(150)    NOT NULL,
    hash_contrasena VARCHAR(255)    NULL,
    fecha_registro  TIMESTAMP       NULL    DEFAULT NOW(),
    foto_perfil     VARCHAR(255)    NULL,
    biografia       TEXT            NULL,
    estado          VARCHAR(20)     NULL    DEFAULT 'activo',
    CONSTRAINT pk_usuario        PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email  UNIQUE (email),
    CONSTRAINT ck_usuario_estado CHECK (estado IN ('activo', 'inactivo', 'suspendido'))
);

-- ============================================================
-- SUBTIPOS DE USUARIO
-- ============================================================

CREATE TABLE estudiante (
    id_usuario          INT         NOT NULL,
    codigo_estudiante   VARCHAR(20) NULL,
    semestre            SMALLINT    NULL,
    id_programa         INT         NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_usuario),
    CONSTRAINT fk_estudiante_usuario
        FOREIGN KEY (id_usuario)  REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_estudiante_programa
        FOREIGN KEY (id_programa) REFERENCES programa_academico(id_programa)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT ck_estudiante_semestre CHECK (semestre BETWEEN 1 AND 10)
);

CREATE TABLE docente (
    id_usuario      INT             NOT NULL,
    codigo_docente  VARCHAR(20)     NULL,
    departamento    VARCHAR(100)    NULL,
    especialidad    VARCHAR(150)    NULL,
    CONSTRAINT pk_docente PRIMARY KEY (id_usuario),
    CONSTRAINT fk_docente_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE empleado (
    id_usuario      INT             NOT NULL,
    codigo_empleado VARCHAR(20)     NULL,
    cargo           VARCHAR(100)    NULL,
    dependencia     VARCHAR(150)    NULL,
    CONSTRAINT pk_empleado PRIMARY KEY (id_usuario),
    CONSTRAINT fk_empleado_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE egresado (
    id_usuario      INT             NOT NULL,
    anio_egreso     SMALLINT        NULL,
    cargo_actual    VARCHAR(100)    NULL,
    empresa_actual  VARCHAR(150)    NULL,
    id_programa     INT             NULL,
    CONSTRAINT pk_egresado PRIMARY KEY (id_usuario),
    CONSTRAINT fk_egresado_usuario
        FOREIGN KEY (id_usuario)   REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_egresado_programa
        FOREIGN KEY (id_programa)  REFERENCES programa_academico(id_programa)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE publico_general (
    id_usuario      INT             NOT NULL,
    organizacion    VARCHAR(150)    NULL,
    tipo_vinculo    VARCHAR(100)    NULL,
    CONSTRAINT pk_publico_general PRIMARY KEY (id_usuario),
    CONSTRAINT fk_publico_gral_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- RELACIONES N:M USUARIO <-> CATÁLOGOS
-- ============================================================

CREATE TABLE usuario_habilidad (
    id_usuario      INT     NOT NULL,
    id_habilidad    INT     NOT NULL,
    CONSTRAINT pk_usuario_habilidad PRIMARY KEY (id_usuario, id_habilidad),
    CONSTRAINT fk_uh_usuario
        FOREIGN KEY (id_usuario)   REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_uh_habilidad
        FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE usuario_interes (
    id_usuario      INT     NOT NULL,
    id_interes      INT     NOT NULL,
    CONSTRAINT pk_usuario_interes PRIMARY KEY (id_usuario, id_interes),
    CONSTRAINT fk_ui_usuario
        FOREIGN KEY (id_usuario)  REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ui_interes
        FOREIGN KEY (id_interes)  REFERENCES interes(id_interes)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- SEGUIMIENTO (RELACIÓN REFLEXIVA N:M)
-- ============================================================

CREATE TABLE seguimiento (
    id_seguidor     INT         NOT NULL,
    id_seguido      INT         NOT NULL,
    fecha_ingreso   TIMESTAMP   NULL    DEFAULT NOW(),
    CONSTRAINT pk_seguimiento PRIMARY KEY (id_seguidor, id_seguido),
    CONSTRAINT fk_seguimiento_seguidor
        FOREIGN KEY (id_seguidor) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_seguimiento_seguido
        FOREIGN KEY (id_seguido)  REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_seguimiento_no_self CHECK (id_seguidor <> id_seguido)
);

-- ============================================================
-- GRUPOS Y MEMBRESÍA
-- ============================================================

CREATE TABLE grupo (
    id_grupo        SERIAL          NOT NULL,
    id_creador      INT             NOT NULL,
    nombre          VARCHAR(150)    NOT NULL,
    descripcion     TEXT            NULL,
    tipo            VARCHAR(50)     NULL,
    fecha_creacion  TIMESTAMP       NULL    DEFAULT NOW(),
    estado          VARCHAR(20)     NULL    DEFAULT 'activo',
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_creador
        FOREIGN KEY (id_creador) REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_grupo_tipo CHECK (tipo IN ('estudio', 'club', 'hackaton', 'proyecto', 'otro'))
);

CREATE TABLE miembro_grupo (
    id_usuario      INT         NOT NULL,
    id_grupo        INT         NOT NULL,
    rol             VARCHAR(50) NULL    DEFAULT 'miembro',
    fecha_ingreso   TIMESTAMP   NULL    DEFAULT NOW(),
    estado          VARCHAR(20) NULL    DEFAULT 'activo',
    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_mg_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_mg_grupo
        FOREIGN KEY (id_grupo)   REFERENCES grupo(id_grupo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- EVENTOS Y ASISTENCIA
-- ============================================================

CREATE TABLE evento (
    id_evento       SERIAL          NOT NULL,
    id_creador      INT             NOT NULL,
    id_grupo        INT             NULL,
    nombre          VARCHAR(150)    NOT NULL,
    descripcion     TEXT            NULL,
    fecha_evento    TIMESTAMP       NULL,
    lugar           VARCHAR(200)    NULL,
    modalidad       VARCHAR(20)     NULL    DEFAULT 'presencial',
    estado          VARCHAR(20)     NULL    DEFAULT 'activo',
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_creador
        FOREIGN KEY (id_creador) REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_evento_grupo
        FOREIGN KEY (id_grupo)   REFERENCES grupo(id_grupo)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE asistencia_evento (
    id_usuario      INT         NOT NULL,
    id_evento       INT         NOT NULL,
    estado          VARCHAR(20) NULL    DEFAULT 'confirmado',
    fecha_registro  TIMESTAMP   NULL    DEFAULT NOW(),
    CONSTRAINT pk_asistencia_evento PRIMARY KEY (id_usuario, id_evento),
    CONSTRAINT fk_ae_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ae_evento
        FOREIGN KEY (id_evento)  REFERENCES evento(id_evento)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- PUBLICACIONES, MULTIMEDIA, COMENTARIOS Y REACCIONES
-- ============================================================

CREATE TABLE publicacion (
    id_publicacion  SERIAL          NOT NULL,
    id_usuario      INT             NOT NULL,
    id_grupo        INT             NULL,
    contenido       TEXT            NULL,
    tipo            VARCHAR(50)     NULL    DEFAULT 'general',
    fecha_creacion  TIMESTAMP       NULL    DEFAULT NOW(),
    estado          VARCHAR(20)     NULL    DEFAULT 'activo',
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_pub_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pub_grupo
        FOREIGN KEY (id_grupo)   REFERENCES grupo(id_grupo)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE publicacion_multimedia (
    id_multimedia   SERIAL          NOT NULL,
    id_publicacion  INT             NOT NULL,
    url             VARCHAR(255)    NOT NULL,
    tipo_archivo    VARCHAR(50)     NULL,
    CONSTRAINT pk_pub_multimedia PRIMARY KEY (id_multimedia),
    CONSTRAINT fk_pm_publicacion
        FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE comentario (
    id_comentario   SERIAL      NOT NULL,
    id_usuario      INT         NOT NULL,
    id_publicacion  INT         NOT NULL,
    id_padre        INT         NULL,
    contenido       TEXT        NOT NULL,
    fecha_creacion  TIMESTAMP   NULL    DEFAULT NOW(),
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_com_usuario
        FOREIGN KEY (id_usuario)     REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_com_publicacion
        FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_com_padre
        FOREIGN KEY (id_padre)       REFERENCES comentario(id_comentario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE reaccion (
    id_reaccion     SERIAL          NOT NULL,
    id_usuario      INT             NOT NULL,
    id_publicacion  INT             NOT NULL,
    tipo            VARCHAR(20)     NOT NULL    DEFAULT 'like',
    fecha_creacion  TIMESTAMP       NULL        DEFAULT NOW(),
    CONSTRAINT pk_reaccion          PRIMARY KEY (id_reaccion),
    CONSTRAINT uq_reaccion_usr_pub  UNIQUE (id_usuario, id_publicacion),
    CONSTRAINT fk_rea_usuario
        FOREIGN KEY (id_usuario)     REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rea_publicacion
        FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_reaccion_tipo CHECK (tipo IN ('like', 'love', 'wow', 'sad', 'angry'))
);

-- ============================================================
-- MARKETPLACE (CAMBALACHE STORE)
-- ============================================================

CREATE TABLE producto (
    id_producto       SERIAL          NOT NULL,
    id_vendedor       INT             NOT NULL,
    nombre            VARCHAR(150)    NOT NULL,
    descripcion       TEXT            NULL,
    precio            NUMERIC(10,2)   NULL,
    estado            VARCHAR(20)     NULL    DEFAULT 'disponible',
    fecha_publicacion TIMESTAMP       NULL    DEFAULT NOW(),
    CONSTRAINT pk_producto PRIMARY KEY (id_producto),
    CONSTRAINT fk_prod_vendedor
        FOREIGN KEY (id_vendedor) REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE producto_foto (
    id_foto         SERIAL          NOT NULL,
    id_producto     INT             NOT NULL,
    url             VARCHAR(255)    NOT NULL,
    orden           SMALLINT        NULL    DEFAULT 1,
    CONSTRAINT pk_producto_foto PRIMARY KEY (id_foto),
    CONSTRAINT fk_pf_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE intercambio (
    id_intercambio  SERIAL          NOT NULL,
    id_producto     INT             NOT NULL,
    id_comprador    INT             NOT NULL,
    fecha           TIMESTAMP       NULL    DEFAULT NOW(),
    estado          VARCHAR(20)     NULL    DEFAULT 'pendiente',
    CONSTRAINT pk_intercambio PRIMARY KEY (id_intercambio),
    CONSTRAINT fk_int_producto
        FOREIGN KEY (id_producto)  REFERENCES producto(id_producto)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_int_comprador
        FOREIGN KEY (id_comprador) REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- BOLSA DE TRABAJO
-- ============================================================

CREATE TABLE oferta_laboral (
    id_oferta           SERIAL          NOT NULL,
    id_empresa          INT             NOT NULL,
    titulo              VARCHAR(150)    NOT NULL,
    descripcion         TEXT            NULL,
    modalidad           VARCHAR(50)     NULL,
    fecha_publicacion   TIMESTAMP       NULL    DEFAULT NOW(),
    fecha_cierre        DATE            NULL,
    estado              VARCHAR(20)     NULL    DEFAULT 'activa',
    CONSTRAINT pk_oferta_laboral PRIMARY KEY (id_oferta),
    CONSTRAINT fk_ol_empresa
        FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE oferta_requisito (
    id_requisito    SERIAL          NOT NULL,
    id_oferta       INT             NOT NULL,
    descripcion     VARCHAR(255)    NOT NULL,
    CONSTRAINT pk_oferta_requisito PRIMARY KEY (id_requisito),
    CONSTRAINT fk_or_oferta
        FOREIGN KEY (id_oferta) REFERENCES oferta_laboral(id_oferta)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE postulacion (
    id_usuario      INT         NOT NULL,
    id_oferta       INT         NOT NULL,
    fecha           TIMESTAMP   NULL    DEFAULT NOW(),
    estado          VARCHAR(20) NULL    DEFAULT 'enviada',
    CONSTRAINT pk_postulacion PRIMARY KEY (id_usuario, id_oferta),
    CONSTRAINT fk_post_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_post_oferta
        FOREIGN KEY (id_oferta)  REFERENCES oferta_laboral(id_oferta)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- MENSAJERÍA, NOTIFICACIONES Y REPORTES
-- ============================================================

CREATE TABLE mensaje (
    id_mensaje      SERIAL      NOT NULL,
    id_emisor       INT         NOT NULL,
    id_receptor     INT         NOT NULL,
    contenido       TEXT        NOT NULL,
    fecha_envio     TIMESTAMP   NULL    DEFAULT NOW(),
    leido           BOOLEAN     NULL    DEFAULT FALSE,
    CONSTRAINT pk_mensaje PRIMARY KEY (id_mensaje),
    CONSTRAINT fk_msg_emisor
        FOREIGN KEY (id_emisor)   REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_msg_receptor
        FOREIGN KEY (id_receptor) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_mensaje_no_self CHECK (id_emisor <> id_receptor)
);

CREATE TABLE notificacion (
    id_notificacion SERIAL          NOT NULL,
    id_usuario      INT             NOT NULL,
    tipo            VARCHAR(50)     NULL,
    contenido       VARCHAR(255)    NULL,
    fecha_creacion  TIMESTAMP       NULL    DEFAULT NOW(),
    leida           BOOLEAN         NULL    DEFAULT FALSE,
    CONSTRAINT pk_notificacion PRIMARY KEY (id_notificacion),
    CONSTRAINT fk_noti_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE reporte (
    id_reporte      SERIAL          NOT NULL,
    id_reportante   INT             NOT NULL,
    tipo            VARCHAR(50)     NULL,
    id_referencia   INT             NULL,
    descripcion     TEXT            NULL,
    fecha           TIMESTAMP       NULL    DEFAULT NOW(),
    estado          VARCHAR(20)     NULL    DEFAULT 'pendiente',
    CONSTRAINT pk_reporte PRIMARY KEY (id_reporte),
    CONSTRAINT fk_rep_reportante
        FOREIGN KEY (id_reportante) REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- Total de tablas: 30
-- ============================================================
