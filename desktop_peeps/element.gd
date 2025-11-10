extends Node2D
const WIDTH = 80
const HEIGHT = 95

var size_factor = 1

var settings_visible = false


func set_mouse_passthrough_window():
	var a = $element_area/CollisionShape2D.polygon.duplicate()
	for i in range(len(a)):
		a[i] += global_position
	DisplayServer.window_set_mouse_passthrough(a)


func _ready():
	global_position = Vector2(500, 500)
	$element_area/CollisionShape2D.polygon = PackedVector2Array(
		[size_factor * Vector2(-WIDTH, -HEIGHT),
		size_factor * Vector2(WIDTH, -HEIGHT),
		size_factor * Vector2(WIDTH, HEIGHT),
		size_factor * Vector2(-WIDTH, HEIGHT)]
	)
	set_mouse_passthrough_window()

# for dragging/sizing
var dragging = false
var offset = Vector2(0,0)
var original_scale = Vector2(1,1)

func _process(delta):
	if dragging:
		if not settings_visible:
			global_position.x = get_global_mouse_position().x - offset.x
			global_position.y = get_global_mouse_position().y - offset.y
		# checking settings size stuff
		else: # changed relative to previous
			size_factor = (get_global_mouse_position()-global_position).length() / offset.length() * original_scale.x
			self.scale = size_factor * Vector2(1,1)
			$element_area/CollisionShape2D.polygon = PackedVector2Array(
				[size_factor * Vector2(-WIDTH, -HEIGHT),
				size_factor * Vector2(WIDTH, -HEIGHT),
				size_factor * Vector2(WIDTH, HEIGHT),
				size_factor * Vector2(-WIDTH, HEIGHT)]
			)
		
		set_mouse_passthrough_window()
	

# note (you can see in godot gui editor) that main button is child of settings button
# this is because for the mouse filter pass - propogate up, it passes up to parent, not for siblings/drawing order
# this mean in order to have a separate left/right click i gotta just make one the child of another and its dum and 
#  theres prob a better way to do it but idc rn
func button_pressed():
	$SettingsButton/Button.disabled = true
	
	var r = randi_range(1,3)
	$AnimatedSprite2D.animation = str(r)
	if r == 1:
		# change size of window and then after animation plays, change back
		$element_area/CollisionShape2D.polygon = PackedVector2Array(
			[size_factor * Vector2(-WIDTH, -HEIGHT * 1.8),
			size_factor * Vector2(WIDTH, -HEIGHT * 1.8),
			size_factor * Vector2(WIDTH, HEIGHT),
			size_factor * Vector2(-WIDTH, HEIGHT)]
		)
		set_mouse_passthrough_window()
		$AnimatedSprite2D.play()
		await $AnimatedSprite2D.animation_finished
		$element_area/CollisionShape2D.polygon = PackedVector2Array(
			[size_factor * Vector2(-WIDTH, -HEIGHT),
			size_factor * Vector2(WIDTH, -HEIGHT),
			size_factor * Vector2(WIDTH, HEIGHT),
			size_factor * Vector2(-WIDTH, HEIGHT)]
		)
		set_mouse_passthrough_window()
		if not settings_visible:
			$SettingsButton/Button.disabled = false
		return
	$AnimatedSprite2D.play()
	await $AnimatedSprite2D.animation_finished
	if not settings_visible:
		$SettingsButton/Button.disabled = false

# for resize rn
func settings_button():
	if not settings_visible:
		settings_visible = true
		$SettingsButton/Button.disabled = true
		$SettingsButton/Button.set_default_cursor_shape(11)
	else:
		settings_visible = false
		$SettingsButton/Button.disabled = false
		$SettingsButton/Button.set_default_cursor_shape(0)
