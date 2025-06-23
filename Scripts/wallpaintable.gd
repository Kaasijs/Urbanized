extends Area2D

func _painted():
	self.queue_free()
	return


func _on_body_entered(body):
	if body.has_method("is_player"):
		body._entered_paintable(self)


func _on_body_exited(body):
	if body.has_method("is_player"):
		body._exited_paintable()
