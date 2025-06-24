extends CharacterBody2D

@onready var hit_s = $hit_sfx
@export var damage: int = 5
@export var speed: float = 300.0

var direction: Vector2
var timer = 0.0
var has_hit: bool = false

func _process(delta: float) -> void:
	timer += delta
	position += direction * speed * delta
	if timer > 5:
		queue_free()

func _physics_process(_delta: float) -> void:
	if has_hit:
		return

	var velocity = direction * speed
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.is_in_group("player"):
			print("Enemy bullet hit player!")
			has_hit = true

			if collider.has_method("take_damage"):
				collider.take_damage(damage)

			hit_s.play()
			hide()
			set_deferred("collision_layer", 0)
			set_deferred("collision_mask", 0)
			await hit_s.finished
			queue_free()
			break

func _on_area_entered(area: Area2D) -> void:
	if has_hit:
		return

	if area.is_in_group("player") or area.is_in_group("enemy"):
		print("Bullet (Area2D) also detected a hit.")
		hit_s.play()
		hide()
		set_deferred("collision_layer", 0)
		set_deferred("collision_mask", 0)
		has_hit = true
		await hit_s.finished
		queue_free()
