extends Area2D


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			get_parent().dragging = true
			get_parent().offset = get_global_mouse_position() - global_position
		else:
			get_parent().dragging = false
