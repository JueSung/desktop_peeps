extends Node2D

func _ready():
	global_position = Vector2(500, 500)
	var a = $element_area/CollisionShape2D.polygon.duplicate()
	for i in range(len(a)):
		a[i] += global_position
	DisplayServer.window_set_mouse_passthrough(a)





var dragging = false
var offset = Vector2(0,0)


func _process(delta):
	if dragging:
		global_position.x = get_global_mouse_position().x - offset.x
		global_position.y = get_global_mouse_position().y - offset.y
		var a = $element_area/CollisionShape2D.polygon.duplicate()
		for i in range(len(a)):
			a[i] += global_position
		DisplayServer.window_set_mouse_passthrough(a)
