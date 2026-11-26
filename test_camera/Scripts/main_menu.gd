extends Node3D

@onready var settings_menu: CanvasLayer = $settings_menu
@onready var button_manager: Control = $"Button Manager"

func _ready() -> void:
	settings_menu.closed.connect(_on_settings_closed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://lvl_1.tscn")


func _on_options_pressed() -> void:
	button_manager.hide()
	settings_menu.open()


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_closed() -> void:
	button_manager.show()
