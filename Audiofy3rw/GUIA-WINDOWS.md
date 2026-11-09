# Compilar e instalar desde Windows

## 1. Subir el proyecto a GitHub
1. Crea una cuenta en github.com y un repositorio nuevo (privado vale), rama principal: main.
2. Sube TODO el contenido de esta carpeta, incluida la carpeta oculta .github (en la web: Add file -> Upload files, arrastra las carpetas).
3. Verifica que existe la ruta .github/workflows/build.yml en el repositorio.

## 2. Compilar
1. Pestaña Actions -> "Build IPA sin firmar" -> Run workflow.
2. Espera unos 5-10 minutos. Si sale en verde, abre la ejecución y descarga el artefacto Audiofy3rw-ipa (es un zip con el .ipa dentro).
3. Si sale en rojo, abre el paso "Compilar (sin firma)" y copia las líneas que contengan "error:". Pásamelas y lo corregimos.

## 3. Instalar con Sideloadly
1. Instala iTunes e iCloud desde apple.com (NO las versiones de Microsoft Store).
2. Instala Sideloadly (sideloadly.io). Conecta el iPhone por cable y acepta "Confiar en este ordenador".
3. En el iPhone: Ajustes -> Privacidad y seguridad -> Modo desarrollador -> activar y reiniciar.
4. Arrastra el .ipa a Sideloadly, escribe tu Apple ID y pulsa Start.
5. En el iPhone: Ajustes -> General -> VPN y gestión de dispositivos -> confía en tu Apple ID.

## Límites (Apple ID gratuito)
- La app caduca a los 7 días: hay que reinstalarla.
- Máximo 3 apps instaladas así a la vez.
- CarPlay no funciona: requiere el entitlement aprobado y una cuenta de pago.
