extends Node

@onready var _2d_camera: PhantomCamera3D = $"2DCamera"
@onready var _3d_camera: PhantomCamera3D = $"3DCamera"

var camera3DActive = false

func updateCamera() -> void:
	if Input.is_action_just_pressed("ChangePerpective"):
		print("change camera")
		if camera3DActive:
			_2d_camera.priority = 1
			_3d_camera.priority = 0
		else:
			_2d_camera.priority = 0
			_3d_camera.priority = 1
