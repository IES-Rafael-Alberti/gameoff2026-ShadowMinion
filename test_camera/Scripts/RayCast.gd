extends RayCast3D

@onready var interactionArea: InteractionArea = $"../../Obstaculo3D/InteractionArea"

var seeObstacle: bool

func _process(delta: float):
	
	if self.get_collider() == interactionArea:
		seeObstacle = true
	else: 
		seeObstacle = false
