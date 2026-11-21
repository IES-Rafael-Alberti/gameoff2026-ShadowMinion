extends Node


@export var ray: RayCast3D
@export var rope: Node3D

#@export var rest_length = 2.0
#@export var stiffness = 10.0
#@export var damping = 1.0

@export_group("Puntería")
@export var max_range = 12.0
@export_range(0.0, 90.0, 1.0) var aim_angle_deg = 45.0
#Abanico total en grados
@export var spread_angle_deg = 15.0
#Cuantos rayos lanzar en el abanico
@export var ray_count = 5

@export_group("Cuerda")
@export var rope_unit_length = 1.0
@export var rope_tip_margin = 0.08
@export var consecutive_grapple:int = 2

@export_group("Péndulo")
#@export var swing_damping: float = 0.05
#Velocidad tangencial constante con la que recorres el arco
@export var swing_speed: float = 12.0
@export var reel_speed: float = 0.0
@export var min_rope_length = 1.0
# Arco total máximo de balanceo en grados
@export_range(0.0, 360.0, 1.0) var max_total_swing_deg: float = 100.0


@onready var player: CharacterBody3D = get_parent() as CharacterBody3D

var rope_length: float = 0.0
var launched: bool = false
var target = Vector3.ZERO
var current_grapple:int = 0

#Estado del arco predefinido
var current_angle: float = 0.0 #ángulo respecto a "abajo" del ancla (rad)
var swing_dir: int = 1 # Dirección del barrido
var swept_angle_rad: float = 0.0 #ángulo total recorrido (rad)

func _physics_process(delta: float) -> void:
	#Desactiva el gancho si no hay jugador o si se activa el modo 3D
	
	if not player or player.movement3DActivated or player.is_in_dialogue:
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
		
	var facing_val = player.get("facing")
	var facing = int(facing_val) if facing_val != null else 1
	if facing == 0: facing = 1
	
	# Lanzamos múltiples rayos en abanico
	for i in range(ray_count):
		# Calculamos el ángulo de este rayo específico
		var angle_offset = (i - (ray_count - 1) / 2.0) * (spread_angle_deg / max(1.0, float(ray_count -1)))
		var current_aim = aim_angle_deg + angle_offset
		var a = deg_to_rad(current_aim)
		
		#Calculamos la dirección en el mundo y la pasamos al espacio local del rayo
		var world_dir = Vector3(cos(a) * float(facing), sin(a), 0.0).normalized()
		var local_dir = ray.global_transform.basis.inverse() * world_dir
		
		#Apuntamos el rayo y forzamos la actualización de colisión
		ray.target_position = local_dir.normalized() * max_range
		#Usa la dirección del frame al activar el gancho
		ray.force_raycast_update()
		
		#Comprobamos si este rayo del abanico golpeó algo
		if ray.is_colliding():
			var collider = ray.get_collider()
			print("¡El rayo chocó con: ", collider.name, "!")
			if collider != null and collider.is_in_group("grappleable"):
				print("¡Es grappleable! Lanzando gancho.")
				#Nos enganchamos al primer rayo que toque algo que se puede enganchar
				target = ray.get_collision_point()
				
				rope_length = player.global_position.distance_to(target)
				rope_length = maxf(rope_length, min_rope_length)
				
				#Ángulo inicial respecto a la vertical hacia abajo del ancla.
				#0 es justo debajo, positivo es derecha y negativo es izquierda
				var offset = player.global_position - target
				current_angle = atan2(offset.x, -offset.y)
				
				#Dirección del barrido según donde mira el jugador
				swing_dir = facing
				swept_angle_rad = 0.0
				
				launched = true
				
				#Se consume un gancho al usarlo con éxito
				current_grapple -= 1
				
				return
	
	
	
	
	
	

	
	
	
	
	
	

	
func retract()->void:
	if launched and player and player.velocity.y > 0.0:
		#Suaviza el impulso hacia arriba al soltar para un salto más parabólico
		player.velocity.y *= 0.4
	launched = false

func handle_grapple(delta: float):
	if rope_length <= 0.0:
		return
	
	# Acortar la cuerda mientras mantienes el gancho
	if reel_speed > 0.0 and Input.is_action_pressed("grapple"):
		rope_length = maxf(rope_length - reel_speed * delta, min_rope_length)
	
	# Avance angular con velocidad tangencial constante
	var angular_speed = swing_speed / maxf(rope_length, 0.001)
	var angle_step = swing_dir * angular_speed * delta
	current_angle += angle_step
	swept_angle_rad += abs(angle_step)
	
	#Posicón exacta sobre el arco (0 es por debajo del ancla)
	var new_offset = Vector3(sin(current_angle), -cos(current_angle), 0.0) * rope_length
	player.global_position = target + new_offset
	
	#Velocidad tangencial para conservar inercia al soltar
	var tangent = Vector3(cos(current_angle), sin(current_angle), 0.0) * swing_dir
	player.velocity = tangent * swing_speed
	
	#Autosaltar al superar el arco máximo
	if rad_to_deg(swept_angle_rad) >= max_total_swing_deg:
		retract()

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
