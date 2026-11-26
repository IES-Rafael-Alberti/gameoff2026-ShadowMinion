extends BaseEnemy

# Para detecta precipicios
func _is_floor_ahead(dir:Vector3) -> bool:
	#Si el enemigo ya está en el aire, devolvemos false para que deje de moverse
	if not is_on_floor() or dir == Vector3.ZERO:
		return false
	
	var space_state = get_world_3d().direct_space_state
	
	#Calculamos un punto 0.8 metros por delante y un poco elevado respecto a la base del enemigo
	var ray_start = global_position + dir.normalized() * 0.8 + Vector3.UP * 0.2
	# El rayo apunta 1.5 metros hacia abajo
	var ray_end = ray_start + Vector3.DOWN * 1.5
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	#Ignora el propio cuerpo del enemigo
	query.exclude = [get_rid()] 
	
	var result = space_state.intersect_ray(query)
	# Devuelve true si el rayo tocó el suelo, false si detectó vacío/precipicio
	return not result.is_empty()

# Sobreescribe la función de dirección del BaseEnemy
func _get_move_direction() -> Vector3:
	# Le pedimos al padre (BaseEnemy) que calcule la dirección (hacia el jugador)
	var dir = super._get_move_direction()
	
	# Si hay una dirección (es decir, nos estamos moviendo)
	if dir != Vector3.ZERO:
		# Comprobamos si delante de esa dirección hay suelo
		if not _is_floor_ahead(dir):
			return Vector3.ZERO # Si hay precipicio, frenamos en seco
			
	# Si hay suelo, devolvemos la dirección normal para que siga persiguiendo
	return dir
