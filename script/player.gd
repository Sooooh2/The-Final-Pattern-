extends CharacterBody2D
#variables ---------------------------------------------------------------------
signal healthChanged
@onready var player_ded = $player_dead
@export var rotation_speed : float = TAU * 2
@export var bullet_spawn_distance: float = 30.0
var theta : float
var speed = 300
var _direction : Vector2
var timer = 0 
const bulletPre = preload("res://scenes/bullet.tscn")
@export var health: int = 100

#calculating damage ------------------------------------------------------------
func take_damage(amount: int) -> void:
	health -= amount
	print("Player took ", amount, " damage. Health: ", health)
	healthChanged.emit() # This signal will update the health bar
	if health <= 0:
		game_over()

#game over ---------------------------------------------------------------------
func game_over() -> void:
	player_ded.play()
	get_tree().change_scene_to_file("res://scenes/lost_game_1.tscn") 
	print("Game Over!")

#ready -------------------------------------------------------------------------
func _ready() -> void:
	add_to_group("player")

#player movement ---------------------------------------------------------------
func _move(direction : Vector2):
	direction = Vector2(Input.get_axis("left","right"),Input.get_axis("up","down"))
	velocity = direction * speed
	_direction = direction 
	move_and_slide()

#so that the ship does not go out of bounds ------------------------------------
func _teleport():
	if(position.y <-1):
		position.y = 450
	if(position.y >450):
		position.y = -1
	if(position.x <-1):
		position.x = 900
	if(position.x >900):
		position.x = -1

#for player shooting -----------------------------------------------------------
func _shoot(delta): 
	var bullet = bulletPre.instantiate()
	get_parent().add_child(bullet)
	# Calculate direction from player to mouse
	var shoot_direction = (get_global_mouse_position() - global_position).normalized()
	# DYNAMICALLY spawn bullet in the direction of shooting
	bullet.global_position = global_position + (shoot_direction * bullet_spawn_distance)
	bullet.direction = shoot_direction

#for rotation  while moving ----------------------------------------------------
func _rotate(delta, direction: Vector2):
	if _direction: 
		theta = wrap(atan2(_direction.y, _direction.x) - rotation,-PI,PI)
		rotation += clamp(rotation_speed *delta, 0, abs(theta) * sin(theta))
		look_at(position + _direction)

#calling all the functions here ------------------------------------------------
func _process(delta: float) -> void:
	_move(_direction)  # Fixed: removed * and added _
	_teleport()
	_rotate(delta, _direction)  # Fixed: removed * and added _
	timer += delta
	if (Input.is_action_just_pressed("shoot") && timer > 0.3):
		_shoot(delta)
		timer = 0  # Reset timer after shooting
