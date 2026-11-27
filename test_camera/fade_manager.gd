extends CanvasLayer

## Autoload: cortina negra reutilizable para muertes, checkpoints y cambios de nivel.

signal faded_out
signal faded_in

const DEFAULT_DURATION := 0.5

var _overlay: ColorRect
var _busy := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100

	_overlay = ColorRect.new()
	_overlay.name = "FadeOverlay"
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)


func fade_out(duration: float = DEFAULT_DURATION) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, duration).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	faded_out.emit()


func fade_in(duration: float = DEFAULT_DURATION) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", 0.0, duration).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	faded_in.emit()


## Hace fade out, ejecuta la acción (recargar/scene change) y hace fade in
## cuando la nueva escena ya está en pantalla.
func transition(action: Callable, duration: float = DEFAULT_DURATION) -> void:
	if _busy:
		return
	_busy = true

	await fade_out(duration)
	action.call()

	# change_scene_to_file / reload_current_scene se aplican al final del frame.
	await get_tree().process_frame
	await get_tree().process_frame

	# La escena recién cargada vuelve con sus materiales originales: reaplicamos el ocultado.
	GlobalScript.hide_esconder_gancho_feo()

	await fade_in(duration)
	_busy = false
