# Clima, Mareas y Mapa

La navegación privada crea un `EntornoGeo` por sesión. Inicio y las pantallas completas comparten los resultados, la actualización manual y las solicitudes en curso. El repositorio retiene durante 15 minutos hasta 12 resultados de cada tipo en memoria. Tras un fallo, reusa el último resultado del mismo lugar y lo marca como anterior. Las peticiones HTTP tienen diez segundos de tiempo límite y un reintento para errores de red o HTTP 5xx. Los campos faltantes se muestran con un guion o un estado vacío.

- **Clima** conserva Open-Meteo e incorpora condiciones actuales, métricas ampliadas, 24 horas próximas, siete días y dos gráficas. Open-Meteo devuelve los horarios civiles de la localidad con `timezone=auto`. Flutter los muestra sin convertirlos al huso del dispositivo. La hora de consulta sí se identifica como hora del dispositivo. [Diseño Clima](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=5-2) · [Weather Forecast API](https://open-meteo.com/en/docs)
- **Mareas** usa Open-Meteo Marine. Presenta oleaje, dirección, período y serie de nivel medio global del mar (MSL) por fecha. Esta última combina mareas y otros efectos, y su resolución limita la utilidad en lagunas y puertos. Los horarios y alturas de pleamar y bajamar se consultan solo al configurar el proveedor específico. [Diseño Mareas](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=12-61) · [Marine API](https://open-meteo.com/en/docs/marine-weather-api)
- **Mapa** usa Flutter Map con teselas HTTPS, desplazamiento, zoom, búsqueda, lista, marcadores numerados y centrado. Consulta solo `puntos_pesca` publicados y relaciona `puntos_especies` con `especies` publicadas. Las fotos usan el almacenamiento privado del catálogo y URLs firmadas. Inicio muestra la cantidad de puntos consultada por el mapa en vez de un croquis. [Diseño Mapa](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=1-88) · [Flutter Map](https://docs.fleaflet.dev/)
- **Ubicación** solicita un permiso de primer plano al pulsar la acción correspondiente. Android pide ubicación aproximada. Flutter redondea las coordenadas antes de usarlas y las conserva solo en memoria. La geocodificación manual envía únicamente el nombre escrito. La búsqueda y el uso de Ciudad del Carmen funcionan aunque el GPS esté desactivado. [Geolocator](https://pub.dev/packages/geolocator) · [Geocoding API](https://open-meteo.com/en/docs/geocoding-api)

## Proveedores, costos y cobertura

| Proveedor | Decisión y términos |
| --- | --- |
| Open-Meteo | Conservado para clima, mar y geocodificación. El endpoint abierto es no comercial, sin clave, sin SLA y con límites de 600 llamadas/minuto, 5 000/hora y 10 000/día. Las consultas con muchas variables pueden ponderarse. El plan comercial tiene licencia y acceso con clave. La capa Flutter admite una pasarela licenciada o autoalojada detrás de HTTPS. [Precios](https://open-meteo.com/en/pricing) · [Términos](https://open-meteo.com/en/terms) |
| Google Weather API | Ofrece datos actuales, hasta 240 horas y diez días, además de alertas según cobertura. Exige proyecto con facturación y clave u OAuth y tiene requisitos de licencia. El SKU global Weather Usage lista 10 000 usos gratuitos y USD 0.15 por mil en el primer tramo de pago. Se mantuvo Open-Meteo para evitar una segunda integración facturable. [Funciones](https://developers.google.com/maps/documentation/weather/overview) · [Facturación](https://developers.google.com/maps/documentation/weather/usage-and-billing) · [Precios globales](https://developers.google.com/maps/billing-and-pricing/pricing) |
| Predicción de mareas | SEMAR publica tablas de estaciones mexicanas, incluida Ciudad del Carmen, en formatos destinados a lectura humana. WorldTides ofrece extremos por coordenadas con clave y créditos, requiere validar la estación o modelo y el datum. El catálogo NOAA sirve para verificar estaciones de su red, sin asumir cobertura transferible a puertos mexicanos. [SEMAR Ciudad del Carmen](https://oceanografia.semar.gob.mx/Templates/grafnum_cdcarmen.html) · [WorldTides](https://www.worldtides.info/apidocs) · [Estaciones NOAA](https://tidesandcurrents.noaa.gov/map/) |
| Cartografía | Flutter Map es el cliente. OSM se usa por defecto en depuración con atribución visible e identificación de aplicación. Las teselas públicas son de capacidad limitada, sin SLA y sin descarga masiva. Para distribución, selecciona un proveedor contratado por el proyecto o teselas autoalojadas, verifica su tarifa y atribución. [Política de teselas de OSM](https://operations.osmfoundation.org/policies/tiles/) |

La comprobación en vivo de Ciudad del Carmen devolvió huso `America/Merida`, 168 horas y siete días de clima, 168 horas de pronóstico marítimo con oleaje y MSL, y dos coincidencias de geocodificación. Son comprobaciones de disponibilidad, no una validación de precisión cerca de costa. Supabase MCP mostró cero puntos publicados y confirmó las FK y RLS en modo de lectura.

## Configuración de distribución

- `GEO_API_BASE` es una URL base HTTPS sin secreto que sirve las rutas `/v1/forecast`, `/v1/marine` y `/v1/search` con el mismo esquema que Open-Meteo. El backend debe aplicar límites y guardar cualquier credencial del proveedor en su entorno. En release sin esta configuración, la app indica que el pronóstico no está disponible.
- `MAP_TILE_URL` es la plantilla HTTPS con `{z}`, `{x}` y `{y}`. `MAP_TILE_ATTRIBUTION` establece el crédito visible del proveedor. En release sin teselas configuradas, el listado y los detalles siguen disponibles.
- `MAREAS_ENDPOINT` es opcional. Configura un endpoint HTTPS con los parámetros `latitude`, `longitude` y `date` (fecha civil de la estación). Debe devolver `{"eventos":[]}` o una lista de objetos con `hora` ISO 8601 incluyendo desplazamiento o Z, `pleamar` booleano y `altura_m` numérica o nula. Selecciona la estación, datum y cobertura en el servidor. Flutter conserva el horario civil y el desplazamiento del proveedor. Usa `MAREAS_FUENTE` para identificar la fuente. Mientras el endpoint no esté configurado se ofrece un enlace al calendario de SEMAR. Guarda la clave de WorldTides solamente en el backend.

## Probar en Android

```powershell
flutter emulators --launch Pixel_8
flutter devices
$clave = Read-Host 'Pega la clave publicable del proyecto'
flutter run -d emulator-5554 --dart-define=SUPABASE_URL=https://higowqchuedxlxlpydso.supabase.co "--dart-define=SUPABASE_PUBLISHABLE_KEY=$clave"
```

Usa el ID que muestre Flutter si difiere. Revisa Clima e Inicio con una ciudad elegida manualmente y compara valores y huso. Repite con ubicación denegada y desactivada. En Mareas selecciona fecha y zona, y verifica la etiqueta de MSL y el acceso a SEMAR. En Mapa prueba gestos, zoom y centrado, busca un punto publicado y abre su marcador para consultar foto y especies. Si el catálogo está vacío, verifica que aún aparezca la cartografía. Apaga la red después de cargar los pronósticos y pulsa Actualizar para comprobar la etiqueta de datos anteriores.

Las pruebas automatizadas simulan HTTP y datos de mapas. La revisión final de permisos del emulador y el contraste visual con Figma requieren una prueba en el dispositivo.

La validación local aprobó las 29 pruebas existentes y ocho nuevas pruebas geográficas. El análisis estático terminó sin incidencias.
