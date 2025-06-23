extends CharacterBody2D

@export var PlayerIndex:int

@export var Aceleration:float = 7.0
@export var MaxSpeed:float = 300.0
@export var Jumpheight:float = -400.0
@export var JabComboMax:int = 3

#Animation stuff
@onready var VisualNode:AnimatedSprite2D = $AnimatedSprite2D
var PrevieusFrame:int
var PrevieusAnimation:String

#Actions and stuff
var PrevieusAction:String
@export var BodyCollition:CollisionShape2D
@export var JabArea:Area2D
@export var UpcutArea:Area2D
@export var DownArea:Area2D

#General Input values/varibles
var direction:float

#Debug
@onready var DebugLabelCooldown = $"../CanvasLayer/Cooldown"
@onready var DebugLabelAnimation = $"../CanvasLayer/Animation"


func _physics_process(delta) -> void:
	#Reset floor snap
	floor_snap_length = 5
	#Get Slop normal angel
	var SlopNormal = rad_to_deg(get_floor_normal().angle())+90
	var IsOnSlop:bool = abs(SlopNormal) > 42 and abs(SlopNormal) < 47
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Jumping
	if not Cooldown > 0:
		# Handle jump.
		if Input.is_action_just_pressed("Jump"+"_"+str(PlayerIndex)) and is_on_floor():
			SpawnPuff(jump_particale)
			velocity.y = Jumpheight
			
		# Get the input direction and handle the movement/deceleration.
		if is_on_floor():
			direction = lerp(direction, Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex)), delta * 10)
		else:
			direction = lerp(direction, Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex)), delta * 3)
	
	#Slope fix :) 
	if abs(SlopNormal) > 42 and abs(SlopNormal) < 47:
		velocity.x = velocity.x*1.95 + velocity.y*1.2
		velocity.y = velocity.y
		if Input.is_action_pressed("Down"+"_"+str(PlayerIndex)):
			if SlopNormal > 0:
				direction = 1
			else:
				direction = -1
			velocity.x = velocity.x + (SlopNormal*34) * (delta * 3)
			if not Input.is_action_pressed("Jump"+"_"+str(PlayerIndex)):
				velocity.y=0
				floor_snap_length = 30
				apply_floor_snap()
			else:
				velocity.x += velocity.x*0.29
				velocity.y += velocity.x*0.13
	
	if not Cooldown > 0:
		if abs(direction) > 0.1:
			velocity.x = lerpf(velocity.x,direction * MaxSpeed, delta * Aceleration)
		else:
			velocity.x = lerpf(velocity.x, 0 , delta * 11)
	else:
		if is_on_floor():
			velocity.x = lerpf(velocity.x, 0 , delta * 11)
	
	
	move_and_slide()
	
	#Slope fix 2
	if abs(SlopNormal) > 42 and abs(SlopNormal) < 47:
		velocity.x = velocity.x/2
	
	# Visualize moving dicretion
	if direction > 0.1:
		VisualNode.scale.x = 2
	elif direction < -0.1:
		VisualNode.scale.x = -2

func _on_damage_dealt(DealtDamage:float,Agressor):
	print(str(self) + "	" + str(DealtDamage) + "	Damage by	" + str(Agressor))

func _process(delta) -> void:
	animate(delta)
	PrevieusFrame = VisualNode.frame
	PrevieusAnimation = VisualNode.animation
	
	pixel_perfect()
	
	action(delta)
	PrevieusAction = VisualNode.animation
	
	damage(delta)
	
	DebugLabelAnimation.text = VisualNode.animation

func damage(delta) -> void:
	BodyCollition.disabled = false
	
	var ListOfAttackAreas:Array = [JabArea,UpcutArea,DownArea]
	for i:Area2D in ListOfAttackAreas: 
		i.get_child(0).disabled = true
	
	var ListOfCustomAreaActions:Array = ["At-Jab","At-Upcut","Down"]
	if not ListOfCustomAreaActions.has(PrevieusAction):
		return
	
	if VisualNode.animation == "At-Jab" and VisualNode.frame == 1:
		JabArea.get_child(0).disabled = false
	if VisualNode.animation == "At-Upcut" and VisualNode.frame == 3:
		UpcutArea.get_child(0).disabled = false
	if VisualNode.animation == "Down":
		DownArea.get_child(0).disabled = false
	
	pass

