extends CanvasLayer

signal closed

const STEP := 1.0
const REPEAT_DELAY := 0.3
const REPEAT_INTERVAL := 0.06

@onready var panel: Control = get_node_or_null("Panel") as Control
@onready var music_value: Label = get_node_or_null("Panel/VBox/VolumeRows/MusicRow/MusicStepper/ValueLabel") as Label
@onready var sfx_value: Label = get_node_or_null("Panel/VBox/VolumeRows/SfxRow/SfxStepper/ValueLabel") as Label
@onready var music_up: Control = get_node_or_null("Panel/VBox/VolumeRows/MusicRow/MusicStepper/UpButton") as Control
@onready var controls_button: Control = get_node_or_null("Panel/VBox/ControlsButton") as Control
@onready var audio_button: Control = get_node_or_null("TextureRect/AudioButton") as Control
@onready var controls_screen: Control = get_node_or_null("ControlsScreen") as Control
@onready var audio_menu: CanvasLayer = get_node_or_null("AudioMenu") as CanvasLayer
@onready var repeat_timer: Timer = get_node_or_null("RepeatTimer") as Timer

var _hidden_siblings: Array[Node] = []
var _audio_meter: Node = null
var _repeat_is_music := true
var _repeat_delta := STEP


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	# Compatible con el diseño anterior (Panel/VBox) y con el actual
	# (TextureRect con botones de textura).
	if panel == null:
		panel = get_node_or_null("TextureRect") as Control
	if controls_button == null:
		controls_button = get_node_or_null("TextureRect/ControlsButton") as Control

	_audio_meter = find_child("AudioMeter", true, false)
	if _audio_meter != null and _audio_meter.has_signal("volume_changed"):
		_audio_meter.connect("volume_changed", _update_labels)

	if audio_menu != null and audio_menu.has_signal("closed"):
		audio_menu.connect("closed", _on_audio_closed)

	if repeat_timer != null:
		repeat_timer.timeout.connect(_on_repeat_timeout)
	_update_labels()


func open() -> void:
	_hide_parent_ui()
	if panel != null:
		panel.show()
	show()
	if music_up != null:
		music_up.grab_focus()
	elif controls_button != null:
		controls_button.grab_focus()


func close() -> void:
	_stop_repeat()
	if audio_menu != null and audio_menu.visible:
		audio_menu.call("close")
		return
	if controls_screen != null and controls_screen.visible:
		controls_screen.call("close")
	else:
		SettingsManager.save_settings()
	_restore_parent_ui()
	if panel != null:
		panel.show()
	hide()
	closed.emit()


func _update_labels() -> void:
	if music_value != null:
		music_value.text = str(roundi(SettingsManager.music_volume * 100.0))
	if sfx_value != null:
		sfx_value.text = str(roundi(SettingsManager.sfx_volume * 100.0))
	if _audio_meter != null and _audio_meter.has_method("update"):
		_audio_meter.call("update")


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
	if repeat_timer == null:
		return
	repeat_timer.wait_time = REPEAT_DELAY
	repeat_timer.start()


func _stop_repeat() -> void:
	if repeat_timer != null:
		repeat_timer.stop()


func _on_repeat_timeout() -> void:
	_change_volume(_repeat_is_music, _repeat_delta)
	if repeat_timer == null:
		return
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
	if panel != null:
		panel.hide()
	if controls_screen != null:
		controls_screen.call("open")


func _on_audio_button_pressed() -> void:
	if panel != null:
		panel.hide()
	if audio_menu != null:
		audio_menu.call("open")


func _on_audio_closed() -> void:
	if panel != null:
		panel.show()
	if audio_button != null:
		audio_button.grab_focus()
	elif controls_button != null:
		controls_button.grab_focus()


func _on_back_pressed() -> void:
	close()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	# Si está abierta Controls o Audio, cada pantalla cierra con Esc ella sola.
	if controls_screen != null and controls_screen.visible:
		return
	if audio_menu != null and audio_menu.visible:
		return

	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	# La pantalla de controles se cierra sola (Back o Esc); recuperamos el panel.
	if not visible:
		return
	if panel != null and panel.visible:
		return
	if controls_screen != null and controls_screen.visible:
		return
	if audio_menu != null and audio_menu.visible:
		return
	if panel != null:
		panel.show()
	if audio_button != null:
		audio_button.grab_focus()
	elif controls_button != null:
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
