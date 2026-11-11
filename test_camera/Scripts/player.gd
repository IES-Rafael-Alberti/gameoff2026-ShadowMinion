extends CharacterBody3D

@export_group("Speeds")
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
# Dash
@export var dash : float = 100.0
var tween: Tween
@export var dash_velocity : float = 0.0
@export_group("Balanceo")
# Aceleración horizontal que aplicas con izquierda/derecha mientras estás enganchado
@export var grapple_air_accel : float = 10.0
# Aceleración cuando empujnas en contra. Más baja para no frenar de golpe
@export var grapple_brake_accel : float = 4.0
#Velocidad horizontal máxima mientras empujas el balanceo
@export var grapple_max_speed : float = 22.0


var move_speed : float = 0.0
var movement3DActivated = false
var jumpCount = 1
#var have_position = false
var original_position = Vector3.ZERO
var facing:int = 1
var is_dead: bool = false



@onready var camera_manager: Node = $"../CameraManager"
@onready var collider: CollisionShape3D = $Collider

@onready var mesh: MeshInstance3D = $Mesh
@onready var mesh_ghost: MeshInstance3D = $MeshGhost

func _physics_process(delta: float) -> void:
	if not is_on_floor():
			velocity += get_gravity() * delta
			#Si caemos del borde sin saltar, se elimina un salto
			if jumpCount > 1:
				jumpCount = 1
	else:
		jumpCount = 1 if movement3DActivated else 2
	
	if Input.is_action_just_pressed("Jump"):
		if movement3DActivated:
			if is_on_floor():
				velocity.y = jump_velocity
		else:
			if jumpCount > 0:
				jumpCount -=1
				velocity.y = jump_velocity
		
			
	if Input.is_action_pressed("Sprint"):
			move_speed = sprint_speed
	else:
		move_speed = base_speed
		
	if movement3DActivated:
		movement3D()
	else:
		movement2D(delta)
		

	changeMovementController()
	accion_dash()
	
	move_and_slide()

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
	var input_dir := Input.get_axis("Left", "Right")
	#var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_zero_approx(input_dir):
		facing = 1 if input_dir > 0.0 else -1
		
	#Busca si el nodo del gancho está en uso
	var grapple_node = get_node_or_null("GrapplingController")
	var is_grappling:bool = grapple_node != null and grapple_node.launched
	
	if is_grappling:
		#empuja el balanceo
		if not is_zero_approx(input_dir):
			#Si empuja en contra del balanceo, se usa una aceleración más suave
			var accel = grapple_air_accel
			if input_dir * velocity.x < -0.5:
				accel = grapple_brake_accel
				
			velocity.x += input_dir * accel * delta
			velocity.x = clampf(velocity.x, -grapple_max_speed, grapple_max_speed)
	elif not is_zero_approx(input_dir):
		velocity.x = input_dir * (move_speed + dash_velocity)
	else:
		#Solo frena cuando no está colgado del techo
		velocity.x = move_toward(velocity.x, 0, move_speed)
	#else:
		#velocity.x = move_toward(velocity.x, 0, move_speed)

func changeMovementController() -> void:
	if Input.is_action_just_pressed("ChangePerpective"):
		if camera_manager and camera_manager.has_method("updateCamera"):
			camera_manager.updateCamera()
		if movement3DActivated:
			movement3DActivated = false
			global_position = original_position
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
			#if have_position == false:
				#have_position = true
				#original_position = global_position
				#return
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

func _ready() -> void:
	movement3DActivated = false
	original_position = global_position
	
	if mesh: 
		mesh.visible = true
	if mesh_ghost:
		mesh_ghost.visible = false

func accion_dash():
	if Input.is_action_just_pressed("dash"):
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
