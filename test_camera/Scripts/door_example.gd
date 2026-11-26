extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var message_without_key: Label3D = $Message_without_key

var showing_message = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if message_without_key:
		message_without_key.hide()


func _on_key_example_door_opened() -> void:
	if message_without_key:
		message_without_key.hide()
	animation_player.play("open_door")
	

func _on_key_example_key_needed() -> void:
	if message_without_key and not showing_message:
		showing_message = true
		message_without_key.show()
		
		await get_tree().create_timer(2.0).timeout
		
		if is_instance_valid(message_without_key):
			message_without_key.hide()
		showing_message = false
