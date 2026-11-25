class_name Player extends CharacterBody3D

@export_group("Speeds")
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
# Dash
@export var dash : float = 70.0
var tween: Tween
@export var dash_velocity : float = 0.0
#Fuerza de frenado en el aire al pulsar la dirección contraria tras soltar el gancho
#Al menor el número, mayor tarda en frenar
@export var air_brake_accel: float = 25.0
#Aceleración normal en el aire para moverte o girar
@export var air_control_accel: float = 50.0
@export_range(0.0, 1.0, 0.05) var ghost_alpha: float = 0.35
#@export_group("Balanceo")
## Aceleración horizontal que aplicas con izquierda/derecha mientras estás enganchado
#@export var grapple_air_accel : float = 10.0
## Aceleración cuando empujnas en contra. Más baja para no frenar de golpe
#@export var grapple_brake_accel : float = 4.0
##Velocidad horizontal máxima mientras empujas el balanceo
#@export var grapple_max_speed : float = 22.0


var move_speed : float = 0.0
var movement3DActivated = true
var jumpCount = 1

var original_position = Vector3.ZERO
var facing:int = 1

# Yaw del jugador en mundo. Se usa para convertir el yaw deseado del modelo
# a yaw local, así funciona con cualquier rotación de la raíz del nivel.
func _player_yaw() -> float:
	return global_transform.basis.get_euler().y

# Sentido de la "derecha" de la cámara 2D sobre el eje X del mundo.
# lvl 2/3 -> +1. lvl 4 (cámara 2D girada 180°) -> -1.
func _screen_x_axis() -> float:
	if _2d_camera == null:
		return 1.0
	var axis := _2d_camera.global_basis.x.x
	return 1.0 if is_zero_approx(axis) else signf(axis)


var is_dead: bool = false
var is_in_dialogue: bool = false
var current_animation: StringName = &""
var jump_replay_pending: bool = false
const CHARACTER_MODEL: PackedScene = preload("res://Assets/Anims/Neutral Idle.fbx")
var ghost_animation_player: AnimationPlayer = null
var ghost_current_animation: StringName = &""
var was_grappling: bool = false
var just_released_grapple: bool = false
var saved_2d_z: float = 0.0
# Mientras estás en el laberinto, los triggers controlan la cámara: E no hace nada
var in_maze: bool = false


@onready var camera_manager: Node = $"../CameraManager"
@onready var collider: CollisionShape3D = $Collider
@onready var _2d_camera: PhantomCamera3D = $"../CameraManager/2DCamera"
@onready var outsideCamera: PhantomCamera3D = $"../CameraManager/OutsideCamera"
@onready var insideCamera: PhantomCamera3D = $"../CameraManager/InsideCamera"

@onready var mesh: Node3D = $Mesh
@onready var mesh_ghost: Node3D = $MeshGhost
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var cameras3D = [outsideCamera, insideCamera]
var active3DCamera = outsideCamera

var debugMode = false

func _physics_process(delta: float) -> void:
	if is_in_dialogue:
		#Si hay diálogo, se bloquea el movimiento
		velocity = Vector3.ZERO
		move_and_slide()
		return
		
	changeMovementController()
	
	var grapple_node = get_node_or_null("GrapplingController")
	var is_grappling: bool = grapple_node != null and grapple_node.launched
	
	#Detecta el momento al soltar el gancho
	if was_grappling and not is_grappling:
		just_released_grapple = true
	
	#Si toca el suelo, se acaba la inercia del gancho
	if is_on_floor():
		just_released_grapple = false
	
	was_grappling = is_grappling
	
	if not is_on_floor():
		if not is_grappling:
			velocity += get_gravity() * delta
			#Si caemos del borde sin saltar, se elimina un salto
			if jumpCount > 1:
				jumpCount = 1
	else:
		jumpCount = 1 if movement3DActivated else 2
	
	if Input.is_action_just_pressed("Jump"):
		if debugMode:
			velocity.y = jump_velocity
			jump_replay_pending = true
		else:
			if movement3DActivated:
				if is_on_floor():
					velocity.y = jump_velocity
					jump_replay_pending = true
			else:
				if jumpCount > 0:
					jumpCount -=1
					velocity.y = jump_velocity
					jump_replay_pending = true
	
	if Input.is_action_just_pressed("Debug"):
		if debugMode:
			debugMode = false
		else:
			debugMode = true
			
	if Input.is_action_pressed("Sprint"):
			move_speed = sprint_speed
	else:
		move_speed = base_speed
		
	if movement3DActivated:
		movement3D()
	else:
		movement2D(delta)
		

	
	accion_dash()
	
	move_and_slide()
	
	_update_animation(delta, is_grappling)

