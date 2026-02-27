extends Node2D
const WIDTH = 80
const HEIGHT = 95

var size_factor = 1

var settings_visible = false
var animation_playing = false

enum Mode {
	idle,
	working
}

var shape_type = "idle" # in set_shape()

var mode = Mode.idle # default value

var countdown= 60 # seconds

var rng = RandomNumberGenerator.new()

func set_mouse_passthrough_window():
	var a = $element_area/CollisionShape2D.polygon.duplicate()
	for i in range(len(a)):
		a[i] += global_position
	DisplayServer.window_set_mouse_passthrough(a)


func _ready():
	global_position = Vector2(500, 500)
	set_shape("idle")
	
	$working_mode_button.visible = false
	$idle_mode_button.visible = false
	

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
			if mode == Mode.idle:
				set_shape("settings_idle")
			elif mode == Mode.working:
				set_shape("settings_working")
		
		set_mouse_passthrough_window()
	
	if mode == Mode.working:
		countdown -= delta
		if countdown <= 0:
			return
			$AnimatedSprite2D.stop()
			$AnimatedSprite2D.animation = "Head_Smashing_Moogie"
			set_shape("Head_Smashing_Moogie")
			$AnimatedSprite2D.play()
			await $AnimatedSprite2D.animation_finished
			set_shape("Working_Moogie")
			$AnimatedSprite2D.animation = "Working_Moogie"
			$AnimatedSprite2D.play()
			countdown = rng.randf_range(1 * 60, 15 * 60) # b/t 1 and 15 minutes, uniform distribution
	

# called by element_area upon left click released
func button_pressed():
	if mode != Mode.idle || settings_visible || animation_playing:
		return
	
	var r = randi_range(1,3)
	var type = "idle"
	if r == 1:
		type = "1 expanded"
	play_animation(str(r), type)
	
	"""$AnimatedSprite2D.animation = str(r) # animations are named 1,2,3
	if r == 1:
		# change size of window and then after animation plays, change back
		$element_area/CollisionShape2D.polygon = PackedVector2Array(
			[size_factor * Vector2(-WIDTH, -HEIGHT * 1.8),
			size_factor * Vector2(WIDTH, -HEIGHT * 1.8),
			size_factor * Vector2(WIDTH, HEIGHT),
			size_factor * Vector2(-WIDTH, HEIGHT)]
		)
		set_mouse_passthrough_window()
		animation_playing = true
		$AnimatedSprite2D.play()
		await $AnimatedSprite2D.animation_finished
		animation_playing = false
		if not settings_visible:
			set_shape("idle")
		
		##if not settings_visible:
			##$SettingsButton/Button.disabled = false
		return
	animation_playing = true
	$AnimatedSprite2D.play()
	await $AnimatedSprite2D.animation_finished
	animation_playing = false"""

# plays animation, disables left click during
# params - animation_name - corresponds to AnimationSprite2D
#        - hitbox_type - to change to during animation for function set_shape
func play_animation(animation_name, hitbox_type):
	var original_shape_type = get_shape()
	$AnimatedSprite2D.animation = animation_name
	set_shape(hitbox_type)
	animation_playing = true
	$AnimatedSprite2D.play()
	await $AnimatedSprite2D.animation_finished
	animation_playing = false
	if not settings_visible:
		set_shape(original_shape_type)

# for resize rn and toggle between idle and working
# called by element_area right_click pressed
func settings_button():
	if not settings_visible:
		settings_visible = true
		$idle_mode_button.visible = true
		$working_mode_button.visible = true
		if mode == Mode.idle:
			set_shape("settings_idle")
		elif mode == Mode.working:
			set_shape("settings_working")
		
		##$SettingsButton/Button.set_default_cursor_shape(11)
	else:
		settings_visible = false
		$idle_mode_button.visible = false
		$working_mode_button.visible = false
		if mode == Mode.idle:
			set_shape("idle")
		elif mode == Mode.working:
			set_shape("Working_Moogie")
		
		##$SettingsButton/Button.set_default_cursor_shape(0)

