extends StaticBody3D

#Area que detecta al jugador para hacerle daño. Arrástrala desde el editor
@onready var hitbox: Area3D = $hitbox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)


func _on_hitbox_body_entered(body: Node3D)->void:
	if not body.is_in_group("player"):
		return
	if body.has_method("die"):
		body.call_deferred("die")
		
