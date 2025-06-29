extends Control


func _on_start_pressed():
	$"../Transition".get_child(0).play("Close")
	await $"../Transition".get_child(0).animation_finished
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scene/Shop/Shop.tscn")

func _on_tutorial_pressed():
	$"../Transition".get_child(0).play("Close")
	await $"../Transition".get_child(0).animation_finished
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scene/Testing/Test.tscn")
