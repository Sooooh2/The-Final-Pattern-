extends Node2D

@onready var sound = $start_sfx
@export var pin_scene: PackedScene
@export var max_lines_allowed := 20

@export var rows := 8
@export var cols := 12
@export var spacing := Vector2(25, 25)
@export var origin := Vector2(430, 140)

var selected_pins: Array = []
func _input(event):
	if event.is_action_pressed("next_scene"):
		get_tree().change_scene_to_file("res://scenes/puzzle.tscn")
	if Input.is_action_just_pressed("end_scene"):
		_fix_constellation()


	# replace with your actual reference scene path

func _ready():
	sound.play()
	_generate_grid()

func _generate_grid():
	for row in range(rows):
		for col in range(cols):
			var pin = pin_scene.instantiate()
			pin.position = origin + Vector2(col, row) * spacing
			pin.name = "Pin_" + str(row) + "_" + str(col)
			add_child(pin)
			pin.connect("pin_clicked", Callable(self, "_on_pin_clicked"))

func _on_pin_clicked(pin: Area2D):
	print("🎯 Grid received click from: ", pin.name)

	# Optional: draw a simple line between last two pins
	selected_pins.append(pin)
	if selected_pins.size() >= 2:
		var line = Line2D.new()
		line.default_color = Color.YELLOW
		line.width = 2
		line.add_point(selected_pins[-2].global_position)
		line.add_point(selected_pins[-1].global_position)
		add_child(line)


func _fix_constellation():
	set_process(false)
	set_process_input(false)
	
	print("✅ Puzzle fixed!")
	get_tree().change_scene_to_file("res://scenes/end_scene.tscn")  # use your real path
