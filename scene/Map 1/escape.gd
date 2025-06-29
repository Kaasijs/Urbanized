extends Area2D

#@onready var PaintedNode = $"../../../Painted"

func _process(delta):
	$Canvas.offset.y = sin(Time.get_ticks_msec()/200)

func _on_body_entered(body):
	if body.has_method("is_player"):
		body._entered_escape()


func _on_body_exited(body):
	if body.has_method("is_player"):
		body._exited_escape()
