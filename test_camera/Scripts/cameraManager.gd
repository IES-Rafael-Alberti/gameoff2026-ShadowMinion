extends Node

@onready var _2d_camera: PhantomCamera3D = $"2DCamera"
@onready var outsideCamera: PhantomCamera3D = $"../CameraManager/OutsideCamera"
@onready var insideCamera: PhantomCamera3D = $"../CameraManager/InsideCamera"

var camera3DActive = false
var active3DCamera:PhantomCamera3D = null
# El maze fija la cámara;updateCamera() (botón E) queda bloqueado mientras tanto
var camera_locked: bool = false

func _ready() -> void:
	_2d_camera.priority = 1
	outsideCamera.priority = 0
	insideCamera.priority = 0
	camera3DActive = false
	active3DCamera = outsideCamera
	print("2dCamera priority: ", _2d_camera.priority)
	print("outsideCamera: ", outsideCamera.priority)

func updateCamera() -> void:
	if camera_locked:
		return
	camera3DActive = !camera3DActive
	if camera3DActive:
		_2d_camera.priority = 0
		active3DCamera.priority = 1
	else:
		_2d_camera.priority = 1
		outsideCamera.priority = 0
		insideCamera.priority = 0

func set_inside_3d_camera() -> void:
	camera_locked = true
	_2d_camera.priority = 0
	outsideCamera.priority = 0
	insideCamera.priority = 1
	camera3DActive = true
	active3DCamera = insideCamera
	print("Cámara cambiada a: InsideCamera (3D)")

func set_2d_camera() -> void:
	camera_locked = false
	_2d_camera.priority = 1
	outsideCamera.priority = 0
	insideCamera.priority = 0
	camera3DActive = false
	# La E de fuera del maze debe volver a usar OutsideCamera, no InsideCamera
	active3DCamera = outsideCamera
	print("Cámara cambiada a: 2D")
