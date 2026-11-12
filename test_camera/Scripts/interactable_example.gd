extends StaticBody3D

@onready var interaction_area: InteractionArea = $InteractionArea


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact() -> void:
	print("Interacción funciona")
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 0.4, 0.15)
	tween.tween_property(self, "position:y", position.y, 0.15)
