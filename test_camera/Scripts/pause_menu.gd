extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Permite que el menú funcione aunque el juego esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_paused(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		set_paused(not get_tree().paused)
		#if get_tree().paused:
			#visible = false
			#get_tree().paused = false
		#else:
			#visible = true
			#get_tree().paused = true


func set_paused(is_paused: bool) -> void:
	get_tree().paused = is_paused
	visible = is_paused


func _on_resume_pressed() -> void:
	set_paused(false)


func _on_return_to_last_checkpoint_pressed() -> void:
	set_paused(false)
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player and player.has_method("die"):
		player.die()


func _on_return_to_title_screen_pressed() -> void:
	set_paused(false) 
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
