extends Area2D

@onready var PaintedNode = $"../../../Painted"

func _ready():
	$"../Paint".hide()

func _painted():
	$"../Paint".show()
	Public.AddScore(Public.PaintReward,global_position)
	
	get_parent().add_to_group("painted")
	self.queue_free()

func _process(delta):
	$Canvas.offset.y = sin(Time.get_ticks_msec()/200)

func _on_body_entered(body):
	if body.has_method("is_player"):
		body._entered_paintable(self)


func _on_body_exited(body):
	if body.has_method("is_player"):
		body._exited_paintable()
