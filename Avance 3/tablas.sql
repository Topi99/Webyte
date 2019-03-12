create type estado as enum ('AGU', 'BCN', 'BCS', 'CAM', 'CHP', 'CHH', 'CMX', 'COA', 'COL', 'DUR', 'GUA', 'GRO', 'HID', 'JAL', 'MEX', 'MIC', 'MOR', 'NAY', 'NLE', 'OAX', 'PUE', 'QUE', 'ROO', 'SLP', 'SIN', 'SON', 'TAB', 'TAM', 'TLA', 'VER', 'YUC', 'ZAC');

create table usuario
(
  id         serial         unique   not null,
  login      varchar(45)    unique   not null,
  passhash   varchar(100)            not null,
  nombre     varchar(100)            not null,
  apellido   varchar(100)            not null,
  email      varchar(150)            not null,
  creado     timestamp default now() not null,
  modificado timestamp default now(),
  constraint usuario_pk
    primary key (id),
  constraint unique_full_name
    unique (nombre, apellido)
);

create table caja
(
  id             serial       not null,
  direccion      varchar(300) not null,
  responsable_id integer      not null,
  constraint table_name_pk
    primary key (id),
  constraint table_name_staff_usuario_id_fk
    foreign key (responsable_id) references usuario
);

create table rol
(
  id          serial       not null,
  nombre      varchar(25)  not null,
  descripcion varchar(150) not null,
  constraint rol_pk
    primary key (id)
);

create table privilegio
(
  id          serial      not null
    constraint privilegio_pk
      primary key,
  nombre      varchar(25) not null,
  descripcion varchar(250)
);

create table rol_privilegio
(
  rol_id        integer not null,
  privilegio_id integer not null,
  constraint rol_privilegio_pk
    primary key (rol_id, privilegio_id)
);

create table usuario_rol
(
  id_usuario integer not null,
  id_rol     integer not null,
  fecha      timestamp default now(),
  activo     boolean   default true,
  constraint usuario_rol_pkey
    primary key (id_usuario, id_rol),
  constraint usuario_rol_rol_id_fk
    foreign key (id_rol) references rol,
  constraint usuario_rol_usuario_id_fk
    foreign key (id_usuario) references usuario
);

create table municipio
(
  id     serial       not null,
  nombre varchar(200) not null,
  estado estado       not null,
  constraint municipio_pk
    primary key (id)
);

create table canalizacion
(
  id        serial       not null,
  contacto  varchar(250) not null,
  telefono  varchar(250) not null,
  direccion varchar(250) not null,
  constraint canalizacion_pk
    primary key (id)
);

create table beneficiario
(
  id              serial                       not null,
  nombre          varchar(250)                 not null,
  apellido        varchar(250),
  curp            varchar(20)                  unique,
  sexo            char                         not null,
  nacimiento      timestamp                    not null,
  municipio_id    integer                      not null,
  direccion       varchar(250)                 not null,
  canalizacion_id integer,
  rfc             varchar(50)                  unique,
  ine             varchar(50),
  estadocivil     varchar(30)                  not null,
  zonageografica  varchar(20) default 'URBANA' not null,
  extranjero      boolean     default false    not null,
  indigente       boolean     default false    not null,
  profesion       varchar(50)                  not null,

  constraint beneficiario_pk
    primary key (id),
  constraint beneficiario_nombre_apellido_key
    unique (nombre, apellido),
  constraint beneficiario_canalizacion_id_fk
    foreign key (canalizacion_id) references canalizacion,
  constraint beneficiario_municipio_id_fk
    foreign key (municipio_id) references municipio,
  constraint beneficiario_sexo_check
    check ((sexo = 'M' OR sexo = 'F')),
  constraint "beneficiario_zonageografica_check"
    check ( zonageografica = 'RURAL' OR  zonageografica = 'URBANA'),
  constraint beneficiario_estadocivil_check
    check (estadocivil = ANY
           ('CASADO', 'DIVORCIADO', 'UNIONLIBRE', 'SOLTERO')
      )
);

create table programa
(
  id            serial                                  not null,
  lineadeaccion varchar(30) default 'ASISTENCIA SOCIAL' not null,
  nombre        varchar(25) unique                      not null,
  descripcion varchar(250)                              not null,
  constraint programa_pk
    primary key (id),
  constraint programa_lineadeaccion_check
    check (lineadeaccion = 'ASISTENCIA SOCIAL' OR lineadeaccion = 'PROMOCIÓN HUMANA')
);

create table subprograma
(
  id          serial  not null,
  programa_id integer not null,
  nombre      varchar(25) unique,
  descripcion varchar(250),
  constraint subprograma_pk
    primary key (id),
  constraint subprograma_programa_id_fk
    foreign key (programa_id) references programa
);

create table proyecto
(
  id             serial                      not null,
  subprograma_id integer                     not null,
  nombre         varchar(250)      unique    not null,
  descripcion    text,
  municipio_id   integer     default 1799    not null,
  direccion      varchar(250)                not null,
  inicio         timestamp   default now()   not null,
  final          timestamp   default now()   not null,
  solicitado     integer     default 1000    not null,
  estatus        varchar(20) default 'NUEVO' not null,
  responsable    integer                     not null,
  observaciones  varchar(250),
  constraint proyecto_pk
    primary key (id),
  constraint proyecto_subprograma_id_fk
    foreign key (subprograma_id) references subprograma,
  constraint proyecto_municipio_id_fk
    foreign key (municipio_id) references municipio,
  constraint proyecto_estatus_check
    check (estatus = ANY
           ( 'NUEVO', 'PROCESO', 'TERMINADO'))
);

create table gasto
(
  id          serial                  not null,
  proyecto_id integer                 not null,
  concepto    varchar(25),
  monto       integer                 not null,
  fecha       timestamp default now() not null,
  constraint gasto_pk
    primary key (id),
  constraint gasto_proyecto_id_fk
    foreign key (proyecto_id) references proyecto
);


create table donativo
(
  id          uuid                    not null,
  proyecto_id integer                 not null,
  donante_id  integer                 not null,
  monto       integer                 not null,
  fecha       timestamp default now() not null,
  constraint donativo_pk
    primary key (id),
  constraint donativo_donante_id_usuario_fk
    foreign key (donante_id) references usuario,
  constraint donativo_proyecto_id_fk
    foreign key (proyecto_id) references proyecto
);

create table proyecto_beneficiario
(
  proyecto_id     integer                 not null,
  beneficiario_id integer                 not null,
  fecha           timestamp default now() not null,
  constraint proyecto_beneficiario_pk
    primary key (proyecto_id, beneficiario_id),
  constraint proyecto_beneficiario_beneficiario_id_fk
    foreign key (beneficiario_id) references beneficiario,
  constraint proyecto_beneficiario_proyecto_id_fk
    foreign key (proyecto_id) references proyecto
);