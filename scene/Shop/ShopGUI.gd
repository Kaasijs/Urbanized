extends Control

func _process(delta):
	if Public.Score != 0:
		Public.SavedScore += Public.Score
		Public.Score = 0
	
	$Score.text = "You have " + str(Public.SavedScore) + " style points "

var city := preload("res://scene/Map 1/NewTownCity.tscn")
func _on_tutorial_pressed():
	$"../Transition".get_child(0).play("Close")
	await $"../Transition".get_child(0).animation_finished
	await get_tree().create_timer(1).timeout
	
	get_tree().change_scene_to_packed(city)
