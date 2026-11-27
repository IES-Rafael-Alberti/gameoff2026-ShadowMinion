extends CanvasLayer

@onready var settings_menu: CanvasLayer = $settings_menu
@onready var button_manager: Control = $"Button Manager"
@onready var efecto_boton: TextureRect = $efecto_boton
@onready var efecto_gusano: TextureRect = $TextureRect/efecto_gusano

func _ready() -> void:
	settings_menu.closed.connect(_on_settings_closed)
	
	 
	
	# Conectar señales de los botones
	for boton in button_manager.get_children():
		if boton is TextureButton: 
			boton.mouse_entered.connect(_on_boton_hover.bind(boton))
			boton.mouse_exited.connect(_on_boton_salir)
			
	for efecto in [efecto_gusano, efecto_boton]:
		efecto.hide()
		efecto.mouse_filter = Control.MOUSE_FILTER_IGNORE # Evita el flickeo
		efecto.set_anchors_preset(Control.PRESET_TOP_LEFT)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://lvl_1.tscn")

func _on_options_pressed() -> void:
	button_manager.hide()
	settings_menu.open()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_closed() -> void:
	button_manager.show()
	
func _on_boton_hover(boton_actual: TextureButton) -> void:
	efecto_gusano.show()
	efecto_boton.show()
	
	# 1. Calculamos el centro exacto del botón actual
	# (get_global_rect() nos da la posición y tamaño real en pantalla)
	var centro_boton = boton_actual.get_global_rect().get_center()
	
	# 2. Calculamos la mitad del tamaño de nuestro efecto
	var mitad_efecto = efecto_boton.size / 2.0
	
	# 3. Movemos el efecto al centro y le restamos su mitad para que quede perfectamente centrado
	efecto_boton.global_position = centro_boton - mitad_efecto

func _on_boton_salir() -> void:
	efecto_gusano.hide()
	efecto_boton.hide()
