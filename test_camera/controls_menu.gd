extends PanelContainer

@onready var back_button: Button = $VBox/Back


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func open() -> void:
	show()
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