# El yaw se calcula en mundo y se convierte a local con _player_yaw(),
# así funciona aunque la raíz del nivel tenga otra rotación.
# basic movement for 3D enviroment
func movement3D() -> void:
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	# Volvemos al basis LOCAL: es el que hacía que W/A/S/D funcionara en lvl 2 y 3.
	var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_dir:
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
		
		if mesh_ghost != null:
			# Usamos la INPUT, no el vector de movimiento: así W/S/A/D conservan
			# su animación aunque gires la raíz del nivel.
			# El FBX mira al revés, por eso sumamos PI:
			# W -> 0 (arriba), S -> PI (abajo), D -> -PI/2 (derecha), A -> PI/2 (izquierda).
			var desired_yaw := atan2(input_dir.x, input_dir.y) + PI
			mesh_ghost.rotation.y = desired_yaw - _player_yaw()
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
		
func movement2D(delta: float) ->void:
	#Busca si el nodo del gancho está en uso
	var grapple_node = get_node_or_null("GrapplingController")
	var is_grappling:bool = grapple_node != null and grapple_node.launched
	
	if is_grappling:
		#Sin control durante el balanceo: el gancho define la trayectoria
		velocity.z = 0.0
		return
		
	var input_dir := Input.get_axis("Left", "Right")
	# Convertimos la entrada a eje X del mundo según la vista de la cámara 2D.
	# En lvl 4 la cámara mira al revés, así que "derecha" es -X.
	var world_input := input_dir * _screen_x_axis()
	
	if not is_zero_approx(input_dir):
		# facing queda en coordenadas de mundo (+1 = +X, -1 = -X).
		facing = 1 if world_input > 0.0 else -1
		
		# facing 1 = +X, facing -1 = -X.
		if mesh != null:
			# En mundo: +X = -90°, -X = +90°.
			var desired_yaw := -float(facing) * PI / 2.0
			mesh.rotation.y = desired_yaw - _player_yaw()
		
		if is_on_floor():
			#En el suelo, el movimiento es instantáneo
			velocity.x = world_input * (move_speed + dash_velocity)
		else:
			#En el aire
			var target_speed = world_input * (move_speed + dash_velocity)
			#Si venimos del gancho y pulsamos la dirección contraria al movimiento
			if just_released_grapple and not is_zero_approx(velocity.x) and signf(world_input) != signf(velocity.x):
				# Frenado, se reduce la velocidad actual hasta 0
				velocity.x = move_toward(velocity.x, 0.0, air_brake_accel * delta)
				#Si ya hemos frenado casi del todo, quitamos el estado para que pueda girar con normalidad
				if absf(velocity.x) < 0.1:
					just_released_grapple = false
			else:
				#Control aéreo normal
				velocity.x = move_toward(velocity.x, target_speed, air_control_accel)
	# frenada
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
	velocity.z = 0.0
		

