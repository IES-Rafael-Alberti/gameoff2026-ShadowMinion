extends Control

## Medidor de audio dibujado con los huesos de "audio -+.png".
## Las 10 barras se iluminan según el volumen general (promedio de Music y SFX).
## Los iconos - y + de la misma imagen cambian ambos volúmenes de 10 en 10.

signal volume_changed

const SOURCE_TEXTURE := "res://Assets/Menu/ResumeMenu/audio -+.png"
const ORIGIN := Vector2i(781, 310)
## El slider se estira casi todo el ancho de la ventana, pero se mantiene fino.
## El ancho se mantiene casi al máximo; el alto se reduce por separado.
const SCALE_X := 0.78
const SCALE_Y := 0.4
const STEP := 0.1

const MINUS_RECT := Rect2i(781, 310, 43, 108)
const PLUS_RECT := Rect2i(1461, 310, 54, 108)

const LIT_COLOR := Color(1.5, 1.4, 1.15, 1.0)
const DIM_COLOR := Color(0.32, 0.30, 0.26, 0.55)
const ICON_COLOR := Color(1.2, 1.1, 0.9, 1.0)
const ICON_HOVER_COLOR := Color(1.9, 1.75, 1.4, 1.0)

var _bone_rects: Array[Rect2i] = [
	Rect2i(874, 310, 39, 108),
	Rect2i(929, 310, 40, 108),
	Rect2i(985, 310, 40, 108),
	Rect2i(1040, 310, 40, 108),
	Rect2i(1096, 310, 40, 108),
	Rect2i(1152, 310, 39, 108),
	Rect2i(1207, 310, 40, 108),
	Rect2i(1263, 310, 40, 108),
	Rect2i(1318, 310, 40, 108),
	Rect2i(1374, 310, 40, 108),
]

var _bones: Array[TextureRect] = []


func _ready() -> void:
	var source := load(SOURCE_TEXTURE) as Texture2D
	if source == null:
		push_error("No se pudo cargar %s" % SOURCE_TEXTURE)
		return
	var image := source.get_image()
	if image == null:
		push_error("No se pudo leer la imagen de %s" % SOURCE_TEXTURE)
		return

	custom_minimum_size = Vector2(739.0 * SCALE_X, 108.0 * SCALE_Y)

	_add_button(image, MINUS_RECT, "_on_minus_pressed")
	for rect in _bone_rects:
		_bones.append(_add_bone(image, rect))
	_add_button(image, PLUS_RECT, "_on_plus_pressed")

	update()


func _make_solid_texture(region: Image) -> ImageTexture:
	## El PNG trae los huesos semitransparentes; subimos el alpha a 255 para
	## poder encenderlos/apagarlos con modulate sin perder la forma original.
	var image := Image.new()
	image.copy_from(region)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a > 0.0:
				image.set_pixel(x, y, Color(pixel.r, pixel.g, pixel.b, 1.0))
	return ImageTexture.create_from_image(image)


func _place(control: Control, rect: Rect2i) -> void:
	control.position = Vector2(
		float(rect.position.x - ORIGIN.x) * SCALE_X,
		float(rect.position.y - ORIGIN.y) * SCALE_Y
	)
	control.size = Vector2(
		float(rect.size.x) * SCALE_X,
		float(rect.size.y) * SCALE_Y
	)


func _add_bone(image: Image, rect: Rect2i) -> TextureRect:
	var bone := TextureRect.new()
	bone.texture = _make_solid_texture(image.get_region(rect))
	_place(bone, rect)
	bone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bone.modulate = DIM_COLOR
	add_child(bone)
	return bone


func _add_button(image: Image, rect: Rect2i, callback: String) -> void:
	var button := TextureButton.new()
	button.texture_normal = _make_solid_texture(image.get_region(rect))
	_place(button, rect)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.modulate = ICON_COLOR
	button.pressed.connect(Callable(self, callback))
	button.mouse_entered.connect(_on_icon_hovered.bind(button))
	button.mouse_exited.connect(_on_icon_unhovered.bind(button))
	add_child(button)


func update() -> void:
	if _bones.is_empty():
		return

	# Si prefieres que siga solo a la música, cambia esta línea por
	# SettingsManager.music_volume.
	var volume := (SettingsManager.music_volume + SettingsManager.sfx_volume) * 0.5
	var lit_count := roundi(clampf(volume, 0.0, 1.0) * float(_bones.size()))
	for i in range(_bones.size()):
		_bones[i].modulate = LIT_COLOR if i < lit_count else DIM_COLOR


func _change_volume(delta: float) -> void:
	SettingsManager.music_volume = clampf(SettingsManager.music_volume + delta, 0.0, 1.0)
	SettingsManager.sfx_volume = clampf(SettingsManager.sfx_volume + delta, 0.0, 1.0)
	SettingsManager.apply()
	update()
	volume_changed.emit()


func _on_minus_pressed() -> void:
	_change_volume(-STEP)


func _on_plus_pressed() -> void:
	_change_volume(STEP)


func _on_icon_hovered(button: TextureButton) -> void:
	button.modulate = ICON_HOVER_COLOR


func _on_icon_unhovered(button: TextureButton) -> void:
	button.modulate = ICON_COLOR
