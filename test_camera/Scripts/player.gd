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
var is_dead: bool = false
var is_in_dialogue: bool = false
var was_grappling: bool = false
var just_released_grapple: bool = false


@onready var camera_manager: Node = $"../CameraManager"
@onready var collider: CollisionShape3D = $Collider
@onready var _2d_camera: PhantomCamera3D = $"../CameraManager/2DCamera"
@onready var outsideCamera: PhantomCamera3D = $"../CameraManager/OutsideCamera"
@onready var insideCamera: PhantomCamera3D = $"../CameraManager/InsideCamera"

@onready var mesh: MeshInstance3D = $Mesh
@onready var mesh_ghost: MeshInstance3D = $MeshGhost

var cameras3D = [outsideCamera, insideCamera]
var active3DCamera = outsideCamera

var fixedZ: float

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
		else:
			if movement3DActivated:
				if is_on_floor():
					velocity.y = jump_velocity
			else:
				if jumpCount > 0:
					jumpCount -=1
					velocity.y = jump_velocity
	
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

# basic movement for 3D enviroment
func movement3D() -> void:
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_dir:
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
		
func movement2D(delta: float) ->void:
	global_position.z = fixedZ
	var input_dir := Input.get_axis("Left", "Right")
	#var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_zero_approx(input_dir):
		facing = 1 if input_dir > 0.0 else -1
		
	#Busca si el nodo del gancho está en uso
	var grapple_node = get_node_or_null("GrapplingController")
	var is_grappling:bool = grapple_node != null and grapple_node.launched
	
	if is_grappling:
		#Sin control durante el balanceo: el gancho define la trayectoria
		velocity.z = 0.0
		return
		
	var input_dir := Input.get_axis("Left", "Right")
	#var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_zero_approx(input_dir):
		facing = 1 if input_dir > 0.0 else -1
		
		if is_on_floor():
			#En el suelo, el movimiento es instantáneo
			velocity.x = input_dir * (move_speed + dash_velocity)
		else:
			#En el aire
			var target_speed = input_dir * (move_speed + dash_velocity)
			#Si venimos del gancho y pulsamos la dirección contraria al movimiento
			if just_released_grapple and not is_zero_approx(velocity.x) and signf(input_dir) != signf(velocity.x):
				# Frenado, se reduce la velocidad actual hasta 0
				velocity.x = move_toward(velocity.x, 0.0, air_brake_accel * delta)
				#Si ya hemos frenado casi del todo, quitamos el estado para que pueda girar con normalidad
				if absf(velocity.x) < 0.1:
					just_released_grapple = false
			else:
				#Control aéreo normal
				velocity.x = move_toward(velocity.x, target_speed, air_control_accel)
	elif is_on_floor():
		#Solo frena en el suelo. En el aire conserva la inercia
		velocity.x = move_toward(velocity.x, 0, move_speed)
	#En el aire sin input no se toca velocity.x para conservar la inercia
	velocity.z = 0.0
	#else:
		#velocity.x = move_toward(velocity.x, 0, move_speed)

# alternate the movement of the player for 2D and 3D and the camera view
func changeMovementController() -> void:
	
	if not Input.is_action_just_pressed("ChangePerpective"):
		return
		
	if camera_manager and camera_manager.has_method("updateCamera"):
		camera_manager.updateCamera()
		
	if movement3DActivated:
		movement3DActivated = false
		
		global_position = original_position
		
		#Borra toda velocidad 3D para no salir del plano 2D
		velocity = Vector3.ZERO
		
		#Recupera el modelo 3D y lo mete como hijo de player
		if mesh: 
			var parent_scene = get_tree().current_scene
			mesh.reparent(self)
			#Se alinea de nuevo con el centro del personaje
			mesh.position = Vector3.ZERO
			mesh.rotation = Vector3.ZERO
			mesh.visible = true
		if mesh_ghost:
			mesh_ghost.visible = false
	else:
		movement3DActivated = true
		original_position = global_position
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
	
	fixedZ = global_position.z
	
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