# for setting hitbox since it needs to be like explicit for some reason idk duping didn't work maybe i just used
# wrong func idk
func set_shape(type):
	match type:
		"idle":
			shape_type = "idle"
			$element_area/CollisionShape2D.polygon = PackedVector2Array(
				[size_factor * Vector2(-WIDTH, -HEIGHT),
				size_factor * Vector2(WIDTH, -HEIGHT),
				size_factor * Vector2(WIDTH, HEIGHT),
				size_factor * Vector2(-WIDTH, HEIGHT)]
			)
			$AnimatedSprite2D.scale = Vector2(.9, .9)
			$AnimatedSprite2D.offset = Vector2(260, 780)
		"settings_idle":
			shape_type = "settings_idle"
			$element_area/CollisionShape2D.polygon = PackedVector2Array(
				[size_factor * Vector2(-WIDTH, -HEIGHT),
				size_factor * Vector2(0,-HEIGHT),
				size_factor * Vector2(0,-2 * HEIGHT),
				size_factor * Vector2(2 * WIDTH, -2 * HEIGHT),
				size_factor * Vector2(2 * WIDTH, 0),
				size_factor * Vector2(WIDTH, 0),
				size_factor * Vector2(WIDTH, HEIGHT),
				size_factor * Vector2(-WIDTH, HEIGHT)
				]
			)
			$AnimatedSprite2D.scale = Vector2(.9, .9)
			$AnimatedSprite2D.offset = Vector2(260, 780)
		"settings_working":
			shape_type = "settings_moogie"
			$element_area/CollisionShape2D.polygon = PackedVector2Array(
				[size_factor * Vector2(-WIDTH, -HEIGHT),
				size_factor * Vector2(0,-HEIGHT),
				size_factor * Vector2(0,-2 * HEIGHT),
				size_factor * Vector2(2 * WIDTH, -2 * HEIGHT),
				size_factor * Vector2(2 * WIDTH, 0),
				size_factor * Vector2(WIDTH*2, 0),
				size_factor * Vector2(WIDTH*2, HEIGHT),
				size_factor * Vector2(-WIDTH, HEIGHT)
				]
			)
			$AnimatedSprite2D.scale = Vector2(.9, .9)
			$AnimatedSprite2D.offset = Vector2(260, 780)
		"1 expanded":
			shape_type = "1 expanded"
			$element_area/CollisionShape2D.polygon = PackedVector2Array(
				[size_factor * Vector2(-WIDTH, -HEIGHT * 1.8),
				size_factor * Vector2(WIDTH, -HEIGHT * 1.8),
				size_factor * Vector2(WIDTH, HEIGHT),
				size_factor * Vector2(-WIDTH, HEIGHT)]
			)
			$AnimatedSprite2D.scale = Vector2(.9, .9)
			$AnimatedSprite2D.offset = Vector2(260, 780)
		"Working_Moogie":
			$element_area/CollisionShape2D.polygon = PackedVector2Array(
				[size_factor * Vector2(-WIDTH, -HEIGHT * 1.8),
				size_factor * Vector2(WIDTH * 2, -HEIGHT * 1.8),
				size_factor * Vector2(WIDTH * 2, HEIGHT),
				size_factor * Vector2(-WIDTH, HEIGHT)]
			)
			$AnimatedSprite2D.scale = Vector2(.3, .3)
			$AnimatedSprite2D.offset = Vector2(120, -60)
		"Head_Smashing_Moogie":
			pass
		_:
			print("idk this kind of hitbox type!!!")
	set_mouse_passthrough_window()

func get_shape():
	return shape_type

func mouse_entered_area() -> void:
	#set_process(true)
	if settings_visible:
		Input.set_default_cursor_shape(11)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)



func mouse_exited_area() -> void:
	#set_process(false)
	Input.set_default_cursor_shape(0)



# dmoe mode types------------------------------------
func working_mode_button_pressed():
	mode = Mode.working
	$AnimatedSprite2D.animation = "Working_Moogie"
	set_shape("settings_working")
	animation_playing = true
	$AnimatedSprite2D.play()


func idle_mode_button_pressed():
	mode = Mode.idle
	$AnimatedSprite2D.animation = "1"
	set_shape("settings_idle")
	animation_playing = false
	$AnimatedSprite2D.stop()
