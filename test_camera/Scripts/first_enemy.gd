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

@export_group("Ciclo movimiento / pausa / giro")
# ~5 s andando, ~1-2 s parado con crabidle.
@export var move_duration: float = 5.0
@export var move_variation: float = 1.0
@export var idle_min_time: float = 1.0
@export var idle_max_time: float = 2.0
# Duración del giro antes de continuar hacia el nuevo sentido.
@export var turn_duration: float = 0.35
# Evita volver a girar el mismo frame en que seguimos tocando el obstáculo.
@export var turn_recheck_delay: float = 0.25

enum State { MOVING, IDLE, TURNING }

#Variables de control 2D
var patrol_dir: float = 1.0
var start_x: float = 0.0

#Variables de control 3D
var wander_direction: Vector3 = Vector3.ZERO
var wander_timer: float = 0.0

#Control del ciclo
var _state: State = State.MOVING
var _move_timer: float = 0.0
var _idle_timer: float = 0.0
var _check_cooldown: float = 0.0
var _last_move_dir: Vector3 = Vector3.ZERO

#Control del giro
var _turn_pending_dir: Vector3 = Vector3.ZERO
var _turn_from: float = 0.0
var _turn_to: float = 0.0
var _turn_elapsed: float = 0.0

@onready var crab_animation_player: AnimationPlayer = $CrabAnimationPlayer

var current_crab_animation: StringName = &""

func _ready() -> void:
	#Llama al _ready del BaseEnemy para buscar al jugador y conectar la hitbox
	super._ready()
	
	start_x = global_position.x
	_state = State.MOVING
	_move_timer = _next_move_time()
	_pick_new_wander_direction(false)
	_play_crab_animation(&"crabidle")

func _next_move_time() -> float:
	return maxf(0.1, randf_range(move_duration - move_variation, move_duration + move_variation))

#Se ejecuta automáticamente en cada frame desde el _physics_process de BaseEnemy
func _custom_physics_process(delta:float)->void:
	if _check_cooldown > 0.0:
		_check_cooldown -= delta
	
	match _state:
		State.MOVING:
			_move_timer -= delta
			if _move_timer <= 0.0:
				_state = State.IDLE
				_idle_timer = randf_range(idle_min_time, idle_max_time)
			elif movement3DActivated:
				_process_3d_wander(delta)
				_update_facing_3d()
			else:
				_process_2d_patrol()
		State.IDLE:
			_idle_timer -= delta
			if _idle_timer <= 0.0:
				_state = State.MOVING
				_move_timer = _next_move_time()
		State.TURNING:
			_update_turn(delta)
	
	_update_crab_animation()

# En pausa o girando devolvemos CERO para que BaseEnemy frene y no se desplace.
func _get_move_direction() -> Vector3:
	if _state != State.MOVING:
		return Vector3.ZERO
	_last_move_dir = super._get_move_direction()
	return _last_move_dir

# Yaw real del enemigo en mundo. get_euler().y puede dar 0 en enemigos girados 90°,
# así que lo sacamos de la columna X de la base (funciona con cualquier escala).
func _enemy_yaw() -> float:
	var b := global_transform.basis
	return atan2(-b.x.z, b.x.x)

# El FBX del cangrejo mira hacia -Z: esta fórmula vale para 2D (±X) y 3D (X/Z).
func _yaw_for_direction(dir: Vector3) -> float:
	return atan2(dir.x, dir.z) + PI - _enemy_yaw()

# En 2D BaseEnemy ya calcula facing (+1 = +X, -1 = -X).
func _set_facing(new_facing: int) -> void:
	facing = new_facing
	if movement3DActivated or visual == null or _state == State.TURNING:
		return
	visual.rotation.y = _yaw_for_direction(Vector3(float(facing), 0.0, 0.0))

# En 3D miramos hacia la dirección real de movimiento (X/Z), no solo hacia ±X.
func _update_facing_3d() -> void:
	if visual == null or _state != State.MOVING:
		return
	var dir := _last_move_dir
	if dir == Vector3.ZERO:
		return
	visual.rotation.y = _yaw_for_direction(dir)

