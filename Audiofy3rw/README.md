# audiofy 3rw – proyecto base (Xcode)

Esto es código fuente, no una app instalable: un .ipa requiere compilar y firmar con tu cuenta de Apple Developer.

## Opción A – XcodeGen (1 minuto)
1. brew install xcodegen
2. En esta carpeta: xcodegen generate
3. Abre Audiofy3rw.xcodeproj, elige tu Team en Signing & Capabilities y ejecuta en tu iPhone.

## Opción B – Manual
1. Xcode → New Project → iOS App (SwiftUI), nombre Audiofy3rw, iOS 17+.
2. Borra ContentView.swift y el App file generados; arrastra las carpetas App, Core, Features y CarPlay al proyecto.
3. Signing & Capabilities → Background Modes → Audio, AirPlay, and Picture in Picture.
4. Copia en el Info.plist del proyecto la clave UIApplicationSceneManifest de Audiofy3rw/Info.plist.

## CarPlay
- Solicita el entitlement com.apple.developer.carplay-audio a Apple. Hasta que lo concedan, NO lo actives: la firma fallará.
- Después: descomenta CODE_SIGN_ENTITLEMENTS en project.yml (o añade el archivo .entitlements en Xcode).
- Prueba en simulador: I/O → External Displays → CarPlay.

## Pendiente
- Cargar un catálogo con derechos en MusicView y CarPlaySceneDelegate (están vacíos).
- Código no compilado en Xcode: puede requerir ajustes menores según la versión del SDK.
