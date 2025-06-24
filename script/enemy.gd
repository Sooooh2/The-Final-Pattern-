extends CharacterBody2D

#variables ---------------------------------------------------------------------
signal healthChanged  # Add this signal for health bar updates
@onready var enemy_dead = $enemy_dead
@export var fire_rate: float = 1 
@export var rotation_speed : float = TAU * 2
@export var speed = 10
@export var bullet_spawn_distance: float = 35.0  # Distance to spawn bullets away from enemy
@onready var enemy_anim = $AnimationPlayer
@export var player: Node2D 
@export var currHealth: int = 100

var time_since_last_shot = 0.0
var theta : float
var _direction : Vector2
var timer = 0

const bulletEPre = preload("res://scenes/enemy_bullet.tscn")

#calculating enemy damage ------------------------------------------------------------------
func take_damage(amount: int) -> void:
	currHealth -= amount
	print("Enemy took ", amount, " damage. Health: ", currHealth)
	healthChanged.emit()  # Emit signal when health changes
	if currHealth <= 0:
		_game_over()
		enemy_dead.play()

#you won -----------------------------------------------------------------------
func _game_over() -> void:
	print("Enemy died!")
	get_tree().change_scene_to_file("res://scenes/won_game_1.tscn") 
	   
	queue_free()

#enemy shooting -----------------------------------------------------------------
func _shoot(delta):
	if player == null:
		return

	var dir_to_player = (player.global_position - global_position).normalized()
	var vertical_spread = [-10, 0, 10] 
	var spread_angle = deg_to_rad(10) 

	for i in range(vertical_spread.size()):
		var bullet = bulletEPre.instantiate()

		# Calculate spawn position OUTSIDE the enemy ship
		var spawn_direction = dir_to_player
		var spawn_position = global_position + (spawn_direction * bullet_spawn_distance)

		# Add the vertical offset
		var y_offset = vertical_spread[i]
		var offset = Vector2(0, y_offset).rotated(dir_to_player.angle())
		bullet.global_position = spawn_position + offset

		# Set bullet direction with spread
		var angle_offset = spread_angle * (i - (vertical_spread.size() - 1) / 2.0)
		bullet.direction = dir_to_player.rotated(angle_offset)
		get_parent().add_child(bullet)

#rotation while moving function ---------------------------------------------------
func _rotate(delta, direction: Vector2):
	if direction != Vector2.ZERO:
		var target_angle = direction.angle()
		var angle_diff = wrapf(target_angle - rotation, -PI, PI)
		rotation += clamp(angle_diff, -rotation_speed * delta, rotation_speed * delta)

#ready ------------------------------------------------------------------------------
func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	if enemy_anim:
		enemy_anim.play("enemy_ship")

#calling other functions ---------------------------------------------------------
func _physics_process(delta):
	if player == null:
		return
		
	time_since_last_shot += delta
	timer += delta
	
	# Calculate direction to player
	var direction = global_position.direction_to(player.global_position)
	_direction = direction 
	
	# FIXED: Only use ONE movement method, not multiple!
	velocity = direction * speed
	move_and_slide()
	
	# Shoot at intervals
	if time_since_last_shot >= fire_rate:
		_shoot(delta)
		time_since_last_shot = 0.0
	
	# Check for collision with player after movement
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider == player:
			print("Enemy collided with player - game over!")
			# Handle collision with player
			if player.has_method("game_over"):
				player.game_over()

#added rotation in this process function -------------------------------------------
func _process(delta: float) -> void:
	_rotate(delta, _direction)

# Alternative _shoot method for spread pattern with better positioning --------------
func _shoot_spread_pattern(delta):
	if player == null:
		return
		
	var dir_to_player = (player.global_position - global_position).normalized()
	var spread_angles = [-15, 0, 15]  # degrees
	
	for angle_deg in spread_angles:
		var bullet = bulletEPre.instantiate()
		
		# Calculate spawn position outside enemy
		var spawn_direction = dir_to_player
		bullet.global_position = global_position + (spawn_direction * bullet_spawn_distance)
		
		# Set bullet direction with spread
		var angle_rad = deg_to_rad(angle_deg)
		bullet.direction = dir_to_player.rotated(angle_rad)
		
		get_parent().add_child(bullet)

# Method for distance-based shooting (shoot more when closer to player) ---------
func _shoot_distance_based(delta):
	if player == null:
		return
		
	var distance_to_player = global_position.distance_to(player.global_position)
	var base_fire_rate = fire_rate
	
	# Shoot faster when closer to player
	if distance_to_player < 200:
		base_fire_rate = fire_rate * 0.5  # Shoot twice as fast
	elif distance_to_player < 100:
		base_fire_rate = fire_rate * 0.25  # Shoot 4x as fast
	
	if time_since_last_shot >= base_fire_rate:
		var dir_to_player = (player.global_position - global_position).normalized()
		var bullet = bulletEPre.instantiate()
		
		bullet.global_position = global_position + (dir_to_player * bullet_spawn_distance)
		bullet.direction = dir_to_player
		
		get_parent().add_child(bullet)
		time_since_last_shot = 0.0
