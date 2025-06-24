extends CanvasLayer

signal transitioned
func _ready() -> void:
	_transition()

func _transition():
	$AnimationPlayer.play("fade_to_balck")
	print("fading to balck")
	
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black": 
		emit_signal("transitioned")
		$AnimationPlayer.play("fade_to_normal")
	
