extends Node2D

@onready var sound = $start_sfx
func _input(event):
	if event.is_action_pressed("next_scene"):
		get_tree().change_scene_to_file("res://scenes/ckt.tscn")

func _ready() -> void:
	sound.play()
