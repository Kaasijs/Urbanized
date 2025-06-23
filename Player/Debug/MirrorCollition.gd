extends CollisionShape2D

@export var VisualNode:AnimatedSprite2D

var EditorX:float

func _ready():
	EditorX = position.x

func _process(delta):
	position.x = EditorX*(abs(VisualNode.scale.x)/VisualNode.scale.x)