# alternate the movement of the player for 2D and 3D and the camera view
func changeMovementController() -> void:
	
	# Dentro del maze la cámara y el modo 3D los fijan los triggers
	if in_maze:
		return
		
	if not Input.is_action_just_pressed("ChangePerpective"):
		return
		
	if camera_manager and camera_manager.has_method("updateCamera"):
		camera_manager.updateCamera()
		
	if movement3DActivated:
		movement3DActivated = false
		
		global_position = original_position
		
		#Borra toda velocidad 3D para no salir del plano 2D
		velocity = Vector3.ZERO
		
		ghost_current_animation = &""
		
		#Recupera el modelo 3D y lo mete como hijo de player
		if mesh: 
			var parent_scene = get_tree().current_scene
			mesh.reparent(self)
			#Se alinea de nuevo con el centro del personaje
			mesh.position = Vector3.ZERO
			var desired_yaw := -float(facing) * PI / 2.0
			mesh.rotation = Vector3(0.0, desired_yaw - _player_yaw(), 0.0)
			mesh.visible = true
		if mesh_ghost:
			mesh_ghost.visible = false
	else:
		movement3DActivated = true
		original_position = global_position
		if animation_player:
			animation_player.stop()
		current_animation = &""
		#Dejamos el modelo 2D estático en el mundo
		if mesh:
			var parent_scene = get_tree().current_scene
			#Sacamos el mesh del parent y lo colgamos de la raíz de la escena
			mesh.reparent(parent_scene, true)
			mesh.visible = true
		if mesh_ghost:
			mesh_ghost.visible = true
			
	GlobalScript.set_3d_mode(movement3DActivated)

func _ready() -> void:
	
	#Conectamos las señales de dialogic para congelar al jugador
	Dialogic.timeline_started.connect(_on_dialogic_started)
	Dialogic.timeline_ended.connect(_on_dialogic_ended)
	
	#Comprobamos si venimos de un cambio de nivel
	if GlobalScript.use_next_spawn:
		global_position = GlobalScript.next_spawn_pos
		GlobalScript.use_next_spawn = false
	
	#Si no, usamos el checkpoint como siempre
	elif GlobalScript.checkpoint_pos != Vector3(-999, -999, -999):
		global_position = GlobalScript.checkpoint_pos
		
	movement3DActivated = false
	original_position = global_position
	
	if mesh: 
		mesh.visible = true
	if mesh_ghost:
		mesh_ghost.visible = false
		
	GlobalScript.set_3d_mode(false)
	
	_setup_animations()
	_setup_ghost_model()
	
	# Seguro: si Falling termina antes de tocar suelo, se reinicia desde el frame 0.
	if animation_player != null:
		animation_player.animation_finished.connect(_on_animation_finished)
	if ghost_animation_player != null:
		ghost_animation_player.animation_finished.connect(_on_ghost_animation_finished)
		
func _setup_animations() -> void:
	if animation_player == null:
		return
	var lib := animation_player.get_animation_library("player_anims")
	if lib == null:
		return
	# Por si al reimportar los FBX se regeneran los .res con rutas "Armature/...",
	# las dejamos como "Skeleton3D:..." que es lo que tiene el modelo del jugador
	for anim_name in lib.get_animation_list():
		var clip := lib.get_animation(anim_name)
		for i in clip.get_track_count():
			var p := String(clip.track_get_path(i))
			var fixed := p.replace("Armature_001/", "").replace("Armature/", "")
			if fixed != p:
				clip.track_set_path(i, NodePath(fixed))
	var looping: Array[StringName] = [&"Neutral Idle", &"Running", &"Gancho", &"Falling"]
	for anim_name in looping:
		if lib.has_animation(anim_name):
			lib.get_animation(anim_name).loop_mode = 1
	# El salto se reproduce una sola vez; al terminar pasa a Falling
	if lib.has_animation(&"Jumping"):
		lib.get_animation(&"Jumping").loop_mode = 0

