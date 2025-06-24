extends CharacterBody2D

signal healthChanged
signal enemy_died
@onready var enemy_dead = $enemy_ded 

@export var fire_rate: float = 0.5
@export var speed: float = 50.0
@export var currHealth: int = 30
@export var bullet_spawn_distance: float = 35.0
@export var rotation_speed: float = TAU * 2
@export var player: Node2D

var time_since_last_shot = 0.0
var direction: Vector2

const bulletEPre = preload("res://scenes/enemy_bullet.tscn")

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return

	direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	_rotate_towards_player(delta)

	time_since_last_shot += delta
	if time_since_last_shot >= fire_rate:
		_shoot()
		time_since_last_shot = 0.0

func _rotate_towards_player(delta: float) -> void:
	var target_angle = direction.angle()
	var angle_diff = wrapf(target_angle - rotation, -PI, PI)
	rotation += clamp(angle_diff, -rotation_speed * delta, rotation_speed * delta)

func _shoot() -> void:
	var bullet = bulletEPre.instantiate()
	bullet.global_position = global_position + (direction * bullet_spawn_distance)
	bullet.direction = direction
	get_parent().add_child(bullet)

func take_damage(amount: int) -> void:
	currHealth -= amount
	healthChanged.emit()
	if currHealth <= 0:
		print("music shuould play")
		enemy_dead.play()
		enemy_died.emit()
		queue_free()
