extends RayCast3D


var current_object


func _process(_delta: float) -> void:
	if is_colliding():
		var object = get_collider()
		if object == current_object:
			return
		else:
			current_object = object
	else:
		current_object = null
