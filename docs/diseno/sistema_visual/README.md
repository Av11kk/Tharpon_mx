# Sistema visual de Tharpon MX

Flutter aplica `TemaApp.oscuro` desde `MaterialApp`. El tema define Inter, jerarquía de texto, superficies, controles Material, iconos y contraste de la barra del sistema. `ColoresApp` contiene la paleta y `MedidasApp` centraliza geometría. La tipografía Inter Regular y Bold se distribuye localmente en `assets/fonts/` con su licencia SIL OFL. [Inter 4.1](https://github.com/rsms/inter/releases/tag/v4.1)

| Uso | Color |
| --- | --- |
| Fondo principal | `#2A2A2A` |
| Tarjetas | `#191919` |
| Superficies secundarias | `#262626` |
| Selección | `#3A3A3A` |
| Texto principal y logotipo claro | `#F5F5F5` |
| Texto secundario | `#BEBEBE` |
| Etiquetas e iconos | `#C3C3C3` |
| Panel de navegación y avisos | `#1E1E1E` |
| Opciones del menú | `#242424` |
| Acción secundaria y de cierre | `#303030` |
| Acción principal | `#E0E0E0` |
| Éxito y requisitos cumplidos | `#67D49B` |
| Errores y discrepancias | `#EF8585` |

## Componentes

- `controles_app.dart` ofrece `BotonPrincipal` con icono opcional, `BotonSecundario`, `CampoApp` con configuración para texto, correo y contraseña, `TarjetaApp`, `EncabezadoApp` y el diálogo `confirmarAccion`. Usa `IconButton` con `tooltip` para acciones de icono que no tienen texto visible. Conserva los estados de interacción de Material.
- `estado_operacion.dart` ofrece `EstadoOperacion` para mensajes breves y carga, `NotificacionApp` para avisos de formulario, `PanelEstadoApp` para estados ilustrados e `IndicadorRequisito` para validación. El color acompaña al icono y al estado semántico. Las ilustraciones exportadas de Figma viven en `assets/estados/`. Los tres iconos de registro viven en `assets/autenticacion/`.
- `LogoTharpon`, en `lib/compartido/widgets/logo_tarpon.dart`, renderiza `assets/logos/logo_tarpon.png`. `VarianteLogo.original` conserva el azul del activo. `VarianteLogo.fondoOscuro` usa la máscara alfa original con `#F5F5F5`. `FormatoLogo.completo` muestra la marca TARPON MX y `FormatoLogo.compacto` recorta el símbolo del mismo PNG. Ambas variantes se crean al renderizar. El archivo fuente se conserva intacto.

```dart
const LogoTharpon(
  ancho: 104,
  alto: 48,
  alineacion: Alignment.centerLeft,
  variante: VarianteLogo.fondoOscuro,
  formato: FormatoLogo.compacto,
)
```

## Autenticación y movimiento

Acceso, registro, solicitud de recuperación y nueva contraseña usan el mismo marco adaptable, con un máximo de 390 puntos lógicos, desplazamiento con teclado y un solo logotipo en la cabecera. En registro y restablecimiento, los requisitos y la coincidencia se actualizan mientras se escribe. El botón de registro se habilita al completar el formulario válido. Los avisos de confirmación mantienen las respuestas genéricas del servicio de autenticación.

`MovimientoApp` concentra las duraciones y curvas. Flutter implementa aparición con opacidad y desplazamiento de 250 ms, transiciones de estados, estilo de interacción de botones de 120 ms, diálogo de 220 ms y ajustes temporales del menú existente de 280 ms. Los componentes propios muestran estados estáticos cuando el sistema solicita movimiento reducido. Figma describe nado de 2.8 s y confirmación de 800 ms. La biblioteca consultada no contiene fotogramas clave exportables para esos gestos. El splash, el nado de marca y las animaciones completas quedan para una fase posterior.

Referencias consultadas en Figma:

- [Acceso](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=1-2), [registro](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=1-188), [requisitos](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=21-66), [discrepancia](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=21-189), [confirmación de contraseña](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=21-230).
- [Recuperación](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=44-130), [aviso de correo](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=44-141) y [estados](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=53-135). El formulario de nueva contraseña reutiliza estos patrones y los campos de registro.
- [Menú](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=5-94), [biblioteca de movimiento](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=50-190) e [identidad de administración](https://www.figma.com/design/wAdU0cD48cLYYkIdhU04nQ?node-id=1-2).

## Validación

`flutter pub get` resolvió los recursos. `flutter analyze` terminó sin incidencias. `flutter test` pasó 19 pruebas, incluidas las 15 existentes. La cobertura incluye el PNG decodificado, las variantes, el tema, el movimiento reducido, validación dinámica y una ventana de 320 × 560 con teclado simulado. Para revisar Android, ejecuta la app con el comando de la raíz y comprueba el contraste de la barra del sistema, los formularios al girar el dispositivo y la navegación mediante teclado.

## Fase 2 · Bienvenida, Inicio y navegación

La página oficial contiene Inicio, encabezado, menú y diálogo de cierre, y carece de un fotograma independiente de Bienvenida. Flutter muestra el logotipo claro centrado durante la inicialización real y entrega el resultado al mismo `ControlAcceso`. Android usa el fondo `#2A2A2A` antes del primer fotograma. El widget de Bienvenida es el punto de integración para el futuro splash animado.

Inicio usa las tarjetas del diseño para Clima, Mareas, Equipo y Mapa. Clima conserva Open-Meteo y permite actualizar deslizando hacia abajo. Mareas todavía carece de una fuente conectada. Equipo y Promociones conservan el acceso a su sección, cuyo catálogo sigue pendiente. El mapa de Inicio es una **Vista de ejemplo**, con los marcadores de Figma, y Consejos aún usa datos de ejemplo. Las categorías de equipo llevan a Equipo y quedan preparadas para los filtros cuando el catálogo esté disponible.

`EncabezadoNavegacion` concentra menú, identidad y perfil. El panel lateral se abre sobre el módulo actual, conserva una lista desplazable y aplica la selección dentro del mismo `IndexedStack`. Se puede cerrar con su botón, Atrás o el área exterior. El menú y Perfil usan `confirmarCierreSesion` con el servicio ya existente. El flujo de autenticación descarta el navegador privado al cerrar sesión.

Flutter resolvió los recursos, el análisis terminó sin incidencias y las 23 pruebas pasaron. Las pruebas nuevas cubren Bienvenida, navegación y Atrás, cancelación y confirmación del cierre a 320 × 500 y el acceso a Promociones.

Referencias de Figma consultadas mediante MCP

- [Inicio](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=1-33) y [encabezado](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=3-3).
- [Menú lateral](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=5-94) y [confirmación de cierre](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=38-136).
- [Movimiento](https://www.figma.com/design/LGkZ9KTPUBlnEzdci29niD?node-id=50-190). El panel usa el deslizamiento de 280 ms y lo omite con movimiento reducido. La revisión de los estados de carga de Android, el splash, los skeletons y las animaciones del sábalo quedan para la fase de pulido.
