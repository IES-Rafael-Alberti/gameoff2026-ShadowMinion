# Texturas para la mansión

Texturas de 512×512 px pensadas para una mansión de finales del siglo XIX / principios del XX.

| Archivo | Uso |
| --- | --- |
| `Muro de roca/rock_wall_antique.png` | Paredes exteriores: muro de piedra irregular con mortero, grietas y musgo. Tileable en ambos ejes. |
| `Papel de pared/wallpaper_vintage_tileable.png` | Papel rojo oscuro vintage (franjas y motivos damasco dorados/burdeos). Tileable en ambos ejes. |
| `Tablas/wood_wainscot_tileable.png` | Revestimiento de madera tipo wainscot: paneles, montantes y rieles. Tileable en ambos ejes. |
| `Tablas/wood_lower_with_rail.png` | La parte de madera de la pared combinada (512×216), con el riel superior incluido. Tileable en horizontal. |
| `Paredes interiores/interior_wall_wallpaper_wood.png` | Pared interior completa: papel arriba, riel de madera y paneles abajo. Tileable en horizontal; no repetir en vertical. |
| `Tablas/wood_planks_antique.png` | Tablones de madera envejecidos con juntas y clavos. Tileable en ambos ejes. |
| `Tablas/wood_seamless.png` | La textura de madera original limpiada y hecha tileable, sin tablones añadidos. Útil para muebles o vigas. |
| `Puertas/antique_door.png` | Puerta antigua de tres paneles con pomo, cerradura y bisagras, en el tono de la madera de la mansión (512×1024). |
| `Puertas/antique_door_plain.png` | La misma puerta sin herrajes, para añadir los tuyos propios. |
| `Puertas/door_from_wood_image_only.png` | Puerta hecha únicamente con la imagen de madera adjunta, repetida con espejo (sin herrajes ni texturas extra). |

## Pared interior recomendada

Para una pared alta, usa **dos texturas separadas** y colócalas una encima de otra:

- `Papel de pared/wallpaper_vintage_tileable.png` en la parte superior.
- `Tablas/wood_wainscot_tileable.png` en la parte inferior (alrededor del 40% de la altura).

Si solo necesitas un segmento de pared de 512×512, usa directamente `Paredes interiores/interior_wall_wallpaper_wood.png`.

## Uso en Godot 4

1. Importa los PNG normalmente; Godot genera los archivos `.import` automáticamente.
2. Para repetir la textura en una superficie grande, usa una de estas opciones:
   - **TileMap/TileSet**: crea un tile de 512×512 y pinta la pared.
   - **Sprite2D / TextureRect** con un `ShaderMaterial` que escale `UV` (por ejemplo, `uv * repetición`).
   - En el importador, activa **Repeat** si vas a muestrear la textura fuera de 0–1.
3. Ajusta el filtrado a `Nearest` si quieres un look pixel-art, o `Linear` para un acabado más suave.

Las texturas tileables están corregidas en los bordes: la columna 0 coincide con la 511 y la fila 0 con la 511, por lo que no se ve corte al repetirlas.
