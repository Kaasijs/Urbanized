extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("1")

func _on_animation_finished() -> void:
	self.queue_free()
