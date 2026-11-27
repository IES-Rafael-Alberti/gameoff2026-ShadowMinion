extends Control

@onready var back_button: Control = get_node_or_null("Back") as Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Compatibilidad con la versión anterior que tenía el botón dentro de VBox.
	if back_button == null:
		back_button = get_node_or_null("VBox/Back") as Control
	hide()


func open() -> void:
	show()
	if back_button != null:
		back_button.grab_focus()


func close() -> void:
	hide()
	SettingsManager.save_settings()


func _on_back_pressed() -> void:
	close()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
