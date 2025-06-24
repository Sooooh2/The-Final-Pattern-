extends Node2D


@onready var sound = $title
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _input(event):
	if event.is_action_pressed("next_scene"):
		get_tree().change_scene_to_file("res://scenes/starting_scene.tscn") 
