extends RigidBody2D

@export var PlayerNode:CharacterBody2D

@onready var RaycastNode:RayCast2D = $RayCast2D

# Called every frame. 'delta' is the elapsed time since the previous frame.

var ArrayTagetSmell:Array = []
var Index:int

var GoToTheFanashing:bool = false

var TargetPreviuesPosition:Vector2

func _physics_process(delta):
	RaycastNode.global_position = global_position
	RaycastNode.target_position = PlayerNode.global_position - RaycastNode.global_position
	
	if RaycastNode.get_collider() == PlayerNode:
		ArrayTagetSmell = []
		GoToTheFanashing= false
		Index=0
		
		linear_velocity = Vector2(RaycastNode.target_position).normalized()*20 + Vector2(RaycastNode.target_position)/1.5
	
	else:
		if ArrayTagetSmell == []:
			ArrayTagetSmell.append(TargetPreviuesPosition)
		
		if ArrayTagetSmell[len(ArrayTagetSmell)-1].distance_to(PlayerNode.global_position) > 20:
			ArrayTagetSmell.append(TargetPreviuesPosition)
		
		var LastTargetDirection = Vector2(ArrayTagetSmell[0] - RaycastNode.global_position)
		
		if global_position.distance_to(ArrayTagetSmell[0]) < 80:
			print(Index)
			ArrayTagetSmell.remove_at(0)
			
		
		if !GoToTheFanashing:
			linear_velocity = LastTargetDirection * global_position.distance_to(PlayerNode.global_position)/200
	
	
	TargetPreviuesPosition = PlayerNode.global_position
