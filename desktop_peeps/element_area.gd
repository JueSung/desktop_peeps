extends Area2D

# not using _input_event() because causing issues with getting stuck to mouse
func _process(delta):
	if Input.is_action_just_pressed("left_click"):
		get_parent().dragging = true
		get_parent().offset = get_global_mouse_position() - get_parent().global_position
		get_parent().original_scale = get_parent().scale
	elif Input.is_action_just_released("left_click"):
		get_parent().dragging = false
