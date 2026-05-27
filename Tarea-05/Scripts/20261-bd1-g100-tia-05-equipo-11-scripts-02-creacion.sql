--
-- Scripts de Creación de la Base de Datos - SGBD PostgreSQL
-- Red Social Estudiantil Pascualina
-- Tarea 5 | Grupo: 11 | Equipo: Sara Palacio Zapata, Julián Velásquez Salas
-- SGBD: PostgreSQL
--
-- Todas las instrucciones se DEBEN EJECUTAR EN SECUENCIA SIN ERRORES
-- NOTA: Primero las tablas independientes y después las dependientes
--

CREATE SCHEMA IF NOT EXISTS pascualina;
SET search_path TO pascualina;

-- ============================================================
-- TABLAS INDEPENDIENTES (catálogos — sin claves foráneas)
-- ============================================================

-- Roles de usuarios en la red social
CREATE TABLE rol (
    id_rol          SERIAL          NOT NULL,
    nombre_rol      VARCHAR(30)     NOT NULL,
    descripcion     VARCHAR(200)    NULL,
    CONSTRAINT pk_rol           PRIMARY KEY (id_rol),
    CONSTRAINT uq_rol_nombre    UNIQUE (nombre_rol)
);

-- Tipos de usuario para clasificación y estadística
CREATE TABLE tipo_usuario (
    id_tipo_usuario         SERIAL          NOT NULL,
    nombre_tipo_usuario     VARCHAR(40)     NOT NULL,
    descripcion             VARCHAR(200)    NULL,
    CONSTRAINT pk_tipo_usuario          PRIMARY KEY (id_tipo_usuario),
    CONSTRAINT uq_tipo_usuario_nombre   UNIQUE (nombre_tipo_usuario)
);

-- Tipos de servicio para clasificación y estadística
CREATE TABLE servicio_tipo (
    id_servicio_tipo    SERIAL          NOT NULL,
    nombre              VARCHAR(100)    NOT NULL,
    descripcion         VARCHAR(200)    NULL,
    CONSTRAINT pk_servicio_tipo         PRIMARY KEY (id_servicio_tipo),
    CONSTRAINT uq_servicio_tipo_nombre  UNIQUE (nombre)
);

-- Tipos de producto para clasificación y estadística
CREATE TABLE producto_tipo (
    id_producto_tipo    SERIAL          NOT NULL,
    nombre              VARCHAR(100)    NOT NULL,
    descripcion         VARCHAR(200)    NULL,
    CONSTRAINT pk_producto_tipo         PRIMARY KEY (id_producto_tipo),
    CONSTRAINT uq_producto_tipo_nombre  UNIQUE (nombre)
);

-- Tipos de evento para clasificación y estadística
CREATE TABLE evento_tipo (
    id_evento_tipo      SERIAL          NOT NULL,
    nombre              VARCHAR(100)    NOT NULL,
    descripcion         VARCHAR(200)    NULL,
    CONSTRAINT pk_evento_tipo           PRIMARY KEY (id_evento_tipo),
    CONSTRAINT uq_evento_tipo_nombre    UNIQUE (nombre)
);

-- ============================================================
-- SUPERTIPO USUARIO
-- ============================================================

