extends Control

## Efecto hover reutilizable: aclara el botón al pasar el ratón.
## Se adjunta a botones de pause_menu, settings_menu y controls_menu.

const HOVER_MULTIPLIER := 1.45

var _base_modulate: Color = Color.WHITE


func _ready() -> void:
	_base_modulate = modulate
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	modulate = Color(
		minf(_base_modulate.r * HOVER_MULTIPLIER, 2.0),
		minf(_base_modulate.g * HOVER_MULTIPLIER, 2.0),
		minf(_base_modulate.b * HOVER_MULTIPLIER, 2.0),
		_base_modulate.a
	)


func _on_mouse_exited() -> void:
	modulate = _base_modulate
