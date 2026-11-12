class_name Player extends CharacterBody3D

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

var move_speed : float = 0.0
var movement3DActivated = true
var jumpCount = 1

var original_position = Vector3.ZERO

@onready var camera_manager: Node = $"../CameraManager"
@onready var collider: CollisionShape3D = $Collider
@onready var _2d_camera: PhantomCamera3D = $"../CameraManager/2DCamera"
@onready var outsideCamera: PhantomCamera3D = $"../CameraManager/OutsideCamera"
@onready var insideCamera: PhantomCamera3D = $"../CameraManager/InsideCamera"

@onready var mesh: MeshInstance3D = $Mesh
@onready var mesh_ghost: MeshInstance3D = $MeshGhost

var cameras3D = [outsideCamera, insideCamera]
var active3DCamera = outsideCamera

func _physics_process(delta: float) -> void:
	if not is_on_floor():
			velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("Jump") and jumpCount > 0:
			jumpCount -=1
			velocity.y = jump_velocity
			
	if Input.is_action_pressed("Sprint"):
			move_speed = sprint_speed
	else:
		move_speed = base_speed
		
	if movement3DActivated:
		movement3D()
	else:
		movement2D()
		
	if is_on_floor():
		jumpCount = 1
	changeMovementController()
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
		
# Basic movement for 2D enviroment
func movement2D() ->void:
	var input_dir := Input.get_axis("Left", "Right")
	if input_dir:
		velocity.x = input_dir * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

# alternate the movement of the player for 2D and 3D and the camera view
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
	if Input.is_action_just_pressed("Dash"):
		dash_velocity = dash
		if tween:
			tween.stop()
		tween = create_tween()
		tween.tween_property(self, "dash_velocity", 0, 0.2).set_ease(Tween.EASE_OUT)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if active3DCamera == outsideCamera:
		outsideCamera.priority = 0
		active3DCamera = insideCamera
	else:
		insideCamera.priority = 0
		active3DCamera = outsideCamera

	active3DCamera.priority = 1
	
func _getMovement3DActive():
	return movement3DActivated
