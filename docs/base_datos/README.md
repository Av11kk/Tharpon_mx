# Base de datos - Tharpon MX

## Tecnologias
- Supabase
- PostgreSQL
- Supabase Auth
- Supabase Storage
- Row Level Security (RLS)

## Arquitectura

Base de datos compartida entre Tharpon MX Cliente
y Tharpon MX Admin.

## Implementacion inicial

- 15 tablas relacionadas.
- Llaves primarias y foraneas.
- 31 politicas de acceso.
- Seguridad RLS en todas las tablas.
- Creacion automatica de perfiles.
- Roles de cliente y administrador.
- 2 contenedores privados de almacenamiento.
- 9 categorias iniciales de productos.
- 8 categorias iniciales de consejos.

## Migraciones

1. Perfiles y seguridad.
2. Catalogo y contenido.
3. Datos personales y almacenamiento.
4. Categorias iniciales.

## Estado del desarrollo

Base de datos inicial implementada en Supabase.
Auditoria inicial de seguridad sin alertas.
Pendientes las pruebas funcionales de autenticacion
y la integracion con Flutter.
