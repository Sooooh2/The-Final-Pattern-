extends Node2D

# Reference to player
var player: CharacterBody2D = null

# Health bar sprite nodes - make sure these match your actual node names
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
	# Find the player using the group system (since you added player to "player" group)
	await get_tree().process_frame  # Wait one frame to ensure everything is loaded
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as CharacterBody2D
		
		# Connect to player's health changed signal
		if player.has_signal("healthChanged"):
			player.healthChanged.connect(_on_health_changed)
			print("Connected to player health signal!")
		
		# Show initial health bar
		update_health_display()
	else:
		print("No player found in 'player' group!")

func _on_health_changed():
	# This function is called whenever the player's health changes
	update_health_display()

func update_health_display():
	if not player:
		return
	
	# Get current health and clamp it
	var current_health = clamp(player.health, 0, 100)
	
	# Round down to nearest 10 for the sprite key
	var health_key = int(floor(current_health / 10.0) * 10)
	
	# Handle edge case: if health is between 1-9, show 10% sprite
	if current_health > 0 and health_key == 0:
		health_key = 10
	
	print("Player health: ", current_health, " -> Showing sprite: ", health_key)
	
	# Hide all sprites first
	hide_all_sprites()
	
	# Show the appropriate sprite
	var target_sprite = health_sprites.get(health_key)
	if target_sprite:
		target_sprite.visible = true
		current_shown_sprite = target_sprite
		print("Health bar updated to: ", health_key, "%")
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
	if player:
		player.health = test_health
		update_health_display()
