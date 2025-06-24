extends Node2D

@onready var bg = $AudioStreamPlayer2D

@onready var frames = [
	$convo1,
	$convo2,
	$convo3,
	$convo4,
	$convo5,
	$convo6
]

var current_frame = 0

func _ready():
	bg.play()
	# Show only the first frame
	for i in range(frames.size()):
		frames[i].visible = (i == 0)

func _input(event):
	if event.is_action_pressed("next_scene"):

		advance_cutscene()

func advance_cutscene():
	# Hide current frame
	if current_frame < frames.size():
		frames[current_frame].visible = false
		current_frame += 1

		# Show next frame if there is one
		if current_frame < frames.size():
			frames[current_frame].visible = true
		else:
			emit_signal("cutscene_finished")
			get_tree().change_scene_to_file("res://scenes/ckt.tscn")  
			
			
