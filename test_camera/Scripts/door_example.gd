extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var message_without_key: Label3D = get_node_or_null("Message_without_key") as Label3D
# Aquí pon el nombre exacto que le hayas dado al Area3D de la puerta en lvl_2
@onready var interaction_area = $InteractionArea 
# Ruta a la llave (asumiendo que es hermana de la puerta en lvl_2)
# En lvl_2 la llave está en la raíz, bajo "Monedas(llaves)"
@onready var key_example: Area3D = $"../../../Monedas(llaves)/key_example" as Area3D

var showing_message = false
var door_opened = false

func _ready() -> void:
	if message_without_key:
		message_without_key.hide()
		
	# Conectamos el área de interacción con nuestra función
	if interaction_area:
		interaction_area.interact = _on_interact_door

func _on_interact_door() -> void:
	if door_opened:
		return
		
	# Comprobamos si la llave ya se ha cogido
	if key_example and key_example.key_taken == true:
		if message_without_key:
			message_without_key.hide()
		door_opened = true
		animation_player.play("open_door")
		
		if interaction_area:
			interaction_area.monitoring = false
			interaction_area.queue_free()
	else:
		if message_without_key and not showing_message:
			showing_message = true
			message_without_key.show()
			
			await get_tree().create_timer(2.0).timeout
			
			if is_instance_valid(message_without_key):
				message_without_key.hide()
			showing_message = false