func _setup_ghost_model() -> void:
	if mesh_ghost == null or animation_player == null:
		return
	if mesh_ghost.get_child_count() > 0:
		return  # Ya hay un modelo dentro (por si lo pusiste a mano en la escena)
	
	# Copia del personaje dentro del ghost
	var model := CHARACTER_MODEL.instantiate() as Node3D
	model.name = "Neutral Idle"
	mesh_ghost.add_child(model)
	
	# Copia exacta del transform del modelo normal:
	# escala 0.13, offset en Y y giro del FBX.
	var source_model := mesh.get_node_or_null("Neutral Idle") as Node3D
	if source_model == null and mesh.get_child_count() > 0:
		source_model = mesh.get_child(0) as Node3D
	if source_model != null:
		model.transform = source_model.transform
	
	_make_ghost_transparent(model, ghost_alpha)
	
	# Su propio AnimationPlayer, apuntando a ese modelo
	ghost_animation_player = AnimationPlayer.new()
	ghost_animation_player.name = "GhostAnimationPlayer"
	mesh_ghost.add_child(ghost_animation_player)
	ghost_animation_player.root_node = ghost_animation_player.get_path_to(model)
	
	# La MISMA librería (los 5 clips ya están normalizados por _setup_animations)
	var lib := animation_player.get_animation_library("player_anims")
	if lib != null:
		ghost_animation_player.add_animation_library("player_anims", lib.duplicate(true))

func _ghost_material(mat: BaseMaterial3D, alpha: float) -> BaseMaterial3D:
	# Duplicamos para no tocar el material del modelo original
	var copy := mat.duplicate(true) as BaseMaterial3D
	copy.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	copy.albedo_color.a = alpha
	copy.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	return copy


func _make_ghost_transparent(node: Node, alpha: float) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		
		# Si tuviera un material global puesto a mano
		var override := mi.material_override as BaseMaterial3D
		if override != null:
			mi.material_override = _ghost_material(override, alpha)
		
		# Materiales por superficie (los del FBX)
		if mi.mesh != null:
			for i in mi.mesh.get_surface_count():
				var mat := mi.get_surface_override_material(i) as BaseMaterial3D
				if mat == null:
					mat = mi.mesh.surface_get_material(i) as BaseMaterial3D
				if mat != null:
					mi.set_surface_override_material(i, _ghost_material(mat, alpha))
		
		# Evitamos que projete una sombra sólida
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# El esqueleto tiene mallas dentro, así que recorremos los hijos
	for child in node.get_children():
		_make_ghost_transparent(child, alpha)


func _on_animation_finished(anim_name: StringName) -> void:
	if is_dead or is_in_dialogue or is_on_floor():
		return
	if anim_name == StringName("player_anims/Falling"):
		animation_player.play(anim_name, 0.0)


func _on_ghost_animation_finished(anim_name: StringName) -> void:
	if is_dead or is_in_dialogue or is_on_floor() or ghost_animation_player == null:
		return
	if anim_name == StringName("player_anims/Falling"):
		ghost_animation_player.play(anim_name, 0.0)


func _update_animation(delta: float, is_grappling: bool) -> void:
	if is_dead or is_in_dialogue:
		return
	if animation_player == null:
		return
	
	# Cada salto (incluido el doble) reinicia Jumping desde el frame 0.
	var force_replay := false
	if jump_replay_pending:
		jump_replay_pending = false
		force_replay = true
	
	var speed := Vector2(velocity.x, velocity.z).length()
	var anim_name: StringName
	if not movement3DActivated and is_grappling:
		anim_name = &"Gancho"
	elif not is_on_floor() and (force_replay or velocity.y > 0.0):
		# Subiendo: Jumping. En el doble salto velocity.y vuelve a ser positivo,
		# así que este bloque se repite correctamente.
		anim_name = &"Jumping"
	elif not is_on_floor():
		# Bajando: Falling, tanto tras el primer salto como tras el doble.
		anim_name = &"Falling"
	elif speed > 0.5:
		anim_name = &"Running"
	else:
		anim_name = &"Neutral Idle"
	
	var anim_id := StringName("player_anims/" + String(anim_name))
	if not animation_player.has_animation(anim_id):
		return
	
	if not movement3DActivated:
		# Modo 2D: se anima el mesh que sigue al jugador
		if force_replay:
			animation_player.play(anim_id, 0.0)
			current_animation = anim_id
		elif anim_id != current_animation:
			animation_player.play(anim_id, 0.15)
			current_animation = anim_id
	else:
		# Modo 3D: se anima el ghost. Aquí no existe el gancho.
		if ghost_animation_player != null and anim_name != &"Gancho":
			if force_replay:
				ghost_animation_player.play(anim_id, 0.0)
				ghost_current_animation = anim_id
			elif anim_id != ghost_current_animation:
				ghost_animation_player.play(anim_id, 0.15)
				ghost_current_animation = anim_id


