extends Area3D

@export var is_entrance: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
		
	if is_entrance:
		body.enter_maze_3d()
	else:
		body.exit_maze_2d()
