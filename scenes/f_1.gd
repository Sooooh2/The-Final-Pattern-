extends Sprite2D

@onready var ufo = $ufo
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ufo.play()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
