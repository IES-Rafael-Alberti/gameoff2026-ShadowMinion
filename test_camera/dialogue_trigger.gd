extends Node3D

@export_file("*.dtl") var dialogo: String
#@export var can_be_replayed: bool = false
var played = false

@onready var area_3d: Area3D = $Area3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and played == false:
		if dialogo.is_empty():
			push_warning("No se ha asignado un timeline de Dialogic.")
			return
		played = true
		Dialogic.start(dialogo)
		await Dialogic.timeline_ended
		#if can_be_replayed:
			#played = false

func _ready() -> void:
	await get_tree().physics_frame
	for body in area_3d.get_overlapping_bodies():
		_on_area_3d_body_entered(body)