# Giro suave hasta el nuevo sentido; al terminar se reanuda el trayecto.
func _start_turn(new_dir: Vector3) -> void:
	if _state == State.TURNING or new_dir == Vector3.ZERO:
		return
	var dir := new_dir.normalized()
	_turn_pending_dir = dir
	if visual == null:
		_apply_new_direction(dir)
		return
	_turn_from = visual.rotation.y
	# Camino corto: nunca da más de media vuelta.
	_turn_to = _turn_from + wrapf(_yaw_for_direction(dir) - _turn_from, -PI, PI)
	_turn_elapsed = 0.0
	_state = State.TURNING

func _update_turn(delta: float) -> void:
	_turn_elapsed += delta
	var t := clampf(_turn_elapsed / maxf(turn_duration, 0.001), 0.0, 1.0)
	var eased := t * t * (3.0 - 2.0 * t) # smoothstep
	if visual != null:
		visual.rotation.y = lerpf(_turn_from, _turn_to, eased)
	if t >= 1.0:
		if visual != null:
			visual.rotation.y = _turn_to
		_apply_new_direction(_turn_pending_dir)
		_check_cooldown = turn_recheck_delay
		_state = State.MOVING

func _apply_new_direction(dir: Vector3) -> void:
	if movement3DActivated:
		wander_direction = dir.normalized()
		wander_timer = randf_range(wander_change_time * 0.7, wander_change_time * 1.3)
	else:
		patrol_dir = 1.0 if dir.x > 0.0 else -1.0

# Reproduce crabwalk mientras se mueve; crabidle en pausa y durante el giro.
func _update_crab_animation() -> void:
	_play_crab_animation(&"crabwalk" if _state == State.MOVING else &"crabidle")

func _play_crab_animation(anim_name: StringName) -> void:
	if crab_animation_player == null:
		return
	var full_name := StringName("crab_anims/%s" % anim_name)
	if full_name == current_crab_animation:
		return
	current_crab_animation = full_name
	crab_animation_player.play(full_name)

func _process_2d_patrol()->void:
	if _check_cooldown > 0.0:
		return
	var current_offset = global_position.x - start_x
	var current_dir_vec := Vector3(patrol_dir, 0.0, 0.0)
	var new_dir := patrol_dir
	
	#Cambia de sentido si choca con una pared, supera la distancia máxima o detecta un precipicio.
	#Solo comprobamos el precipicio mientras está en suelo: en el aire no debe dar la vuelta.
	if is_on_wall():
		new_dir = -patrol_dir
	elif is_on_floor() and not _is_floor_ahead(current_dir_vec):
		new_dir = -patrol_dir
	elif avoid_other_enemies and _is_enemy_ahead(current_dir_vec):
		new_dir = -patrol_dir
	elif absf(current_offset) >= patrol_distance * get_movement_scale():
		new_dir = -1.0 if current_offset > 0 else 1.0
	
	if not is_equal_approx(new_dir, patrol_dir):
		_start_turn(Vector3(new_dir, 0.0, 0.0))

func _process_3d_wander(delta: float)->void:
	wander_timer -= delta
	if _check_cooldown > 0.0:
		return
	
	#Si detecta un precipicio enfrente en 3D, inicia el giro para alejarse del borde.
	if is_on_floor() and not _is_floor_ahead(wander_direction):
		_start_turn(-wander_direction)
	#Si se agota el tiempo o choca contra una pared, elige un nuevo rumbo aleatorio
	elif wander_timer <= 0.0 or is_on_wall():
		_pick_new_wander_direction()

func _pick_new_wander_direction(start_turn: bool = true)->void:
	#Asigna un tiempo aleatorio alrededor de wander_change_time para que no sea mecánico
	wander_timer = randf_range(wander_change_time * 0.7, wander_change_time*1.3)
	
	#Genera una dirección aleatoria en 360 grados sobre el plano horizontal (X, Z)
	var random_angle = randf() * TAU
	var dir := Vector3(cos(random_angle), 0.0, sin(random_angle)).normalized()
	if start_turn:
		_start_turn(dir)
	else:
		wander_direction = dir

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
