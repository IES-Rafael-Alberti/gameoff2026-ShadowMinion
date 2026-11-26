extends CanvasLayer

signal closed

const STEP := 1.0
const REPEAT_DELAY := 0.3
const REPEAT_INTERVAL := 0.06

@onready var panel: Panel = $Panel
@onready var music_value: Label = $Panel/VBox/VolumeRows/MusicRow/MusicStepper/ValueLabel
@onready var sfx_value: Label = $Panel/VBox/VolumeRows/SfxRow/SfxStepper/ValueLabel
@onready var music_up: Button = $Panel/VBox/VolumeRows/MusicRow/MusicStepper/UpButton
@onready var controls_button: Button = $Panel/VBox/ControlsButton
@onready var controls_screen: PanelContainer = $ControlsScreen
@onready var repeat_timer: Timer = $RepeatTimer

var _hidden_siblings: Array[Node] = []
var _repeat_is_music := true
var _repeat_delta := STEP


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	repeat_timer.timeout.connect(_on_repeat_timeout)
	_update_labels()


func open() -> void:
	_hide_parent_ui()
	panel.show()
	show()
	music_up.grab_focus()


func close() -> void:
	_stop_repeat()
	if controls_screen.visible:
		controls_screen.close()
	else:
		SettingsManager.save_settings()
	_restore_parent_ui()
	panel.show()
	hide()
	closed.emit()


func _update_labels() -> void:
	music_value.text = str(roundi(SettingsManager.music_volume * 100.0))
	sfx_value.text = str(roundi(SettingsManager.sfx_volume * 100.0))


func _change_volume(is_music: bool, delta: float) -> void:
	var value := (SettingsManager.music_volume if is_music else SettingsManager.sfx_volume) * 100.0
	value = clampf(value + delta, 0.0, 100.0)
	var normalized := value / 100.0
	if is_music:
		SettingsManager.music_volume = normalized
	else:
		SettingsManager.sfx_volume = normalized
	SettingsManager.apply()
	_update_labels()


func _start_repeat(is_music: bool, delta: float) -> void:
	_repeat_is_music = is_music
	_repeat_delta = delta
	_change_volume(is_music, delta)
	repeat_timer.wait_time = REPEAT_DELAY
	repeat_timer.start()


func _stop_repeat() -> void:
	repeat_timer.stop()


func _on_repeat_timeout() -> void:
	_change_volume(_repeat_is_music, _repeat_delta)
	repeat_timer.wait_time = REPEAT_INTERVAL
	repeat_timer.start()


func _on_music_up_button_down() -> void:
	_start_repeat(true, STEP)


func _on_music_down_button_down() -> void:
	_start_repeat(true, -STEP)


func _on_sfx_up_button_down() -> void:
	_start_repeat(false, STEP)


func _on_sfx_down_button_down() -> void:
	_start_repeat(false, -STEP)


func _on_controls_button_pressed() -> void:
	panel.hide()
	controls_screen.open()


func _on_back_pressed() -> void:
	close()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	# Si está abierta la pantalla de controles, Esc la cierra ella sola.
	if controls_screen.visible:
		return

	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	# La pantalla de controles se cierra sola (Back o Esc); recuperamos el panel.
	if not visible or panel.visible or controls_screen.visible:
		return
	panel.show()
	controls_button.grab_focus()


func _hide_parent_ui() -> void:
	_hidden_siblings.clear()
	var parent := get_parent()
	if parent == null:
		return
	for sibling in parent.get_children():
		if sibling == self:
			continue
		if sibling is CanvasItem and sibling.visible:
			sibling.hide()
			_hidden_siblings.append(sibling)


func _restore_parent_ui() -> void:
	for node in _hidden_siblings:
		if is_instance_valid(node):
			node.show()
	_hidden_siblings.clear()
