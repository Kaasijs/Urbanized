extends Node2D

@export var PlayerNode:CharacterBody2D

func _process(delta):
	_get_painted_walls()

var part_wall_instance := preload("res://Player/Painter/Part_wall.tscn")
func _get_painted_walls():
	var ListOfPaintedWalls:Array[Node2D] = [] 
	for i in get_children():
		if i.is_in_group("painted"):
			#Check if there are in range
			if i.global_position.distance_to(PlayerNode.global_position) > 800:
				ListOfPaintedWalls.append(i)
	
	if len(ListOfPaintedWalls) > 1:
		var IndexWallOfBestResult:int = 0
		var WallCompareDistance:float = 0
		
		#for i in len(ListOfPaintedWalls):
			#var distance = ListOfPaintedWalls[i].global_position.distance_to(PlayerNode.global_position)
			#if WallCompareDistance <= distance:
				#WallCompareDistance = distance
				#IndexWallOfBestResult = i
		
		IndexWallOfBestResult = randi_range(0,len(ListOfPaintedWalls)-1)
		
		print(IndexWallOfBestResult)
		var cleaning = part_wall_instance.instantiate()
		ListOfPaintedWalls[IndexWallOfBestResult].add_child(cleaning)
		ListOfPaintedWalls[IndexWallOfBestResult].remove_from_group("painted")
