class_name BaseEnemy
extends CharacterBody3D

@export_group("Referencias")
#Area que detecta al jugador para hacerle daño. Arrástrala desde el editor
@export var hitbox: Area3D
#Nodo visual para que el script voltee el enemigo
@export var visual: Node3D

@export_group("Movimiento")
#Activa el seguimiento al jugador mientras está en el modo 2D
@export var track_in_2d : bool = false
#Activa el seguimiento al jugador mientras está en el modo 3D
@export var track_in_3d : bool = false
## Velocidad base del enemigo
@export var base_speed : float = 5.0
#Que tan rápido acelera o frena hacia la velocidad del objetivo
@export var acceleration : float = 25.0
#Distancia a la que deja de acercarse al jugador
@export var stop_distance : float = 0.8


var move_speed : float = 0.0
var facing:int = 1
var movement3DActivated = false
var original_position: Vector3 = Vector3.ZERO


var player: CharacterBody3D = null


func _ready() -> void:
	move_speed = base_speed
	original_position = global_position
	_find_player()
	
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _find_player()-> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	if not is_instance_valid(player):
		var scene = get_tree().current_scene
		if scene:
			player = scene.get_node_or_null("Player") as CharacterBody3D

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		_find_player()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	_update_movement_mode()
	
	var dir = _get_move_direction() 
	
	if movement3DActivated:
		_move_3d(dir, delta)
	else:
		_move_2d(dir, delta)
		
	_custom_physics_process(delta)
	move_and_slide()

func _update_movement_mode()-> void:
	if not is_instance_valid(player):
		return
	
	var new_mode: bool = bool(player.get("movement3DActivated"))
	
	if new_mode == movement3DActivated:
		return
	
	movement3DActivated = new_mode
	_on_mode_changed()
	
func _on_mode_changed() -> void:
	if movement3DActivated:
		#Guarda la posición 2D al entrar 3D
		original_position = global_position
		return
	#Vuelve exactamente al punto 2D donde estaba
	global_position = original_position
	velocity.z = 0.0
	
func _get_move_direction() -> Vector3:
	var tracking_enable: bool = track_in_3d if movement3DActivated else track_in_2d
	
	#Si el tracking de la dimensión actual está activo, persigue al jugador
	if tracking_enable and is_instance_valid(player):
		return _get_player_direction()
	
	#Si el tracking está apagado, usa la dirección propia que definas en el hijo
	return _get_custom_direction()

	
func _get_player_direction()-> Vector3:
	var to_player = player.global_position - global_position
	to_player.y = 0
	
	if not movement3DActivated:
		to_player.z = 0.0
	
	var dist = to_player.length()
	if dist <= stop_distance:
		return Vector3.ZERO
	
	return to_player / dist
	

func _move_2d(dir: Vector3, delta: float) ->void:
	var target_x = dir.x * move_speed
	velocity.x = move_toward(velocity.x, target_x, acceleration * delta)
	velocity.z = 0.0
	if absf(dir.x) > 0.01:
		_set_facing(1 if dir.x > 0.0 else -1)


func _move_3d(dir: Vector3, delta: float) ->void:
	var flat = Vector3(dir.x, 0.0, dir.z)
	if flat.length() > 1.0:
		flat = flat.normalized()
	
	var target = flat * move_speed
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)
	
	if absf(flat.x) > 0.01:
		_set_facing(1 if flat.x > 0.0 else -1)

func _set_facing(new_facing: int)->void:
	facing = new_facing
	
	if visual == null:
		return
	
	visual.rotation_degrees.y = 0.0 if facing == 1 else 180.0
	
	#var s = visual.scale
	#s.x = absf(s.x) * float(facing)
	#visual.scale = s
	
func _on_hitbox_body_entered(body: Node3D)->void:
	if not body.is_in_group("player"):
		return
	if body.has_method("die"):
		body.die()
		

#Sobrescribir en scripts hijos cuando no uses tracking en alguna dimensión
#Si no se sobreescribes, el enemigo se queda en su sitio

func _get_custom_direction() -> Vector3:
	return Vector3.ZERO

#Para añadir lógica adicional
func _custom_physics_process(_delta: float) -> void:
	pass
