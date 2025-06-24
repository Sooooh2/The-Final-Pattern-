extends Node2D

@onready var game = $game_sound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game.play()
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("next_scene"):
		get_tree().change_scene_to_file("res://scenes/whale_convo.tscn")  
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
