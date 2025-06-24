extends Node2D

# Reference to enemy
var enemy: CharacterBody2D = null

# Enemy health bar sprite nodes - make sure these match your actual node names
@onready var health_sprites = {
	100: $"100",
	90: $"90",
	80: $"80",
	70: $"70",
	60: $"60",
	50: $"50",
	40: $"40",
	30: $"30",
	20: $"20",
	10: $"10",
	0: $"0"
}

var current_shown_sprite: Node = null

func _ready():
	# Find the enemy using the group system (since enemy is added to "enemy" group)
	await get_tree().process_frame  # Wait one frame to ensure everything is loaded
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() > 0:
		enemy = enemies[0] as CharacterBody2D
		
		# Connect to enemy's health changed signal
		if enemy.has_signal("healthChanged"):
			enemy.healthChanged.connect(_on_health_changed)
			print("Connected to enemy health signal!")
		
		# Show initial health bar
		update_health_display()
	else:
		print("No enemy found in 'enemy' group!")

func _on_health_changed():
	# This function is called whenever the enemy's health changes
	update_health_display()

func update_health_display():
	if not enemy:
		return
	
	# Get current health and clamp it (using currHealth for enemy)
	var current_health = clamp(enemy.currHealth, 0, 100)
	
	# Round down to nearest 10 for the sprite key
	var health_key = int(floor(current_health / 10.0) * 10)
	
	# Handle edge case: if health is between 1-9, show 10% sprite
	if current_health > 0 and health_key == 0:
		health_key = 10
	
	print("Enemy health: ", current_health, " -> Showing sprite: ", health_key)
	
	# Hide all sprites first
	hide_all_sprites()
	
	# Show the appropriate sprite
	var target_sprite = health_sprites.get(health_key)
	if target_sprite:
		target_sprite.visible = true
		current_shown_sprite = target_sprite
		print("Enemy health bar updated to: ", health_key, "%")
	else:
		print("ERROR: No sprite found for health key: ", health_key)

func hide_all_sprites():
	# Hide all health bar sprites
	for sprite in health_sprites.values():
		if sprite:
			sprite.visible = false

# Optional: Manual update function you can call for testing
func force_update():
	update_health_display()

# For testing - you can call this from anywhere to test different health values
func test_health_display(test_health: int):
	if enemy:
		enemy.currHealth = test_health
		update_health_display()

# If you have multiple enemies, you can specify which one to track
func set_target_enemy(target_enemy: CharacterBody2D):
	# Disconnect from old enemy if exists
	if enemy and enemy.has_signal("healthChanged"):
		enemy.healthChanged.disconnect(_on_health_changed)
	
	# Connect to new enemy
	enemy = target_enemy
	if enemy and enemy.has_signal("healthChanged"):
		enemy.healthChanged.connect(_on_health_changed)
		update_health_display()

# Alternative setup for when you know the enemy's node path
func connect_to_enemy_by_path(enemy_path: String):
	var target_enemy = get_node_or_null(enemy_path) as CharacterBody2D
	if target_enemy:
		set_target_enemy(target_enemy)
	else:
		print("Enemy not found at path: ", enemy_path)
