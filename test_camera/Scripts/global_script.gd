extends Node

var checkpoint_pos: Vector3 = Vector3(-999, -999, -999)
var previous_checkpoint_node: Area3D = null
var intro_dialogue_seen: bool = false
var is_3d_mode: bool = false
var next_spawn_pos: Vector3 = Vector3.ZERO
var use_next_spawn: bool = false
var _hook_hidden_material: StandardMaterial3D = null

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	call_deferred("hide_esconder_gancho_feo")

func _on_node_added(nodo: Node) -> void:
	if nodo is CSGBox3D and nodo.is_in_group("grappleable"):
		_esconder_gancho(nodo)

func hide_esconder_gancho_feo() -> void:
	for nodo in get_tree().get_nodes_in_group("esconder_gancho_feo"):
		_esconder_gancho(nodo)

func _get_hook_hidden_material() -> StandardMaterial3D:
	if _hook_hidden_material == null:
		_hook_hidden_material = StandardMaterial3D.new()
		_hook_hidden_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_hook_hidden_material.albedo_color = Color(1.0, 1.0, 1.0, 0.0)
		_hook_hidden_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_hook_hidden_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	return _hook_hidden_material

func _esconder_gancho(nodo: Node) -> void:
	if not nodo.is_in_group("esconder_gancho_feo"):
		nodo.add_to_group("esconder_gancho_feo")
	# En CSG, visible=false excluye el hijo del brush y quita la colisión del combiner.
	# Mantenemos visible=true y ocultamos solo el render con un material alpha 0.
	if "visible" in nodo:
		nodo.visible = true
	if "material" in nodo:
		nodo.set("material", _get_hook_hidden_material())

func set_3d_mode(active: bool) -> void:
	is_3d_mode = active
	for nodo in get_tree().get_nodes_in_group("only_in_3d_mode"):
		if "visible" in nodo:
			nodo.visible = active
		
		#Pausa la lógica y la física si no está activo
		if active:
			nodo.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			nodo.process_mode = Node.PROCESS_MODE_DISABLED
