extends Node2D

func _ready():
	get_tree().get_root().set_transparent_background(true)


func _on_transparency_button_pressed() -> void:
	get_tree().get_root().transparent = !get_tree().get_root().transparent
