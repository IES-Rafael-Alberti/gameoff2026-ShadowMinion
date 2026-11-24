extends Node3D


@export var ray: RayCast3D
@export var rope: Node3D

#@export var rest_length = 2.0
#@export var stiffness = 10.0
#@export var damping = 1.0

@export_group("Puntería")
@export var max_range = 12.0
@export_range(0.0, 90.0, 1.0) var aim_angle_deg = 60.0
@export var spread_angle_deg = 60.0
#Cuantos rayos lanzar en el abanico
@export var ray_count = 7
#Si está activo, solo puedes enganchar puntos visibles en pantalla
@export var require_on_screen: bool = true
@export_range(0.0, 0.5, 0.01) var screen_margin: float = 0.05

@export_group("Cuerda")
@export var rope_unit_length = 1.0
@export var rope_tip_margin = 0.08
@export var consecutive_grapple:int = 2

@export_group("Péndulo")
#@export var swing_damping: float = 0.05
#Velocidad tangencial constante con la que recorres el arco
@export var swing_speed: float = 12.0
@export var reel_speed: float = 0.0
@export var min_rope_length = 0.2
# Arco total máximo de balanceo en grados
@export_range(0.0, 360.0, 1.0) var max_total_swing_deg: float = 100.0
@export_range(0.0, 90.0, 1.0) var max_swing_angle_deg: float = 80.0


@onready var player: CharacterBody3D = get_parent() as CharacterBody3D

var rope_length: float = 0.0
var launched: bool = false
var target: Vector3 = Vector3.ZERO
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
	

func _is_grappleable(col: Object) -> bool:
	# El grupo puede estar en el collider, en el Area3D, o en el contenedor "ganchos"
	var node := col as Node
	while node != null:
		if node.is_in_group("grappleable"):
			return true
		node = node.get_parent()
	return false


func _is_on_screen(point: Vector3) -> bool:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return true
	# Delante de la cámara
	if (point - cam.global_position).dot(-cam.global_transform.basis.z) <= 0.0:
		return false
	# Dentro del rectángulo de pantalla (con un pequeño margen)
	var screen_pos := cam.unproject_position(point)
	var rect := get_viewport().get_visible_rect()
	var mx := rect.size.x * screen_margin
	var my := rect.size.y * screen_margin
	return (
		screen_pos.x >= -mx and screen_pos.x <= rect.size.x + mx
		and screen_pos.y >= -my and screen_pos.y <= rect.size.y + my
	)

func launch():
	if ray == null or current_grapple <= 0:
		return
		
	var facing_val = player.get("facing")
	var facing = int(facing_val) if facing_val != null else 1
	if facing == 0: facing = 1
	
	var space_state = get_world_3d().direct_space_state
	var start = ray.global_position
	
	# Mejor candidato encontrado
	var best_target := Vector3.ZERO
	var best_distance := INF
	var found_target := false
	
	var offsets := []
	for i in range(ray_count):
		offsets.append((i - (ray_count - 1) / 2.0) * (spread_angle_deg / max(1.0, float(ray_count - 1))))
	
	for angle_offset in offsets:
		var a = deg_to_rad(aim_angle_deg + angle_offset)
		var world_dir = Vector3(cos(a) * float(facing), sin(a), 0.0).normalized()
		var ray_end = start + (world_dir * max_range)
		
		var excluded: Array[RID] = [player.get_rid()]
		
		for j in range(20):
			var query = PhysicsRayQueryParameters3D.create(start, ray_end)
			query.exclude = excluded
			query.collide_with_bodies = true
			query.collide_with_areas = true
			query.hit_from_inside = true
			
			var result = space_state.intersect_ray(query)
			if result.is_empty():
				break
			
			var col = result.collider
			if col == null:
				break
			
			if _is_grappleable(col):
				# Comparamos distancia desde el JUGADOR, no desde el rayo
				var point = result.position
				var d = player.global_position.distance_to(point)
				
				# No enganchar fuera de alcance ni fuera de pantalla
				if d > max_range:
					break
				if require_on_screen and not _is_on_screen(point):
					break
				
				if d < best_distance:
					best_distance = d
					best_target = point
					found_target = true
				
				# Este rayo ya encontró su primer gancho; los de más allá están más lejos
				break
			
			# Pared/techo/suelo: excluir y relanzar desde el mismo punto
			if col is CollisionObject3D:
				excluded.append(col.get_rid())
			else:
				break
	
	# Ningún rayo encontró un gancho
	if not found_target:
		return
	
	# Enganchamos SIEMPRE al más cercano
	target = best_target
	rope_length = maxf(best_distance, min_rope_length)
	
	var offset = player.global_position - target
	current_angle = atan2(offset.x, -offset.y)
	
	swing_dir = facing
	swept_angle_rad = 0.0
	launched = true
	current_grapple -= 1
	
	ray.target_position = ray.to_local(target)
	ray.force_raycast_update()
	
	print("GANCHO MAS CERCANO: ", target, " distancia=", best_distance)

	
func retract()->void:
	if launched and player and player.velocity.y > 0.0:
		#Suaviza el impulso hacia arriba al soltar para un salto más parabólico
		player.velocity.y *= 0.4
	launched = false

func handle_grapple(delta: float):
	if rope_length <= 0.0:
		return
	
	if reel_speed > 0.0 and Input.is_action_pressed("grapple"):
		rope_length = maxf(rope_length - reel_speed * delta, min_rope_length)
	
	var angular_speed = swing_speed / maxf(rope_length, 0.001)
	var angle_step = swing_dir * angular_speed * delta
	current_angle += angle_step
	swept_angle_rad += abs(angle_step)
	
	#No subir por encima del ancla
	var limit := deg_to_rad(max_swing_angle_deg)
	if current_angle > limit:
		current_angle = limit
		swing_dir = -1
	elif current_angle < -limit:
		current_angle = -limit
		swing_dir = 1
	
	var new_offset: Vector3 = Vector3(sin(current_angle), -cos(current_angle), 0.0) * rope_length
	var desired: Vector3 = target + new_offset
	var tangent: Vector3 = Vector3(cos(current_angle), sin(current_angle), 0.0) * swing_dir
	
	player.velocity = tangent * swing_speed
	
	#No atravesar colisiones
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(player.global_position, desired)
	query.exclude = [player.get_rid()]
	var hit := space_state.intersect_ray(query)
	if not hit.is_empty():
		retract()
		return
	
	player.global_position = desired
	
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
