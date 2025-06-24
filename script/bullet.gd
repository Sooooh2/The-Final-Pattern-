extends CharacterBody2D

@onready var hit_s = $hit_sfx
@export var damage: int = 10
const speed = 500
var direction : Vector2
var timer = 0
var has_hit: bool = false

func _physics_process(delta: float) -> void:
	if has_hit:
		return

	velocity = direction * speed
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.is_in_group("player") or collider.is_in_group("enemy"):
			print("Bullet hit: ", collider.name)
			has_hit = true
			get_tree().change_scene_to_file("res://path_to_your_main_scene.tscn")

		if collider.has_method("take_damage"):
			collider.take_damage(damage)

		hit_s.play()
		hide() 
		set_deferred("collision_layer", 0)
		set_deferred("collision_mask", 0)
		await hit_s.finished
		queue_free()
		break
