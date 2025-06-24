extends CanvasLayer

var amount:int = 5

var index:int = -1
var TextureArray:Array =[
	"res://Player/Painter/Textures/up.png",
	"res://Player/Painter/Textures/down.png",
	"res://Player/Painter/Textures/left.png",
	"res://Player/Painter/Textures/right.png"
]
var InputMapArray:Array =[
	"Jump_0",
	"Down_0",
	"Left_0",
	"Right_0"
]

var FailureTexts:Array =[
	"Bad layers!",
	"Paint dripping!",
	"Uneven Coverage!",
	"Paint Spitting!",
	"Over sprayed!",
	"Lack of Patience!",
	"Rushing or Dragging?",
	"To bad.",
	"Eww!",
	"your trolling."
]

var GreatTexts:Array =[
	"Turbo roasting it!",
	"Absolute cinema!",
	"harry your a wizard.",
	"Thats topshelf spaghetti!",
	"gordon ramsay would be proud!",
	"Nice job!",
	"Your getting good!",
	"slaying!",
	"Thats bussin",
	"Fire",
	"Your gucci ganging that shit!"
]

func _start():
	index = 0
	print(InputMap.get_actions())
	
	for i in amount:
		_add_action()

func _add_action():
	var i2 = randi_range(0,len(TextureArray)-1)
	var new := TextureRect.new()
	
	new.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	new.texture = load(TextureArray[i2])
	
	new.set("tooltip_text",InputMapArray[i2])
	
	$ColorRect/HBoxContainer.add_child(new)


var action: TextureRect
func _process(delta):
	if index == -1:
		return
	
	if index < amount:
		action = $ColorRect/HBoxContainer.get_child(index)
	else:
		escape_good()
		print("Painting")
	
	if action != null:
		if InputMap.get_actions().has(action.tooltip_text):
			if Input.is_action_just_pressed(str(action.tooltip_text)):
				action.modulate = Color(1,1,1,0.2)
				
				$D.play()
				$D.pitch_scale = 0.5 + index*0.1
				
				var tween = get_tree().create_tween()
				tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
				tween.tween_property(action, "position", action.position + Vector2(0,15),0.2)
				tween.tween_property(action, "modulate", Color(1,1,1,0.2),0.2)
				
				index += 1
			else:
				for OtherInputs:String in InputMapArray:
					if Input.is_action_just_pressed(OtherInputs):
						index = -1
						
						$D.pitch_scale = 0.
						$D.play()
						
						action.modulate = Color.RED
						action.position.y += 10
						escape_bad()
						print("BAD input")
		else:
			escape_bad()
			print("BAD actions loop")
	
func escape_good():
	index = -1
	$ColorRect/Text.text = GreatTexts.pick_random()
	
	$AnimationPlayer.play("Good")
	await $AnimationPlayer.animation_finished
	
	get_parent()._on_painterminigame_compleation()
	
	queue_free()

func escape_bad():
	index = -1
	$ColorRect/Text.text = FailureTexts.pick_random()
	
	$AnimationPlayer.play("Bad")
	await $AnimationPlayer.animation_finished
	queue_free()
