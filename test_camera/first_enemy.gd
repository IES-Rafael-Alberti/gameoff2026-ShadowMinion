extends BaseEnemy

@export_group("Patrulla 2D")
#Distnacia máxima a la que se aleja del punto inicial en 2D
@export var patrol_distance: float = 8.0

@export_group("Deambulando 3D")
#Tieempo en segundos antes de cambiar de dirección aleatoria en 3D
@export var wander_change_time: float = 3.0

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
	var current_dir_vec = Vector3(patrol_dir, 0.0, 0.0)
	
	#Cambia de sentido si choca con una pared, supera la distancia máxima o detecta un precipicio
	if is_on_wall() or not _is_floor_ahead(current_dir_vec):
		patrol_dir *= -1.0
	elif absf(current_offset) >= patrol_distance:
		patrol_dir = -1.0 if current_offset > 0 else 1.0
func _process_3d_wander(delta: float)->void:
	wander_timer -= delta
	
	#Si detecta un precipicio enfrente en 3D, invierte el sentido para alejarse del borde
	if not _is_floor_ahead(wander_direction):
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
	#Si el enemigo ya está en el aire, no se comprueba el borde
	if not is_on_floor() or dir == Vector3.ZERO:
		return true
	
	var space_state = get_world_3d().direct_space_state
	
	#Calculamos un punto 0.8 metros por delante y un poco elevado respecto a la base del enemigo
	var ray_start = global_position + dir.normalized() * 0.8 + Vector3.UP * 0.2
	# El rayo apunta 1.5 metros hacia abajo
	var ray_end = ray_start + Vector3.DOWN * 1.5
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	#Ignora el propio cuerpo del enemigo
	query.exclude = [get_rid()] 
	
	var result = space_state.intersect_ray(query)
	# Devuelve true si el rayo tocó el suelo, false si detectó vacío/precipicio
	return not result.is_empty()