func accion_dash():
	if Input.is_action_just_pressed("Dash"):
		dash_velocity = dash
		if tween:
			tween.stop()
		tween = create_tween()
		tween.tween_property(self, "dash_velocity", 0, 0.2).set_ease(Tween.EASE_OUT)

func die()->void:
	if is_dead:
		return
	is_dead = true
	
	#Detén al jugador para que no siga interactuando
	set_physics_process(false)
	set_process(false)
	velocity = Vector3.ZERO
	
	#Desactiva la colisión para no disparar más body_entered
	if collider:
		collider.set_deferred("disabled", true)
		
	# Espera un frame para que terminen las señales de este frame
	await get_tree().process_frame
	
	#Recarga la escena
	get_tree().call_deferred("reload_current_scene")

#func _on_area_3d_body_entered(body: Node3D) -> void:
	#if active3DCamera == outsideCamera:
		#outsideCamera.priority = 0
		#active3DCamera = insideCamera
	#else:
		#insideCamera.priority = 0
		#active3DCamera = outsideCamera

	#active3DCamera.priority = 1
	
func _getMovement3DActive():
	return movement3DActivated
	
func _on_dialogic_started() -> void:
	is_in_dialogue = true
	# Detener la velocidad horizontal por si venía corriendo
	velocity.x = 0
	velocity.z = 0

func _on_dialogic_ended() -> void:
	is_in_dialogue = false
	

func enter_maze_3d() -> void:
	in_maze = true

	# El trigger manda: aunque ya estuvieras en 3D por la E, va la cámara del maze
	if camera_manager and camera_manager.has_method("set_inside_3d_camera"):
		camera_manager.set_inside_3d_camera()

	if movement3DActivated:
		# Ya veníamos en 3D: recupera el plano 2D que guardó la E
		saved_2d_z = original_position.z
		return

	# Guardamos la Z actual del plano 2D
	saved_2d_z = global_position.z

	movement3DActivated = true

	if animation_player:
		animation_player.stop()
	current_animation = &""

	if mesh:
		var parent_scene = get_tree().current_scene
		mesh.reparent(parent_scene, true)
		mesh.visible = true
	if mesh_ghost:
		mesh_ghost.visible = true

	GlobalScript.set_3d_mode(true)

func exit_maze_2d() -> void:
	if not movement3DActivated: return
	
	in_maze = false
	
	movement3DActivated = false
	
	# Usamos la Z que guardamos al entrar al laberinto
	var new_pos = global_position
	new_pos.z = saved_2d_z 
	global_position = new_pos
	original_position = new_pos # Actualizamos la referencia
	
	velocity = Vector3.ZERO
	ghost_current_animation = &""
	
	if mesh:
		var parent_scene = get_tree().current_scene
		mesh.reparent(self)
		mesh.position = Vector3.ZERO
		var desired_yaw := -float(facing) * PI / 2.0
		mesh.rotation = Vector3(0.0, desired_yaw - _player_yaw(), 0.0)
		mesh.visible = true
	if mesh_ghost:
		mesh_ghost.visible = false
		
	if camera_manager and camera_manager.has_method("set_2d_camera"):
		camera_manager.set_2d_camera()
		
	GlobalScript.set_3d_mode(false)
