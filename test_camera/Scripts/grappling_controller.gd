extends Node


@export var ray: RayCast3D
@export var rope: Node3D

#@export var rest_length = 2.0
#@export var stiffness = 10.0
#@export var damping = 1.0

@export_group("Puntería")
@export var max_range = 12.0
@export_range(0.0, 90.0, 1.0) var aim_angle_deg = 45.0

@export_group("Cuerda")
@export var rope_unit_length = 1.0
@export var rope_tip_margin = 0.08
@export var consecutive_grapple:int = 1

@export_group("Péndulo")
@export var swing_damping: float = 0.05
@export var reel_speed: float = 0.0
@export var min_rope_length = 1.0
# Arco total máximo de balanceo en grados
@export_range(0.0, 360.0, 1.0) var max_total_swing_deg: float = 200.0


@onready var player: CharacterBody3D = get_parent() as CharacterBody3D

var rope_length: float = 0.0
var launched: bool = false
var target = Vector3.ZERO
var current_grapple:int = 0

func _physics_process(delta: float) -> void:
	#Desactiva el gancho si no hay jugador o si se activa el modo 3D
	
	if not player or player.movement3DActivated:
		if launched:
			retract()
		return
	
	if player.is_on_floor():
		current_grapple = consecutive_grapple
		
	_update_ray_direction()
	
	if Input.is_action_just_pressed("grapple"):
		#print("gancho usado")
		launch()
	if Input.is_action_just_released("grapple"):
		#print("gancho soltado")
		retract()
	
	if launched:
		handle_grapple(delta)
	
	update_rope()

func launch():
	if ray == null:
		print("ERROR: No has asignado el nodo RayCast3D en el Inspector de GrapplingController")
		return
	
	#Si no le quedan usos en el aire, no dispara
	if current_grapple <= 0:
		return
		
	#Usa la dirección del frame al activar el gancho
	ray.force_raycast_update()
	
	if not ray.is_colliding():
		return
		
	var collider = ray.get_collider()
	#if collider == null or not collider.is_in_group("grappleable"):
		#return
	target = ray.get_collision_point()
	
	rope_length = player.global_position.distance_to(target)
	rope_length = maxf(rope_length, min_rope_length)
	
	launched = true
	
	#Se consume un gancho al usarlo con éxito
	current_grapple -= 1

	
func retract()->void:
	launched = false

func handle_grapple(delta: float):
	if rope_length <= 0.0:
		return
	
	# Acortar la cuerda mientras mantienes el gancho
	if reel_speed > 0.0 and Input.is_action_pressed("grapple"):
		rope_length = maxf(rope_length - reel_speed * delta, min_rope_length)
	
	#Vector que va del ancla al jugador
	var offset = player.global_position - target
	var dist = offset.length()
	if dist < 0.001:
		return
	var dir = offset / dist
	
	#Si la cuerda está tensa, el jugador no puede alejarse más
	if dist >= rope_length:
		#Devuelve al jugador a la circuferencia de radio rope_length
		player.global_position = target + dir * rope_length
		
		#Quita solo la velocidad que aleja del ancla, la velocidad perpendicular se conserva
		var radial_speed = player.velocity.dot(dir)
		if radial_speed > 0.0:
			player.velocity -= dir * radial_speed
		
		var max_angle = deg_to_rad(max_total_swing_deg * 0.5)
		var down = Vector3.DOWN
		var angle = acos(clampf(dir.dot(down), -1.0, 1.0))
		if angle > max_angle:
			# Eje perpendicular al plano del balanceo
			var axis = down.cross(dir)
			if axis.length_squared() < 0.00001:
				axis = Vector3.BACK * (1.0 if player.velocity.x >= 0.0 else -1.0)
			axis = axis.normalized()
			
			#Dirección justo en el límite
			var clamped_dir = down.rotated(axis, max_angle)
			player.global_position = target + clamped_dir * rope_length
			
			#Quita la velocidad que intentaría seguir subiendo
			var tangent = axis.cross(clamped_dir)
			var outward_speed = player.velocity.dot(tangent)
			if outward_speed > 0.0:
				player.velocity -= tangent * outward_speed
			
			dir = clamped_dir
		
		#Amortiguación del balanceo
		if swing_damping > 0.0:
			var radial = dir * player.velocity.dot(dir)
			var tangential = player.velocity - radial
			player.velocity -= tangential * swing_damping * delta
			
	
	player.velocity.z = 0.0

func update_rope():
	if rope == null:
		return
	
	if not launched:
		rope.visible = false
		return
	
	rope.visible = true
	
	#Mismo origen para posicionar, orientar y medir
	var origin = player.global_position
	
	var to_target = target - origin
	var dist = to_target.length()
	if dist < 0.001:
		return
	var dir = to_target / dist
	
	#La punta se queda un pelín antes del impacto para no atravesar la superficie
	var visual_length = maxf(dist - rope_tip_margin, 0.001)
	
	var up = Vector3.UP
	if absf(dir.dot(up)) > 0.999:
		up = Vector3.BACK
	
	rope.scale = Vector3.ONE
	rope.global_position = origin
	rope.look_at(target, up)
	rope.scale = Vector3(1.0, 1.0, visual_length / maxf(rope_unit_length, 0.001))
	
	
func _update_ray_direction()->void:
	if ray == null:
		return
	var facing = 1
	var value = player.get("facing")
	if value != null:
		facing = int(value)
	var a = deg_to_rad(aim_angle_deg)
	var world_dir = Vector3(cos(a) * float(facing), sin(a), 0.0).normalized()
	#target_position va en espacio local del RayCast3D
	var local_dir = ray.global_transform.basis.inverse() * world_dir
	ray.target_position = local_dir.normalized() * max_range
