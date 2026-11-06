extends Node


@export var ray: RayCast3D

@export var rest_length = 2.0
@export var stiffness = 10.0
@export var damping = 1.0
@export var grapple_per_jump = 1

@onready var player: CharacterBody3D = get_parent() as CharacterBody3D

var launched: bool = false
var target: Vector3

func _physics_process(delta: float) -> void:
	#Desactiva el gancho si no hay jugador o si se activa el modo 3D
	if not player or player.movement3DActivated:
		if launched:
			retract()
		return
	if Input.is_action_just_pressed("grapple"):
		print("gancho usado")
		launch()
	if Input.is_action_just_released("grapple"):
		print("gancho soltado")
		retract()
	
	if launched:
		handle_grapple(delta)

func launch():
	if ray == null:
		print("ERROR: No has asignado el nodo RayCast3D en el Inspector de GrapplingController")
		return
	if ray.is_colliding():
		target = ray.get_collision_point()
		launched = true
		print("Gancho conectado en: ", target)
	else:
		print("El gancho no alcanzó ninguna superficie colisionable")
	
func retract():
	launched = false

func handle_grapple(delta: float):
	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)
	
	var displacement = target_dist - rest_length
	
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = player.velocity.dot(target_dir)
		var damping_force = -damping * vel_dot * target_dir
		
		force = spring_force + damping_force
		
	player.velocity += force * delta
	#Para que el personaje no se desplace por el eje Z
	player.velocity.z = 0
