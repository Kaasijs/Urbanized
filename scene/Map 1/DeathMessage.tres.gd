extends Label

func _ready():
	$"..".hide()

func _process(delta):
	$"../ColorRect".scale = Vector2(1,1)

func death():
	$"../ColorRect".scale = Vector2(1,0)
	
	$"../../../../Player 1".Cooldown = 3
	
	get_parent().show()
	
	text = " BUSTED! \nlost " + str(Public.Score) + " style point"
	Public.Score = 0
	
	$"../AnimationPlayer".play("wawu")
	
	await get_tree().create_timer(3).timeout
	
	get_tree().change_scene_to_file("res://scene/Shop/Shop.tscn")
