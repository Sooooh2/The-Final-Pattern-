extends Sprite2D

@onready var whale = $whale_sound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	whale.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
