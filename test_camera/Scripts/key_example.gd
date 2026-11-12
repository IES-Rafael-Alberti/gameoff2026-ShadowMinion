extends Area3D

@onready var mesh_key: MeshInstance3D = $MeshInstance3D


signal door_opened
signal key_needed

var key_taken = false
var in_door_zone = false

#func _ready() -> void:
	#message_without_key.hide()


func _on_body_entered(body: CharacterBody3D) -> void:
	if not is_instance_valid(body):
		return
	if not body.is_in_group("player"):
		return
	
	if key_taken == false:
		key_taken = true
		mesh_key.queue_free()
	
func _process(delta):
	if in_door_zone == true and Input.is_action_just_pressed("interact"):
			if key_taken == true:
				door_opened.emit()
			else:
				key_needed.emit()



func _on_door_zone_body_entered(body: CharacterBody3D) -> void:
	if not is_instance_valid(body):
		return
	if not body.is_in_group("player"):
		return
		
	in_door_zone = true


func _on_door_zone_body_exited(body: CharacterBody3D) -> void:
	if not is_instance_valid(body):
		return
	if not body.is_in_group("player"):
		return
		
	in_door_zone = false
