extends CharacterBody3D

@export_group("Speeds")
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0

var move_speed : float = 0.0
var movement3DActivated = true
var jumpCount = 1


@onready var collider: CollisionShape3D = $Collider
@onready var _2d_camera: PhantomCamera3D = $"../CameraManager/2DCamera"
@onready var outsideCamera: PhantomCamera3D = $"../CameraManager/OutsideCamera"
@onready var insideCamera: PhantomCamera3D = $"../CameraManager/InsideCamera"

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
		
func movement2D() ->void:
	var input_dir := Input.get_axis("Left", "Right")
	#var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if input_dir:
		velocity.x = input_dir * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

func changeMovementController() -> void:
	if Input.is_action_just_pressed("ChangePerpective"):
		if movement3DActivated:
			movement3DActivated = false
			_2d_camera.priority = 1
			active3DCamera.priority = 0
		else:
			movement3DActivated = true
			_2d_camera.priority = 0
			active3DCamera.priority = 1


func _on_area_3d_body_entered(body: Node3D) -> void:
	if active3DCamera == outsideCamera:
		outsideCamera.priority = 0
		active3DCamera = insideCamera
	else:
		insideCamera.priority = 0
		active3DCamera = outsideCamera

	active3DCamera.priority = 1
