extends Node2D

@onready var whale = $f2/whale_sound
@onready var title = $title/title
@onready var ship = $f1/ufo

@onready var frames = [
	$title,
	$f1,
	$f2,
	$f3,
	$f4,
	$f6
]

var current_frame = 0

func _ready():
	title.play()
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
			get_tree().change_scene_to_file("res://scenes/game.tscn")  
			

	# Play sounds at specific frames
	if current_frame == 4: 
		whale.stop()
	if current_frame == 2:
		
		whale.play()
	if current_frame == 1:
		title.stop()
		ship.play()
		