#Fighting shit
var Cooldown:float
var CurrentAttack:String
#	Specials
#uppercut
var MidAirUpCutUsed:bool = false
#Cobmo jabs
var JabCombo:int = 999

func action(delta) -> void:
	#Special Upercut machaniced delays
	if is_on_floor():
		MidAirUpCutUsed = false
	if PrevieusAction == "At-Upcut" and VisualNode.frame == 3 and MidAirUpCutUsed==false:
		if is_on_floor():
			SpawnPuff(jump_particale)
			velocity.y = Jumpheight*1.1
			MidAirUpCutUsed = true
		else:
			velocity.y = Jumpheight/2
			MidAirUpCutUsed = true
	
	#At-Jab Combo
	if Input.is_action_just_pressed("At-Jab"+"_"+str(PlayerIndex)) and VisualNode.animation == "At-Jab" and Cooldown > 0 and Cooldown < 4.2 and JabCombo < JabComboMax:
		print(JabCombo)
		velocity.x = direction * 150
		JabCombo += 1
		Cooldown = 5
		VisualNode.stop()
		VisualNode.play("At-Jab")
		
	#Cooldown logic
	if Cooldown > 0:
		Cooldown += -delta*8
		DebugLabelCooldown.text = "Cooldown: " + str(Cooldown)
		return
	
	#Jab Action
	if Input.is_action_just_pressed("At-Jab"+"_"+str(PlayerIndex)):
		print("New Jab")
		velocity.x = direction * 200
		JabCombo = 1
		Cooldown = 5
		VisualNode.play("At-Jab")
	#Upper cut Action
	if Input.is_action_just_pressed("At-Upcut"+"_"+str(PlayerIndex)) and (MidAirUpCutUsed==false or is_on_floor()):
		MidAirUpCutUsed = false
		Cooldown = 6.5
		VisualNode.play("At-Upcut")
	if Input.is_action_pressed("Down"+"_"+str(PlayerIndex)):
		velocity.y += direction * -10 * delta
		#Cooldown = 1.4
		VisualNode.play("Down")

func pixel_perfect() -> void:
	VisualNode.global_position = round(global_position/2)*2
	
func animate(delta) -> void:
	if Cooldown > 0:
		return
	VisualNode.speed_scale = 1
	
	#Jumping
	if velocity.y > 0.1:
		VisualNode.animation = "Jump"
		VisualNode.set_frame_and_progress(0,0)
		
		return
	if velocity.y < -0.2:
		VisualNode.animation = "Jump"
		VisualNode.set_frame_and_progress(2,0)
		return
	
	#Running
	if abs(Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex))) < 0.3 and is_on_floor():
		VisualNode.play("Idle")
		return
	elif abs(Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex))) > 0.3 and abs(velocity.x) > 15 and is_on_floor():
		VisualNode.play("Run")
		VisualNode.speed_scale = lerpf(0.3,1,abs(velocity.x/MaxSpeed))
		
		#Particle
		if (VisualNode.frame == 0 and PrevieusFrame != 0) or (VisualNode.frame == 4 and PrevieusFrame != 4) or PrevieusAnimation != "Run":
			SpawnPuff(run_particale)
		return

var run_particale = preload("res://Player/Debug/Run/Particels/Run_Particels.tscn")
var jump_particale = preload("res://Player/Debug/Jump/Particels/Jump_Particels.tscn")

func SpawnPuff(ParticalType:PackedScene) -> void:
	var particale = ParticalType.instantiate()
	particale.global_position = global_position
	if Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex)) > 0:
		particale.scale.x = 2
	else:
		particale.scale.x = -2
	self.add_child(particale)
	particale = null
	return
