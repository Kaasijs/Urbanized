extends Node2D

var animated_value:float = 0
var locked_amount:int = 0

func update(amount):
	locked_amount = amount
	
	if amount <= 100:
		$AnimationPlayer.play("1")
	
	else:
		$AnimationPlayer.play("10")
	
func _process(delta):
	var steps:float = locked_amount/5
	
	
	animated_value = lerpf(animated_value,locked_amount,delta*5)
	
	$Label.text = str(int(roundi(animated_value/steps)*steps))


func _on_animation_player_animation_finished(anim_name):
	queue_free()
