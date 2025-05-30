<h1 align="center">CODE HACKER</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Versión-1.0.0-brightgreen" alt="Versión">
  <img src="https://img.shields.io/badge/Flutter-3.19.0-blue" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.3.0-blue" alt="Dart">
  <img src="https://img.shields.io/badge/Licencia-MIT-orange" alt="Licencia">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Plataforma-Android%20%7C%20iOS%20%7C%20Web-lightgrey" alt="Plataformas">
</p>

<p align="center">
                            
```                                                
                       ██████╗ ██████╗ ██████╗ ███████╗    ██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗ 
                      ██╔════╝██╔═══██╗██╔══██╗██╔════╝    ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
                      ██║     ██║   ██║██║  ██║█████╗      ███████║███████║██║     █████╔╝ █████╗  ██████╔╝
                      ██║     ██║   ██║██║  ██║██╔══╝      ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
                      ╚██████╗╚██████╔╝██████╔╝███████╗    ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║
                       ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                                                                     
```
</p>

<p align="center">
Un juego de hacking estilo retro desarrollado con Flutter que pone a prueba tus habilidades cognitivas y reflejos.
</p>

## 🔍 Descripción

**Code Hacker** es una aplicación lúdica de temática cyberpunk que simula las actividades de un hacker a través de minijuegos que desafían las capacidades cognitivas del usuario. El jugador debe superar tres niveles de seguridad para romper un firewall ficticio, cada uno representando diferentes aspectos de las habilidades requeridas en el ámbito de la seguridad informática:

1. **Romper Firewall**: Un desafío de velocidad y precisión donde el usuario debe interactuar rápidamente con la interfaz para progresar antes de agotar el tiempo.
   
2. **Secuencia de Código**: Ejercicio de memoria y reconocimiento de patrones donde el jugador debe reproducir secuencias de colores cada vez más complejas.
   
3. **Descifrar Código**: Prueba de razonamiento lógico-matemático que requiere resolver ecuaciones en tiempo limitado.

4. **Acceso al Sistema**: Desafío final donde el jugador debe demostrar su agilidad para descifrar un código de acceso mediante reconocimiento de patrones y lógica.
   
Adicionalmente, el juego incluye un modo desafío especial denominado **"Black Hat"**, que incrementa significativamente la dificultad y complejidad de los retos presentados.

## 📸 Capturas de Pantalla

<!-- Aquí puedes incluir capturas de pantalla del juego -->
<p align="center">
  <!-- <img src="assets/screenshots/screenshot1.png" width="200" alt="Pantalla de inicio">
  <img src="assets/screenshots/screenshot2.png" width="200" alt="Nivel 1">
  <img src="assets/screenshots/screenshot3.png" width="200" alt="Nivel 2"> -->
  <i>Capturas de pantalla próximamente</i>
</p>

## ✨ Características

- **Diseño Inmersivo**: Interfaz con estética retro-futurista inspirada en interfaces de hacking de películas y videojuegos clásicos.
- **Progresión de Dificultad**: Sistema adaptativo que incrementa el desafío en base al rendimiento del jugador.
- **Efectos Audiovisuales**: Retroalimentación visual y sonora que mejora la experiencia de usuario.
- **Sistema de Puntuación**: Seguimiento detallado del rendimiento con tabla de clasificación local.
- **Modo Pesadilla**: Desafío adicional para jugadores experimentados con mecánicas alteradas.
- **Easter Eggs**: Contenido oculto que premia la exploración y el pensamiento lateral.
- **Accesibilidad**: Diseño inclusivo con opciones adaptables para diferentes perfiles de usuario.

## 🏗️ Arquitectura

El proyecto implementa una arquitectura limpia basada en el patrón BLoC (Business Logic Component) que separa claramente:

- **Capa de Presentación**: Widgets de Flutter para la interfaz de usuario.
- **Capa de Lógica de Negocio**: Gestores de estado y controladores de juego.
- **Capa de Datos**: Servicios de persistencia y acceso a recursos locales.

Esta separación facilita el mantenimiento, las pruebas unitarias y la escalabilidad del código.

## 🚀 Instalación

### Requisitos Previos

- Flutter SDK (versión 3.0.0 o superior)
- Dart SDK (versión 2.17.0 o superior)
- Git
- Android Studio / VS Code (con extensiones de Flutter y Dart)
- Dispositivo físico o emulador con Android/iOS

### Pasos

1. Clone el repositorio:
   ```bash
   git clone https://github.com/Johnson1255/CodeHacker.git
   cd CodeHacker
   ```

2. Instale las dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecute la aplicación:
   ```bash
   flutter run
   ```

Para generar un APK de lanzamiento:
```bash
flutter build apk --release
```

## 💻 Uso

1. Inicie la aplicación desde el menú principal.
2. Complete cada nivel siguiendo las instrucciones en pantalla.
3. Intente obtener la mayor puntuación posible.
4. Desbloquee el modo "Black Hat" para experimentar desafíos adicionales.

## 🔧 Tecnologías

- **Flutter**: Framework de UI multiplataforma.
- **Dart**: Lenguaje de programación.
- **Shared Preferences**: Almacenamiento persistente de configuraciones y puntuaciones.
- **Audio Players**: Biblioteca para efectos de sonido y música.
- **Animate_do**: Animaciones fluidas de la interfaz.
- **Provider**: Gestión de estado para componentes reactivos.

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                  # Punto de entrada
├── app.dart                   # Configuración de la aplicación
├── config/                    # Configuración y constantes
├── models/                    # Modelos de datos
├── screens/                   # Pantallas de la UI
│   ├── home_screen.dart       # Pantalla principal
│   ├── game_screen.dart       # Pantalla de juego
│   ├── nightmare.dart         # Modo Black Hat
│   └── points_screen.dart     # Pantalla de puntuación
├── services/                  # Servicios y API
│   ├── audio_service.dart     # Gestión de audio
│   └── storage_service.dart   # Persistencia de datos
├── widgets/                   # Componentes reutilizables
└── utils/                     # Utilidades y helpers
```

## 🗺️ Roadmap

- [ ] Implementación de multijugador online
- [ ] Nuevos niveles temáticos
- [ ] Sistema de logros y recompensas
- [ ] Soporte para más idiomas
- [ ] Versión web completa

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - vea el archivo [LICENSE](LICENSE) para más detalles.

## 🙏 Créditos

Desarrollado por Senlin (Johnson1255) como proyecto académico

---

<p align="center">
  Desarrollado con ❤️ por Senlin
</p>
