# Shadow Minions — Game Off 2026

Proyecto de desarrollo de videojuegos del equipo **Shadow Minions** para **Game Off 2026**, desarrollado con Godot y preparado para publicarse como juego web en **itch.io**.

## Descripción

> Pendiente de completar: describe aquí la idea principal del juego, su género, ambientación y mecánicas principales.

## Plataforma objetivo

- **Plataforma principal:** navegador web.
- **Publicación prevista:** itch.io, con una versión HTML5/Web que se pueda jugar directamente en la página del juego.
- **Motor:** Godot.
- **Equipo:** Shadow Minions.

El objetivo es que los jugadores puedan iniciar y jugar la versión web sin instalar el juego. Las versiones descargables para escritorio podrán añadirse más adelante si el equipo lo decide.



- Godot Engine: v4.7.2
- Plantillas de exportación de Godot correspondientes a esa misma versión.
- Un navegador moderno para probar la exportación web.

## Abrir el proyecto en Godot

1. Clona este repositorio:
   ```bash
   git clone https://github.com/IES-Rafael-Alberti/gameoff2026-shadow-minions.git
   ```
2. Abre Godot.
3. Selecciona **Importar** y elige el archivo `project.godot`.
4. Ejecuta el proyecto con **F6** para la escena actual o **F5** para la escena principal.

## Exportar para itch.io

1. Confirma que el proyecto funciona correctamente en el editor.
2. Instala las plantillas de exportación correspondientes a la versión de Godot del proyecto.
3. En **Proyecto → Exportar**, añade un preset **Web** y configura la escena principal.
4. Exporta el proyecto a una carpeta dedicada a la versión web.
5. Sigue las instrucciones actuales de itch.io para publicar un juego HTML5/Web: sube los archivos exportados respetando la estructura generada por Godot y configura el proyecto para ejecutarse en el navegador.
6. Prueba la versión publicada desde la página de itch.io, no solo desde el editor o una prueba local.

> **Importante:** las opciones de exportación y los requisitos del navegador dependen de la versión de Godot. Comprueba la documentación de esa versión antes de publicar. No des por hecho que una exportación funciona en todos los navegadores o dispositivos sin probarla.

## Compatibilidad y pruebas web

Antes de publicar una versión, comprueba:

- Que el juego carga correctamente desde itch.io.
- Que el menú, las escenas y los recursos se cargan sin errores.
- Que los controles funcionan con teclado y ratón; documenta otros métodos si los hay.
- Que el audio se inicia correctamente después de la interacción del jugador cuando el navegador lo requiera.
- Que el rendimiento y los tiempos de carga son aceptables.
- Que la resolución se adapta razonablemente al área de juego de itch.io.
- Que no hay errores de rutas, recursos ausentes ni funciones incompatibles con la exportación web.

## Controles

Pendiente de documentar cuando se definan los controles del juego.

## Equipo

**Shadow Minions**

Añade aquí los nombres y perfiles de GitHub de los integrantes.

## Seguimiento del desarrollo

Las tareas, errores, pruebas de navegador y mejoras se organizarán en el GitHub Project asociado al repositorio.

## Licencia

Este proyecto se distribuye bajo la licencia MIT. Consulta el archivo [`LICENSE`](LICENSE).
