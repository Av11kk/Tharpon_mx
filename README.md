# tharpom_mx

El [sistema visual de Flutter](docs/diseno/sistema_visual/README.md) documenta el tema oscuro, las variantes del logotipo, los componentes compartidos y las referencias de Figma.

## Autenticación de Tharpon MX

Configura Flutter con la URL del proyecto y la clave publicable `sb_publishable_…` del [panel de Supabase](https://supabase.com/dashboard/project/higowqchuedxlxlpydso/settings/api-keys).

```powershell
flutter run --dart-define=SUPABASE_URL=https://higowqchuedxlxlpydso.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=CLAVE_PUBLICABLE_DEL_PROYECTO
```

El SDK restaura la sesión en el dispositivo. Antes de abrir los módulos, la aplicación consulta `perfiles` por el ID de esa sesión y exige un perfil activo con rol `cliente` o `admin`. El formulario de acceso administrativo exige el rol `admin`. Ambos roles autenticados entran en los módulos actuales de Flutter y Perfil muestra el rol validado. El registro público envía únicamente el nombre como metadato y el trigger existente asigna el rol `cliente`. Cuando Supabase requiere confirmar el correo, la aplicación indica que hay que revisar la bandeja de entrada.

### Confirmación por correo y recuperación

- Android e iOS reciben enlaces en `tharponmx://auth/callback`. La URL debe estar autorizada en [Authentication → URL Configuration](https://supabase.com/dashboard/project/higowqchuedxlxlpydso/auth/url-configuration).
- En web, configura una URL de retorno autorizada mediante `--dart-define=SUPABASE_AUTH_REDIRECT_URL=URL_DE_LA_APP_WEB`. Si se omite, Supabase usa la Site URL del proyecto. La recepción nativa del enlace está configurada para Android e iOS.
- Para completar el intercambio PKCE, abre el enlace en la misma instalación o en el mismo navegador que solicitó el correo. Tras aceptar un enlace de recuperación, la aplicación solicita la nueva contraseña y vuelve al acceso después de guardarla.

### Recuperación y permisos después de reiniciar

El almacenamiento de Supabase guarda la sesión junto con el indicador de recuperación. La app registra el indicador antes del intercambio PKCE y lo conserva durante la renovación del token. Al reabrir, una sesión de recuperación pendiente ofrece únicamente el formulario de nueva contraseña o la opción de cancelar y cerrar sesión. Si el proceso termina antes de guardar la sesión devuelta por el servidor y el enlace ya fue consumido, solicita uno nuevo. Al instalar esta versión, las sesiones guardadas con el formato anterior se descartan una vez porque ese formato no identifica el tipo de sesión.

La app consulta `perfiles` al iniciar sesión, al restaurarla, al renovar el token y al volver a primer plano. Si la renovación coincide con la consulta de primer plano, se comparte la comprobación en curso. Las rutas quedan ocultas durante la verificación. Si se confirma el mismo rol, se conserva la navegación. Si se pierde el rol administrador, la cuenta se desactiva o falla la verificación, se descartan las rutas privadas. Una cuenta degradada y todavía activa puede volver a entrar como cliente después de cerrar sesión. RLS aplica los permisos del servidor a las operaciones de datos.

### Política de contraseñas del servidor

Supabase MCP permite revisar PostgreSQL y RLS, pero no expone la configuración alojada de Auth. El archivo `supabase/config.toml` describe el entorno local. Para aplicar la política en el proyecto alojado:

1. Abre [Authentication → Sign In / Providers → Email](https://supabase.com/dashboard/project/higowqchuedxlxlpydso/auth/providers?provider=Email) en el proyecto `higowqchuedxlxlpydso`.
2. En **Minimum password length**, establece **8**. En **Password Requirements**, selecciona la opción que exige **minúsculas, mayúsculas, números y símbolos**.
3. Guarda, vuelve a abrir la configuración y confirma ambos valores. Para las pruebas, usa una mayúscula y minúscula ASCII y un símbolo admitido por Supabase, como `!`. El formulario de Flutter también admite algunos caracteres Unicode que pueden no satisfacer las categorías del servidor.

[Política de contraseñas de Supabase](https://supabase.com/docs/guides/auth/password-security)

### Almacenamiento y enlaces de producción

- En Android e iOS, el registro de sesión y el verificador PKCE todavía usan las preferencias del SDK. Para cifrarlos en reposo, `flutter_secure_storage` puede respaldar ambas interfaces públicas de Supabase Flutter 2.x, `LocalStorage` y `GotrueAsyncStorage`. Usa Android Keystore y Keychain de iOS para la configuración nativa. Conserva sesión e indicador en un único registro, excluye los datos cifrados de copias de respaldo de Android según la configuración del plugin y prueba reinstalación, cierre de sesión y recuperación tras detener el proceso en ambas plataformas. [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- El esquema actual `tharponmx://auth/callback` sirve para pruebas. PKCE vincula el intercambio a la instalación que solicitó el correo, pero un esquema personalizado carece de verificación de propietario por el sistema. Para producción, usa una ruta HTTPS exacta en un dominio controlado por el proyecto. [Supabase y redirecciones](https://supabase.com/docs/guides/auth/redirect-urls)
- En Android, configura un **App Link** con `android:autoVerify="true"`, el host y la ruta exactos. Publica `/.well-known/assetlinks.json` con el ID de la aplicación y la huella SHA-256 del certificado que firma la versión distribuida. [Verificación de App Links](https://developer.android.com/training/app-links/verify-applinks)
- En iOS, habilita **Associated Domains** con `applinks:<dominio>` y publica `/.well-known/apple-app-site-association` con el identificador de equipo, el bundle ID y la ruta del callback. Autoriza la URL HTTPS exacta en Supabase y úsala también en el código Flutter. Verifica confirmación y recuperación con una compilación firmada antes de retirar el esquema de pruebas del destino de producción. [Associated Domains de Apple](https://developer.apple.com/documentation/xcode/supporting-associated-domains)

### Verificación

```powershell
flutter analyze
flutter test
```

Las pruebas cubren la persistencia del indicador de recuperación, su restauración, la degradación de rol al renovar el token, la desactivación de cuenta al volver al primer plano y el cierre de sesión. Para la prueba real, abre un enlace de recuperación en el emulador, detén la app cuando aparezca el formulario y vuelve a abrirla sin borrar los datos. Debe volver al formulario y mantener cerrados los módulos hasta guardar la nueva contraseña y autenticarse otra vez.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
