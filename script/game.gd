extends Node2D

@onready var start_sound = $start_sfx
var enemy_scene = preload("res://scenes/smaller_enemey.tscn")
var max_enemies = 2
var current_enemy_count = 0

func _on_timer_timeout():
	if current_enemy_count >= max_enemies:
		return

	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(20, 1000), -20)
	enemy.scale = Vector2(1, 2)
	add_child(enemy)

	# Connect death signal
	enemy.enemy_died.connect(_on_enemy_ded)
	current_enemy_count += 1

func _on_enemy_ded():
	current_enemy_count -= 1



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_sound.play()

func _hit_excape():
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://scenes/starting_scene.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
