# Página de itch.io — Shadow Minions / Manifest

Diseño de **abismo lovecraftiano**: azules casi negros, verde salobre, dorado viejo de
tomo antiguo, tipografía serif y ondas concéntricas en lugar de cuadrículas. La estructura
es la que ya te gustó; solo ha cambiado el registro visual. Incluye **placeholders**
marcados como `[[ ... ]]` para rellenar cuando tengas el juego y las capturas.

> Nota: la URL que pasaste (`https://hadowminions.itch.io/manifest`) devuelve 404 desde fuera
> (supongo que el proyecto sigue en borrador), así que no he podido copiar tus textos actuales.
> He conservado lo que sí aparece en el README del repo: **Shadow Minions**, **Game Off 2026**,
> **Godot**, versión **web**, nombres del equipo y licencia **MIT**. Si el título definitivo no es
> *Manifest*, cámbialo en `description.html` y `preview.html`.

## Archivos

| Archivo | Para qué sirve |
|---|---|
| `custom.css` | El CSS que se pega en el editor de CSS de itch.io (cuando te den acceso). |
| `description.html` | Descripción HTML pensada para usarse **con** `custom.css`. |
| `preview.html` | Maqueta local de la versión **con** CSS. |
| **`description-no-css.html`** | **Versión de emergencia: funciona sin CSS**, solo con el tema + estilos en línea. |
| **`preview-no-css.html`** | Vista previa local de la versión sin CSS. |
| `INSTRUCCIONES.md` | Este archivo. |

---

## 1. Verlo antes de tocar itch.io

Abre `itchio/preview.html` (versión con CSS) o `itchio/preview-no-css.html`
(versión sin CSS, la que puedes usar ya mismo). Ambas son simulaciones locales de la
columna de itch.io con los colores actuales del tema.

---

## 2. Editor de tema de itch.io (sin CSS, haz esto ya)

En la página del juego: **Edit Theme** y ajusta:

- **Layout → Screenshots: Sidebar**. Importante: con juegos HTML5 itch.io pone
  *Auto/Hidden* y esconde las capturas; elige *Sidebar* para que salgan a la derecha.
- **Colors:**
  - BG: `#040a10`
  - BG2: `#0a1620` (sube un poco la opacidad en *More options → BG2 Alpha*, ~85-95%)
  - Text: `#e6e7dc`
  - Link: `#8fb8a8`
  - Buttons: `#8fb8a8`
  - Headers: `#d8c49a`
  - Border: `#1f3739`
- **Text → Font:** una serif de libro antiguo (*Georgia*, *Iowan Old Style* o *Lora*);
  tamaño 15-16 px. Así se mantiene el tono lovecraftiano incluso antes del CSS.
- **Images:** sube un **banner** con el título del juego (el banner sustituye al título
  en la página) y una **portada** para que el juego destaque en los listados.
- Si tienes tráiler, añade el enlace de YouTube/Vimeo: aparece sobre las capturas.

### Texto corto de la descripción (Metadata)

Pon algo así (sustituye el placeholder):

> [[ GANCHO INQUIETANTE EN UNA FRASE ]] — Una señal desde el abismo. Shadow Minions para Game Off 2026. Jugable en el navegador.

### Tags sugeridos

`game-off-2026`, `godot`, `web`, `singleplayer`, `cosmic-horror`, `lovecraftian`,
`deep-sea`, `ocean`, `3d`, `[[ idioma: spanish / english ]]`.

Añade también el enlace al repositorio de GitHub en **External links → Homepage**:
`https://github.com/IES-Rafael-Alberti/gameoff2026-shadow-minions`

---

## 3. Descripción en HTML

1. En **Edit game → Description**, pulsa el botón **`<>`** para pasar a modo HTML.
2. Borra lo que haya y pega todo el contenido de `description.html`.
   (El comentario del principio no hace daño, pero puedes quitarlo.)
3. Busca `[[` y reemplaza cada placeholder por el texto real.
4. **Importante:** una vez en modo HTML no vuelvas al editor visual: puede reescribir
   el marcado y quitar las clases `custom-*`.

Si quieres cambiar algo del texto, edita el HTML directamente; las clases `custom-*`
son las que aplican el estilo del CSS.

---

## 3b. Versión SIN CSS (para entregar el lunes)

