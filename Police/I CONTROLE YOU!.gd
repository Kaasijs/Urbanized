extends RigidBody2D

@export var PlayerNode:CharacterBody2D
@onready var RaycastNode:RayCast2D = $RayCast2D

@export var Speed:float = 75
@export var SpeedDistance:float = 2.3

# Called every frame. 'delta' is the elapsed time since the previous frame.

var ArrayTagetSmell:Array = []
var Index:int

var GoToTheFanashing:bool = false

var TargetPreviuesPosition:Vector2

func _physics_process(delta):
	if freeze:
		return
	
	var PlayerGlobalPositionRounded:Vector2 = round(PlayerNode.global_position/32)*32 - Vector2(16,-16)
	
	RaycastNode.global_position = global_position
	RaycastNode.target_position = PlayerNode.global_position - RaycastNode.global_position
	
	if ArrayTagetSmell == []:
			ArrayTagetSmell.append(round(PlayerGlobalPositionRounded))
		
	if ArrayTagetSmell[len(ArrayTagetSmell)-1].distance_to(PlayerNode.global_position) > 15:
		ArrayTagetSmell.append(round(PlayerGlobalPositionRounded))
	
	
	if RaycastNode.get_collider() == PlayerNode:
		ArrayTagetSmell = []
		GoToTheFanashing= false
		Index=0
		
		linear_velocity = Vector2(RaycastNode.target_position).normalized()*Speed + Vector2(RaycastNode.target_position)/SpeedDistance
		#print(Vector2(RaycastNode.target_position).normalized())
		
		#print(ArrayTagetSmell)
		
		if len(ArrayTagetSmell) > 10:
			for i in len(ArrayTagetSmell)-10:
				ArrayTagetSmell.remove_at(0)
		
	else:
		var LastTargetDirection = Vector2(ArrayTagetSmell[0] - round(RaycastNode.global_position/32)*32 - Vector2(0,0))
		
		#print(global_position.distance_to(ArrayTagetSmell[0]))
		
		if global_position.distance_to(ArrayTagetSmell[0]) < 30:
			ArrayTagetSmell.remove_at(0)
		
		
		#print(LastTargetDirection.normalized())
		var taget_position = global_position.distance_to(PlayerNode.global_position) * LastTargetDirection.normalized()
		linear_velocity = (LastTargetDirection.normalized()*Speed) + taget_position/SpeedDistance
	
	
	TargetPreviuesPosition = round(PlayerGlobalPositionRounded)


func _on_area_2d_body_entered(body):
	if body.has_method("is_player"):
		$CanvasLayer/Death.death()
