extends CanvasLayer

var amount:int = 4

var index:int = 0
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

func _ready():
	for i in amount:
		_add_action()

func _add_action():
	var new := TextureRect.new()
	var i2 = randi_range(0,len(TextureArray)-1)
	
	new.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	new.texture = load(TextureArray[i2])
	new.name = InputMapArray[i2]
	print("newbaby")
	$ColorRect/HBoxContainer.add_child(new)


var action: TextureRect
func _process(delta):
	action = $ColorRect/HBoxContainer.get_child(index)
	if Input.is_action_just_pressed(str(action.name)):
		action.modulate = Color.GREEN
		index += 1
	
func _input(event):
	if action != null:
		# Controleer of het een InputEventAction is (bv. een actie zoals "jump", "shoot", etc.)
		if event is InputEventAction:
			if event.pressed:
				var action_name = event.action
				print("Andere actie:", action_name)
