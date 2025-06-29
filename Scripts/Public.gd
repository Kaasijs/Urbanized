extends Node

#Shop
var ListOfItemsBought:Array = []
var SelectedItem:String = ""

#Painting
var PaintSteps:int = 2
var PaintReward:int = 500

#Score keeping
var Score:int = 0
var SavedScore:int = 0
var score_updater := preload("res://Player/ScoreKeeper/ScoreUpdate.tscn")
func AddScore(amount,global_position):
	Score += amount
	
	print(Score)
	
	var display := score_updater.instantiate()
	display.global_position = global_position
	display.update(amount)
	add_child(display)

#Atlases
var AtlasListLadders:Array = [
	Vector2i(3, 0), #DEBUG LADER
	Vector2i(3, 1), #CITY LADER
	Vector2i(3, 3), #WOOD LADER
	]

#In game currents
var CurrentPlayer:CharacterBody2D
