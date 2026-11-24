extends BaseEnemy

@export_group("Patrulla 2D")
#Distnacia máxima a la que se aleja del punto inicial en 2D
@export var patrol_distance: float = 8.0

# Solo se activa en los cangrejos gigantes de lvl 2 para que no se choquen.
@export var avoid_other_enemies: bool = false
# Distancia mínima, en unidades sin escalar, antes de dar la vuelta.
@export var enemy_separation: float = 1.25

@export_group("Deambulando 3D")
#Tieempo en segundos antes de cambiar de dirección aleatoria en 3D
@export var wander_change_time: float = 1.5

#Variables de control 2D
var patrol_dir: float = 1.0
var start_x: float = 0.0

#Variables de control 3D
var wander_direction: Vector3 = Vector3.ZERO
var wander_timer: float = 0.0

func _ready() -> void:
	#Llama al _ready del BaseEnemy para buscar al jugador y conectar la hitbox
	super._ready()
	
	start_x = global_position.x
	_pick_new_wander_direction()

#Se ejecuta automáticamente en cada frame desde el _physics_process de BaseEnemy
func _custom_physics_process(delta:float)->void:
	if movement3DActivated:
		_process_3d_wander(delta)
	else:
		_process_2d_patrol()

func _process_2d_patrol()->void:
	var current_offset = global_position.x - start_x
	var current_dir_vec := Vector3(patrol_dir, 0.0, 0.0)
	
	#Cambia de sentido si choca con una pared, supera la distancia máxima o detecta un precipicio.
	#Solo comprobamos el precipicio mientras está en suelo: en el aire no debe dar la vuelta.
	if is_on_wall():
		patrol_dir *= -1.0
	elif is_on_floor() and not _is_floor_ahead(current_dir_vec):
		patrol_dir *= -1.0
	elif avoid_other_enemies and _is_enemy_ahead(current_dir_vec):
		patrol_dir *= -1.0
	elif absf(current_offset) >= patrol_distance * get_movement_scale():
		patrol_dir = -1.0 if current_offset > 0 else 1.0


func _process_3d_wander(delta: float)->void:
	wander_timer -= delta
	
	#Si detecta un precipicio enfrente en 3D, invierte el sentido para alejarse del borde.
	if is_on_floor() and not _is_floor_ahead(wander_direction):
		wander_direction = -wander_direction
		wander_timer = randf_range(wander_change_time * 0.7, wander_change_time * 1.3)
	#Si se agota el tiempo o choca contra una pared, elige un nuevo rumbo aleatorio
	elif wander_timer <= 0.0 or is_on_wall():
		_pick_new_wander_direction()

func _pick_new_wander_direction()->void:
	#Asigna un tiempo aleatorio alrededor de wander_change_time para que no sea mecánico
	wander_timer = randf_range(wander_change_time * 0.7, wander_change_time*1.3)
	
	#Genera una dirección aleatoria en 360 grados sobre el plano horizontal (X, Z)
	var random_angle = randf() * TAU
	wander_direction = Vector3(cos(random_angle), 0.0, sin(random_angle)).normalized()
	

func _get_custom_direction() -> Vector3:
	if movement3DActivated:
		return wander_direction
	else:
		return Vector3(patrol_dir, 0.0, 0.0)
		

#Detecta precipicios
func _is_floor_ahead(dir:Vector3) -> bool:
	if dir == Vector3.ZERO:
		return false
	
	var space_state := get_world_3d().direct_space_state
	var scale := get_movement_scale()
	var forward := dir.normalized()
	
	# La dirección ya está en mundo (el movimiento 2D siempre usa X/Z mundo),
	# así que funciona aunque el nivel o el enemigo estén girados.
	# Las distancias se escalan: los cangrejos de lvl 2 son x4.
	var ray_start := global_position + forward * (0.8 * scale) + Vector3.UP * (0.2 * scale)
	var ray_end := ray_start + Vector3.DOWN * (1.5 * scale)
	
	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	# No queremos que el rayo detecte Areas (por ejemplo, nuestro propio Hurtbox).
	query.collide_with_areas = false
	query.collide_with_bodies = true
	# Excluye el cuerpo, el Hurtbox y cualquier otro CollisionObject3D propio.
	query.exclude = _get_self_rids()
	
	var result := space_state.intersect_ray(query)
	# Devuelve true si el rayo tocó el suelo, false si detectó vacío/precipicio
	return not result.is_empty()


func _get_self_rids() -> Array[RID]:
	var rids: Array[RID] = []
	var stack: Array[Node] = [self]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is CollisionObject3D:
			rids.append(node.get_rid())
		for child in node.get_children():
			stack.append(child)
	return rids


# Evita que dos first_enemy se choquen: si hay otro delante, damos la vuelta.
func _is_enemy_ahead(dir: Vector3) -> bool:
	var forward := dir.normalized()
	var limit := enemy_separation * get_movement_scale()
	var parent := get_parent()
	if parent == null:
		return false
	
	for sibling in parent.get_children():
		if sibling == self or not (sibling is BaseEnemy):
			continue
		var other := sibling as Node3D
		var to_other := other.global_position - global_position
		to_other.y = 0.0
		if to_other.length() > limit:
			continue
		if to_other.normalized().dot(forward) > 0.2:
			return true
	return false
