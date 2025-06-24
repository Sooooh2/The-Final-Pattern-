extends Area2D

signal pin_clicked(pin: Area2D)

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("✅ Pin clicked:", name)
			emit_signal("pin_clicked", self)