CREATE TABLE usuario (
    id_usuario          SERIAL          NOT NULL,
    codigo_usuario      VARCHAR(20)     NOT NULL,
    nombres             VARCHAR(80)     NOT NULL,
    apellidos           VARCHAR(80)     NOT NULL,
    correo              VARCHAR(120)    NOT NULL,
    direccion           VARCHAR(120)    NULL,
    fecha_nacimiento    DATE            NOT NULL,
    fecha_registro      TIMESTAMP       NOT NULL    DEFAULT NOW(),
    activo              BOOLEAN         NOT NULL    DEFAULT TRUE,
    id_rol              INT             NOT NULL,
    id_tipo_usuario     INT             NOT NULL,
    CONSTRAINT pk_usuario               PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_codigo        UNIQUE (codigo_usuario),
    CONSTRAINT uq_usuario_correo        UNIQUE (correo),
    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol)            REFERENCES rol(id_rol)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_usuario_tipo
        FOREIGN KEY (id_tipo_usuario)   REFERENCES tipo_usuario(id_tipo_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- PERFIL DE USUARIO (JSONB — Big Data)
-- Se crea automáticamente al registrar un usuario.
-- Almacena atributos variables: intereses, deportes,
-- habilidades, redes sociales, disponibilidad de mentoría.
-- Caso de uso Big Data: motor de recomendación de pares.
-- ============================================================

CREATE TABLE perfil (
    id_perfil               SERIAL      NOT NULL,
    id_usuario              INT         NOT NULL,
    informacion_perfil      JSONB       NOT NULL    DEFAULT '{}',
    CONSTRAINT pk_perfil                PRIMARY KEY (id_perfil),
    CONSTRAINT uq_perfil_usuario        UNIQUE (id_usuario),
    CONSTRAINT fk_perfil_usuario
        FOREIGN KEY (id_usuario)        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_perfil_jsonb
    ON perfil USING GIN (informacion_perfil);

-- ============================================================
-- PUBLICACIONES Y COMENTARIOS
-- ============================================================

CREATE TABLE publicacion (
    id_publicacion      SERIAL          NOT NULL,
    id_usuario          INT             NOT NULL,
    titulo              VARCHAR(200)    NULL,
    contenido           TEXT            NOT NULL,
    fecha_publicacion   TIMESTAMP       NOT NULL    DEFAULT NOW(),
    activo              BOOLEAN         NOT NULL    DEFAULT TRUE,
    CONSTRAINT pk_publicacion           PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_pub_usuario
        FOREIGN KEY (id_usuario)        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- NOTA: id_usuario_comentario es el usuario que comenta
--       (diferente al id_usuario que publicó)
CREATE TABLE comentario (
    id_comentario           SERIAL      NOT NULL,
    id_publicacion          INT         NOT NULL,
    id_usuario_comentario   INT         NOT NULL,
    contenido               TEXT        NOT NULL,
    fecha_comentario        TIMESTAMP   NOT NULL    DEFAULT NOW(),
    activo                  BOOLEAN     NOT NULL    DEFAULT TRUE,
    CONSTRAINT pk_comentario            PRIMARY KEY (id_comentario),
    CONSTRAINT fk_com_publicacion
        FOREIGN KEY (id_publicacion)    REFERENCES publicacion(id_publicacion)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_com_usuario
        FOREIGN KEY (id_usuario_comentario) REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- GRUPOS
-- ============================================================

CREATE TABLE grupo (
    id_grupo        SERIAL          NOT NULL,
    id_usuario      INT             NOT NULL,
    codigo_grupo    VARCHAR(20)     NOT NULL,
    nombre          VARCHAR(150)    NOT NULL,
    descripcion     TEXT            NULL,
    fecha_creacion  TIMESTAMP       NOT NULL    DEFAULT NOW(),
    activo          BOOLEAN         NOT NULL    DEFAULT TRUE,
    CONSTRAINT pk_grupo             PRIMARY KEY (id_grupo),
    CONSTRAINT uq_grupo_codigo      UNIQUE (codigo_grupo),
    CONSTRAINT fk_grupo_usuario
        FOREIGN KEY (id_usuario)    REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Usuarios que se integran a un grupo
CREATE TABLE grupo_usuarios (
    id_grupo_usuario    SERIAL      NOT NULL,
    id_grupo            INT         NOT NULL,
    id_usuario          INT         NOT NULL,
    fecha_ingreso       TIMESTAMP   NOT NULL    DEFAULT NOW(),
    activo              BOOLEAN     NOT NULL    DEFAULT TRUE,
    CONSTRAINT pk_grupo_usuarios        PRIMARY KEY (id_grupo_usuario),
    CONSTRAINT uq_grupo_usuarios        UNIQUE (id_grupo, id_usuario),
    CONSTRAINT fk_gu_grupo
        FOREIGN KEY (id_grupo)          REFERENCES grupo(id_grupo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_gu_usuario
        FOREIGN KEY (id_usuario)        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- SERVICIOS
-- ============================================================

CREATE TABLE servicio (
    id_servicio         SERIAL          NOT NULL,
    id_usuario          INT             NOT NULL,
    id_servicio_tipo    INT             NOT NULL,
    codigo_servicio     VARCHAR(20)     NOT NULL,
    nombre              VARCHAR(150)    NOT NULL,
    descripcion         TEXT            NULL,
    precio              NUMERIC(10,2)   NOT NULL,
    duracion_horas      NUMERIC(5,1)    NULL,
    ubicacion           VARCHAR(200)    NULL,
    activo              BOOLEAN         NOT NULL    DEFAULT TRUE,
    fecha_registro      TIMESTAMP       NOT NULL    DEFAULT NOW(),
    CONSTRAINT pk_servicio              PRIMARY KEY (id_servicio),
    CONSTRAINT uq_servicio_codigo       UNIQUE (codigo_servicio),
    CONSTRAINT ck_servicio_precio       CHECK (precio >= 0),
    CONSTRAINT fk_serv_usuario
        FOREIGN KEY (id_usuario)        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_serv_tipo
        FOREIGN KEY (id_servicio_tipo)  REFERENCES servicio_tipo(id_servicio_tipo)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Usuarios que solicitan un servicio
CREATE TABLE servicio_usuarios (
    id_servicio_usuario SERIAL          NOT NULL,
    id_servicio         INT             NOT NULL,
    id_usuario          INT             NOT NULL,
    fecha_consumo       TIMESTAMP       NOT NULL    DEFAULT NOW(),
    calificacion        SMALLINT        NULL,
    comentario          TEXT            NULL,
    CONSTRAINT pk_servicio_usuarios     PRIMARY KEY (id_servicio_usuario),
    CONSTRAINT ck_su_calificacion       CHECK (calificacion BETWEEN 1 AND 5),
    CONSTRAINT fk_su_servicio
        FOREIGN KEY (id_servicio)       REFERENCES servicio(id_servicio)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_su_usuario
        FOREIGN KEY (id_usuario)        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- PRODUCTOS
-- ============================================================

CREATE TABLE producto (
    id_producto         SERIAL          NOT NULL,
    id_usuario          INT             NOT NULL,
    id_producto_tipo    INT             NOT NULL,
    codigo_producto     VARCHAR(20)     NOT NULL,
    nombre              VARCHAR(150)    NOT NULL,
    descripcion         TEXT            NULL,
    precio              NUMERIC(10,2)   NOT NULL,
    stock               INT             NOT NULL    DEFAULT 1,
    activo              BOOLEAN         NOT NULL    DEFAULT TRUE,
    fecha_registro      TIMESTAMP       NOT NULL    DEFAULT NOW(),
    CONSTRAINT pk_producto              PRIMARY KEY (id_producto),
    CONSTRAINT uq_producto_codigo       UNIQUE (codigo_producto),
    CONSTRAINT ck_producto_precio       CHECK (precio >= 0),
    CONSTRAINT ck_producto_stock        CHECK (stock >= 0),
    CONSTRAINT fk_prod_usuario
        FOREIGN KEY (id_usuario)        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prod_tipo
        FOREIGN KEY (id_producto_tipo)  REFERENCES producto_tipo(id_producto_tipo)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Usuarios que compran productos
CREATE TABLE producto_usuarios (
    id_producto_usuario SERIAL          NOT NULL,
    id_producto         INT             NOT NULL,
    id_usuario          INT             NOT NULL,
    numero_transaccion  VARCHAR(30)     NOT NULL,
    fecha_compra        TIMESTAMP       NOT NULL    DEFAULT NOW(),
    precio_venta        NUMERIC(10,2)   NOT NULL,
    CONSTRAINT pk_producto_usuarios     PRIMARY KEY (id_producto_usuario),
    CONSTRAINT uq_pu_transaccion        UNIQUE (numero_transaccion),
    CONSTRAINT ck_pu_precio             CHECK (precio_venta >= 0),
    CONSTRAINT fk_pu_producto
        FOREIGN KEY (id_producto)       REFERENCES producto(id_producto)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pu_usuario
        FOREIGN KEY (id_usuario)        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- EVENTOS
-- ============================================================

CREATE TABLE evento (
    id_evento           SERIAL          NOT NULL,
    id_usuario          INT             NOT NULL,
    id_evento_tipo      INT             NOT NULL,
    codigo_evento       VARCHAR(20)     NOT NULL,
    nombre              VARCHAR(200)    NOT NULL,
    descripcion         TEXT            NULL,
    direccion           VARCHAR(200)    NULL,
    fecha_evento        TIMESTAMP       NOT NULL,
    fecha_registro      TIMESTAMP       NOT NULL    DEFAULT NOW(),
    activo              BOOLEAN         NOT NULL    DEFAULT TRUE,
    CONSTRAINT pk_evento                PRIMARY KEY (id_evento),
    CONSTRAINT uq_evento_codigo         UNIQUE (codigo_evento),
    CONSTRAINT fk_evt_usuario
        FOREIGN KEY (id_usuario)        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_evt_tipo
        FOREIGN KEY (id_evento_tipo)    REFERENCES evento_tipo(id_evento_tipo)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Usuarios que se suscriben a un evento
-- NOTA: id_usuario es diferente al id_usuario que creó el evento
CREATE TABLE evento_usuarios (
    id_evento_usuario   SERIAL          NOT NULL,
    id_evento           INT             NOT NULL,
    id_usuario          INT             NOT NULL,
    fecha_suscripcion   TIMESTAMP       NOT NULL    DEFAULT NOW(),
    asistio             BOOLEAN         NULL,
    calificacion        SMALLINT        NULL,
    comentario          TEXT            NULL,
    CONSTRAINT pk_evento_usuarios       PRIMARY KEY (id_evento_usuario),
    CONSTRAINT uq_eu                    UNIQUE (id_evento, id_usuario),
    CONSTRAINT ck_eu_calificacion       CHECK (calificacion BETWEEN 1 AND 5),
    CONSTRAINT fk_eu_evento
        FOREIGN KEY (id_evento)         REFERENCES evento(id_evento)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_eu_usuario
        FOREIGN KEY (id_usuario)        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- Total de tablas: 17
-- ============================================================
