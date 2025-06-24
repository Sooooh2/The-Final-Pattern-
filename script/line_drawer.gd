extends Node2D

var start_pin: Area2D = null
var current_line: Line2D = null
var all_connections: Array = []
var current_path: Array[Area2D] = []

# Line visual settings
@export var drawing_color: Color = Color.YELLOW
@export var completed_color: Color = Color.WHITE
@export var line_width: float = 3.0

# Connection rules
@export var allow_diagonal_connections: bool = true
@export var max_connection_distance: float = 2.0

signal shape_completed(pins: Array[Area2D])
signal connection_made(pin_a: Area2D, pin_b: Area2D)

func _ready():
	await get_tree().process_frame
	var pins = get_tree().get_nodes_in_group("pin_nodes")
	for pin in pins:
		if pin.has_signal("pin_clicked"):
			pin.connect("pin_clicked", Callable(self, "_on_pin_clicked"))
		else:
			print("Pin missing signal: ", pin.name)

func _on_pin_clicked(pin: Area2D):
	print("🎯 Pin clicked: ", pin.name)
	
	if start_pin == null:
		_start_connection(pin)
	else:
		if pin != start_pin and _can_connect_to(pin):
			_complete_connection(pin)
		else:
			_cancel_connection()

func _start_connection(pin: Area2D):
	start_pin = pin
	current_path = [pin]
	pin.set_selected(true)
	
	current_line = Line2D.new()
	current_line.default_color = drawing_color
	current_line.width = line_width
	current_line.add_point(pin.global_position)
	current_line.add_point(pin.global_position)
	add_child(current_line)

func _complete_connection(pin: Area2D):
	current_path.append(pin)
	
	# Create the actual connection
	start_pin.add_connection(pin)
	pin.add_connection(start_pin)
	
	# Finalize the line
	current_line.set_point_position(1, pin.global_position)
	current_line.default_color = completed_color
	
	# Store connection data
	var connection_data = {
		"pin_a": start_pin,
		"pin_b": pin,
		"line": current_line,
		"path": current_path.duplicate()
	}
	all_connections.append(connection_data)
	
	# Emit signals
	emit_signal("connection_made", start_pin, pin)
	
	# Check if this completes a shape
	_check_for_completed_shapes()
	
	# Reset for next connection
	start_pin.set_selected(false)
	_reset_connection_state()

func _cancel_connection():
	if current_line:
		current_line.queue_free()
	if start_pin:
		start_pin.set_selected(false)
	_reset_connection_state()

func _reset_connection_state():
	start_pin = null
	current_line = null
	current_path.clear()

func _can_connect_to(pin: Area2D) -> bool:
	if not start_pin or pin == start_pin:
		return false
	
	# Check if already connected
	if start_pin.connections.has(pin):
		return false
	
	# Check distance based on grid positions
	var distance = _get_grid_distance(start_pin, pin)
	return distance <= max_connection_distance

func _get_grid_distance(pin_a: Area2D, pin_b: Area2D) -> float:
	if not (pin_a.has_method("grid_position") and pin_b.has_method("grid_position")):
		# Fallback to position-based distance
		return pin_a.global_position.distance_to(pin_b.global_position) / 30.0 # Approximate grid units
	
	var pos_a = pin_a.grid_position if "grid_position" in pin_a else Vector2.ZERO
	var pos_b = pin_b.grid_position if "grid_position" in pin_b else Vector2.ZERO

	if allow_diagonal_connections:
		# Euclidean distance for diagonal connections
		return Vector2(pos_a - pos_b).length()
	else:
		# Manhattan distance for orthogonal only
		return abs(pos_a.x - pos_b.x) + abs(pos_a.y - pos_b.y)

func _check_for_completed_shapes():
	# Simple shape detection - look for closed loops
	var visited = {}
	var shapes = []
	
	var all_pins = get_tree().get_nodes_in_group("pin_nodes")
	for pin in all_pins:
		if not visited.has(pin) and pin.connections.size() > 0:
			var shape = _trace_connected_component(pin, visited)
			if _is_closed_shape(shape):
				shapes.append(shape)
				emit_signal("shape_completed", shape)

func _trace_connected_component(start_pin: Area2D, visited: Dictionary) -> Array[Area2D]:
	var component = []
	var stack = [start_pin]
	
	while not stack.is_empty():
		var current_pin = stack.pop_back()
		if visited.has(current_pin):
			continue
			
		visited[current_pin] = true
		component.append(current_pin)
		
		for connected_pin in current_pin.connections:
			if not visited.has(connected_pin):
				stack.append(connected_pin)
	
	return component

func _is_closed_shape(pins: Array[Area2D]) -> bool:
	# A closed shape needs at least 3 pins, and each pin should have exactly 2 connections
	if pins.size() < 3:
		return false
	
	for pin in pins:
		if pin.connections.size() != 2:
			return false
	
	return true

func clear_all_connections():
	"""Clear all connections and lines"""
	# Clear visual lines
	for connection in all_connections:
		if connection.line:
			connection.line.queue_free()
	
	# Clear connection data from pins
	var pins = get_tree().get_nodes_in_group("pin_nodes")
	for pin in pins:
		pin.clear_connections()
	
	all_connections.clear()
	print("All connections cleared")

func _process(delta):
	# Update current drawing line to follow mouse
	if current_line and start_pin:
		var mouse_pos = get_global_mouse_position()
		current_line.set_point_position(1, mouse_pos)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if start_pin:
				_cancel_connection()
			else:
				clear_all_connections()