Si no te activan el CSS a tiempo, usa **`description-no-css.html`** en lugar de
`description.html`. Da el mismo contenido y la misma paleta, pero el aspecto se consigue
con **estilos en línea** dentro del propio HTML, así que itch.io lo respeta sin editor CSS.

Haz esto:

1. **Edit game → Description** → botón **`<>`** (modo HTML). Ojo: otra vez, no vuelvas
   al editor visual.
2. **Ctrl+A** y pega todo `itchio/description-no-css.html`.
3. Sustituye los `[[ ... ]]` por el texto real.
4. **Save & view page**. Comprueba con `Ctrl+U` que aparece `border-bottom:1px solid #223d54`
   (si aparece, los estilos en línea se han conservado).
5. Deja el tema como está: no cambies los colores, porque los estilos en línea usan
   esos mismos valores (`#040a10`, `#0a1620`, `#e6e7dc`, `#8fb8a8`, `#d8c49a`, `#223d54`).

> Esta versión no tiene ondas ni marco de juego, pero sí tarjetas, separadores,
> numeración romana, botones y lista de equipo con el mismo aire lovecraftiano.
> Cuando llegue el CSS, puedes volver a `description.html` sin perder nada.

---

## 4. CSS personalizado

itch.io solo habilita el editor de CSS si lo pides: **https://itch.io/support**
(indica *"I'd like to request custom CSS access for my project page"* y que solo
modificarás el aspecto de tu página, sin tocar la interfaz de itch.io).

Cuando te lo concedan:

1. **Edit game → Customize → CSS** (o *Edit Theme → Custom CSS*).
2. Pega todo `custom.css`.
3. Guarda y abre la página **sin sesión iniciada** (o en incógnito) para comprobarlo.
4. Prueba también en el móvil / reduciendo la ventana: el CSS ya incluye dos media queries.

El CSS está todo dentro de `#wrapper` a propósito: así no afecta a la cabecera ni a
los botones globales de itch.io.

### Si aún no tienes acceso al CSS

Con los colores del paso 2 y `description-no-css.html` la página ya está lista para
entregar. El CSS añadiría las ondas concéntricas y el marco del juego, pero **no es
necesario para el lunes**. Puedes pedir acceso igualmente y migrar después.

### Señal de que el HTML se pegó en el editor visual

Si en la página ves cosas como **«ISobre el juego»**, **«IIMecánicas»** o los
placeholders `[[ ... ]]` como texto normal sin estilo, es que itch.io limpió las
etiquetas. Vuelve a **Description**, pulsa **`<>`**, selecciona todo (**Ctrl+A**) y
pega de nuevo el archivo que estés usando (`description.html` o `description-no-css.html`).
Después no vuelvas al editor visual.

---

## 5. Checklist antes de publicar

- [ ] Sustituidos todos los `[[ ... ]]` (busca `[[` en el HTML).
- [ ] Título definitivo decidido (¿*Manifest* u otro nombre?).
- [ ] Banner y portada subidos.
- [ ] 3-5 capturas subidas y layout en **Sidebar**.
- [ ] Descripción con el texto real de mecánicas y controles.
- [ ] Botón "Jugar en el navegador" apuntando a la URL correcta (en `description.html`,
      ahora mismo es `href="#"`).
- [ ] HTML5 exportado desde Godot con `index.html` en la raíz del ZIP.
- [ ] Embed configurado: *Embeddable / play in browser*, **Click to play** activado,
      botón de pantalla completa activado, tamaño inicial `960 × 540` (o el que use tu exportación).
- [ ] Probado en incógnito, en móvil y con el audio después del primer clic.
- [ ] Estado del proyecto: **In development** mientras estés en Game Off 2026.

---

## 6. Colores

Si quieres cambiar la paleta, edita solo estas variables al principio de `custom.css`:

```css
--sm-bg:        #040a10;  /* abismo */
--sm-panel:     #0a1620;  /* tarjeta */
--sm-brine:     #8fb8a8;  /* verde salobre: acento principal */
--sm-gold:      #c0a166;  /* dorado viejo: acento secundario */
--sm-parchment: #d8c49a;  /* pergamino: placeholders y avisos */
--sm-text:      #e6e7dc;  /* hueso */
--sm-muted:     #96a79f;  /* niebla salina */
```

---

Referencias oficiales: [Designing your page](https://itch.io/docs/creators/design) ·
[Custom CSS guide](https://itch.io/docs/creators/css-guide) ·
[HTML5 games](https://itch.io/docs/creators/html5)
