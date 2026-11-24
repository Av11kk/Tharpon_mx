# Módulos cliente conectados a Supabase

La app abre estos módulos desde el navegador privado existente, después de validar el perfil. `RepositorioCliente` usa la instancia ya inicializada de Supabase y queda ligado al ID de la sesión validada. Las consultas personales filtran explícitamente por ese ID, además de RLS. La edición de perfil solo envía nombre y la ruta del avatar. Los reportes solo admiten título y descripción desde la app cliente.

| Módulo | Tablas | Referencia |
| --- | --- | --- |
| Perfil | `perfiles` y correo de Auth | [Mi cuenta](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=9-46), [Editar perfil](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=25-207) |
| Capturas | `capturas`, `especies` | [Archivo](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=1-62), [Formulario](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=25-225), [Detalle](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=25-319) |
| Notas y reportes | `notas`, `reportes` | [Notas](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=25-251), [Crear reporte](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=25-269), [Listado](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=25-295), [Detalle](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=25-305) |
| Especies, consejos y favoritos | `especies`, `categorias_consejos`, `consejos`, `favoritos_consejos` | [Especies](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=22-123), [Consejos](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=1-112), [Favoritos](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=27-703) |
| Equipo, promociones y WhatsApp | `categorias_productos`, `productos`, `imagenes_productos`, `promociones`, `configuracion` | [Equipo](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=1-138), [Producto](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=30-145), [Promociones](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=31-82), [Detalle de oferta](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=31-167), [Contacto](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=31-213) |

El esquema local y el remoto permiten editar nombre y avatar. Biografía, vínculo nota-captura, tipo, ubicación y evidencia de reportes necesitan columnas o relaciones adicionales. La app conserva el correo como dato de solo lectura. Los estados administrativos son `pendiente`, `en_revision` y `resuelto`. La respuesta se muestra cuando existe.

Los catálogos solo presentan contenido publicado. Las ofertas además deben estar vigentes y asociadas a un producto publicado en una categoría publicada. Las consultas leen lotes de 100 con orden estable y completan la colección para buscar y filtrar localmente. Las pantallas principales se montan al abrirlas por primera vez y conservan sus datos al cambiar de módulo. Para catálogos grandes, el siguiente paso es búsqueda indexada en servidor con páginas bajo demanda.

## Imágenes y contacto

- `image_picker` abre la galería. El cliente verifica el tamaño máximo de 5 MB y las firmas JPG, PNG y WebP antes de subir. Las rutas personales empiezan por el ID de usuario. Storage conserva ambos buckets privados y la base guarda rutas, mientras Flutter usa firmas de cinco minutos y vuelve a solicitarlas si falla la carga.
- La edición con fotografía usa una ruta nueva y compara la ruta anterior antes de guardar el cambio. Tras actualizar o borrar la fila, el cliente intenta limpiar la fotografía reemplazada o eliminada. Si la base rechaza definitivamente la escritura, intenta borrar la subida nueva. Ante un fallo de red ambiguo, conserva la subida para evitar borrar una foto que la base podría haber referenciado. La depuración de huérfanos queda como operación de mantenimiento.
- `url_launcher` abre un vínculo HTTPS de WhatsApp solo después de mostrar la vista previa y recibir la pulsación del usuario. El sistema puede abrir WhatsApp o el navegador. Sin número válido, la acción queda inactiva. Un número mexicano local de diez dígitos se normaliza con el prefijo 52.

## Verificación en Android

El acceso a Supabase MCP fue de solo lectura. En la revisión, las 15 tablas públicas tenían RLS, los buckets eran privados y estaban publicadas nueve categorías de productos. El proyecto no tenía especies, consejos, productos ni promociones publicados, y `configuracion.whatsapp` estaba vacío. Para verificar las pantallas con contenido, un responsable del proyecto debe publicar contenido real y configurar el número oficial. Las pruebas de widgets usan repositorios simulados y no prueban RLS en producción.

```powershell
flutter emulators --launch Pixel_8
flutter devices
$clavePublicable = Read-Host 'Pega la clave publicable del proyecto'
flutter run -d emulator-5554 --dart-define=SUPABASE_URL=https://higowqchuedxlxlpydso.supabase.co "--dart-define=SUPABASE_PUBLISHABLE_KEY=$clavePublicable"
```

Usa el ID de Android que muestre `flutter devices`, si difiere.

1. Con la cuenta A, edita el nombre y sustituye el avatar. Registra, busca, edita y elimina una captura de prueba con foto. Crea una nota y un reporte. Reabre la app para comprobar persistencia.
2. Cierra sesión y entra con la cuenta B. Verifica que sus capturas, notas, reportes, favoritos y fotos sean propios. Comprueba con cuentas de integración separadas que las operaciones autorizadas y denegadas cuadran con RLS y que un cliente carece de permiso para cambiar estados de reportes o su rol.
3. Con contenido comercial real, prueba búsqueda, categorías, galería, agotados, vigencia y la vista previa general, de producto y de promoción. Repite el contacto sin WhatsApp instalado y comprueba la alternativa del navegador.
4. Contrasta pantallas y estados con Figma en Android. Los prototipos contienen productos y especies ilustrativos, mientras la app solo presenta los datos disponibles. Las interfaces usan componentes adaptables y aún requieren esa revisión visual con contenido real.
