extends Node2D

@export var PlayerNode:CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.

var ArrayTagetSmell:Array = []
var ArrayTagetLooks:Array = []
var ArrayTagetLooksf:Array = []
var ArrayTagetLooksS:Array = []
var ArrayTagetLooksR:Array = []

var GoToTheFanashing:bool = false

var TargetPreviuesPosition:Vector2

var time:float

func _process(delta):
	time += delta
	
	ArrayTagetSmell.append(PlayerNode.global_position)
	ArrayTagetLooks.append(PlayerNode.VisualNode.animation)
	ArrayTagetLooksf.append(PlayerNode.VisualNode.frame)
	ArrayTagetLooksS.append(PlayerNode.VisualNode.speed_scale)
	ArrayTagetLooksR.append(PlayerNode.VisualNode.scale)
	
	#print(ArrayTagetLooks[0])
	
	var r = 3
	
	#print(round(r/delta))
	
	
	if len(ArrayTagetSmell) > round(r/delta):
		var DirectionNext:Vector2 = global_position - ArrayTagetSmell[0]
		var DirectionPlayer:Vector2 = global_position - PlayerNode.global_position
		
		#print(
			#str(DirectionNext) +
			#str(DirectionPlayer)
			#)
		
		
		global_position = lerp(global_position,ArrayTagetSmell[0],clamp(delta*20,0,1))
		$AnimatedSprite2D.animation = ArrayTagetLooks[0]
		$AnimatedSprite2D.frame
		$AnimatedSprite2D.set_frame_and_progress(ArrayTagetLooksf[0],0)
		$AnimatedSprite2D.speed_scale = ArrayTagetLooksS[0]
		$AnimatedSprite2D.scale = ArrayTagetLooksR[0]
		
		for i in range(len(ArrayTagetSmell)-round(r/delta)):
			ArrayTagetSmell.remove_at(0)
			ArrayTagetLooks.remove_at(0)
			ArrayTagetLooksf.remove_at(0)
			ArrayTagetLooksS.remove_at(0)
			ArrayTagetLooksR.remove_at(0)


func _on_area_2d_body_entered(body):
	if len(ArrayTagetSmell) < 10:
		return
	
	if body.has_method("is_player"):
		#get_tree().quit()
		#body.Busted(self)
		
		pass
