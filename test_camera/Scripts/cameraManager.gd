extends Node

@onready var _2d_camera: PhantomCamera3D = $"2DCamera"
@onready var _3d_camera: PhantomCamera3D = $"3DCamera"
@onready var outsideCamera: PhantomCamera3D = $"../CameraManager/OutsideCamera"
@onready var insideCamera: PhantomCamera3D = $"../CameraManager/InsideCamera"



var camera3DActive = false
var active3DCamera:PhantomCamera3D = null

func _ready() -> void:
	_2d_camera.priority = 1
	outsideCamera.priority = 0
	insideCamera.priority = 0
	camera3DActive = false
	active3DCamera = outsideCamera

func updateCamera() -> void:
	camera3DActive = !camera3DActive
	if camera3DActive:
		_2d_camera.priority = 0
		active3DCamera.priority = 1
	else:
		_2d_camera.priority = 1
		outsideCamera.priority = 0
		insideCamera.priority = 0
