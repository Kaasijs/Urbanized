extends CharacterBody2D

@export var TileMapNode:TileMapLayer

@export var PlayerIndex:int

@export var Aceleration:float = 7.0
@export var MaxSpeed:float = 300.0
@export var MaxSpeedSlope:float = 350.0
@export var MaxSpeedLader:float = 300.0
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
@export var DownArea:Area2D

#General Input values/varibles
var direction:float

func is_player() -> void:
	return

func _ready():
	Public.CurrentPlayer = self


var SlopeMomentum:float
var SlopeInitVelocity:float
var initSlop:bool = false

var previeus_velocity:Vector2 = Vector2.ZERO
var previeus_global_position:Vector2 = Vector2.ZERO

#Player related stuff

func _physics_process(delta) -> void:
	#RESET FLOOR SNAP. See slope fix for why
	floor_snap_length = 15
	
	#Get Slop normal angel
	var SlopNormal = rad_to_deg(get_floor_normal().angle())+90
	var IsOnSlop:bool = abs(SlopNormal) > 42 and abs(SlopNormal) < 47
	
	#Is sliding
	if IsOnSlop and initSlop:#Input.is_action_pressed("Down"+"_"+str(PlayerIndex)):
		if SlopNormal > 0 and direction < 0:
			direction = 1
			
			if initSlop:
				velocity.x = velocity.x * -1
				previeus_velocity.x = previeus_velocity.x *-1
			
		if SlopNormal < 0 and direction > 0:
			direction = -1
			
			if initSlop:
				velocity.x = velocity.x * -1
				previeus_velocity.x = previeus_velocity.x *-1
	
	#Not sliding
	else:
		#handle movement/deceleration.
		if not Cooldown > 0:
			if is_on_floor():
				direction = lerp(direction, Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex)), delta * 10)
			else:
				direction = lerp(direction, Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex)), delta * 3)
	
	
	#Acelleration and decelleration
	if not Cooldown > 0:
		#while sliding
		if IsOnSlop and initSlop:
			pass
			
		#while not sliding
		else:
			if abs(direction) > 0.05:
				#IF on a slope
				if IsOnSlop:
					velocity.x = lerpf(velocity.x,direction * MaxSpeedSlope, delta * Aceleration)
				else:
					velocity.x = lerpf(velocity.x,direction * MaxSpeed, delta * Aceleration)
			else:
				velocity.x = lerpf(velocity.x, 0 , delta * 11)
	
	else:
		if is_on_floor():
			velocity.x = lerpf(velocity.x, 0 , delta * 11)
	
	
	#Handle jumping
	if not Cooldown > 0:
		if Input.is_action_just_pressed("Jump"+"_"+str(PlayerIndex)) and is_on_floor():
			SpawnPuff(jump_particale)
			velocity.y += Jumpheight
			if IsOnSlop and not initSlop:
				if round(SlopNormal/abs(SlopNormal)) != direction:
					velocity.x = 20 *-SlopNormal/-45
	
	
	# Add the gravity.
	if not is_on_floor() and not Cooldown > 0:
		velocity += get_gravity() * delta
	
	
	#Slope Handeling
	if IsOnSlop:
		if Input.is_action_pressed("Down"+"_"+str(PlayerIndex)):
			if SlopNormal > 0:
				direction = 1
			if SlopNormal < 0:
				direction = -1
			
			var DefualtSlopeMinimumSpeed = (25 * direction)
			var DefualtSpeedIncrease = 25
			
			#On first sliding frame
			if initSlop == false:
				initSlop = true
				
				print("Init slope")
				print(previeus_velocity)
				
				velocity.x += (abs(previeus_velocity.y+10) * direction * 0.5) + (previeus_velocity.x/6) + DefualtSlopeMinimumSpeed
				velocity.x *= 0.87
				velocity.x *= 0.8 + abs(Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex)))*0.25
				velocity.y += abs(previeus_velocity.y)*2
		
			#On other slding frams
			else:
				velocity.x = lerp(velocity.x,clamp(abs(velocity.x)*direction + (DefualtSpeedIncrease/abs(velocity.x/100) * direction),-520,520) + DefualtSlopeMinimumSpeed, delta*3)
				
			
			velocity.x += abs(Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex))) + MaxSpeedSlope/6 * direction * delta
			
			
			#StylePoints
			if abs(velocity.x) > 500 and time_reset_forward_to_pychics_process:
				Public.AddScore(10,global_position)
			
			if Input.is_action_just_pressed("Jump"+"_"+str(PlayerIndex)):
				initSlop = false
				print("s:" + str(velocity.x))
				var Relative = velocity
				velocity.y += ((abs(Relative.x)*-1)+Relative.y)/6.3
				velocity.x += (abs((Relative.x+Relative.y)/3) *direction )/1.4
				
			else:
				floor_snap_length = 9999
				apply_floor_snap()
		else:
			if abs(velocity.x) < 100:
				initSlop = false
			if initSlop == true:
				velocity.x = lerpf(velocity.x, 0 , delta * 11)
	else:
		initSlop = false
	
	_lader_step()
	
	move_and_slide()
	
	
	# Visualize moving dicretion
	if direction > 0.1:
		VisualNode.scale.x = 2
	elif direction < -0.1:
		VisualNode.scale.x = -2
	
	if !is_on_floor():
		previeus_velocity = velocity
	previeus_global_position = global_position
	
	time_reset_forward_to_pychics_process = false

func _on_damage_dealt(DealtDamage:float,Agressor):
	print(str(self) + "	" + str(DealtDamage) + "	Damage by	" + str(Agressor))

var time:float = 0
var time_reset_forward_to_pychics_process: bool = false
func _process(delta) -> void:
	if time >= 0.1:
		time_reset_forward_to_pychics_process = true
		time = 0
	time += delta
	
	_Ghost_controle(delta) #This is for the camera so it knows how much to zoom
	
	animate(delta)
	PrevieusFrame = VisualNode.frame
	PrevieusAnimation = VisualNode.animation
	
	pixel_perfect()
	
	PrevieusAction = VisualNode.animation
	
	painting(delta)
	_escape()
	
	#DebugLabelAnimation.text = VisualNode.animation

func _Ghost_controle(delta) -> void:
	$Ghost.global_position = lerp($Ghost.global_position,self.global_position+Vector2(2*velocity.x,1.2*velocity.y),2*delta)

#Fighting/Doge shit
var Cooldown:float
var CurrentAttack:String
#TODO Cobmo jabs (Dont use this anymore. i hate this)

#Visual
func pixel_perfect() -> void:
	VisualNode.global_position = round(global_position/2)*2
	
func animate(delta) -> void:
	#Ladder
	if has_node("BodyCollition"):
		if $BodyCollition.disabled:
			VisualNode.play("Ladder")
			VisualNode.speed_scale = clamp(abs(velocity.y)/170,0,6)
			return
	
	#CooldownStopAnimation
	if Cooldown > 0:
		VisualNode.play("Idle")
		return
	VisualNode.speed_scale = 1
	
	#Slope
	if initSlop:
		VisualNode.animation = "Slide"
		return
	
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

#Laders
var TileMapCords_up   : Vector2i
var TileMapCords_down : Vector2i
func calculate_lader_varibles():
	TileMapCords_up   = Vector2i(
		round( ( $Lader_up.global_position + Vector2(-16,-16) ) /32 )
		)
	TileMapCords_down = Vector2i(
		round( ( $Lader_down.global_position + Vector2(-16,-16) ) /32 )
		)

var Lock_Direction:int = 0

func _lader_step():
	calculate_lader_varibles()
	
	#TODO FIX ATLES CORDS THAT MATCH LADDER IN A GENERAL SCRIPT
	if Public.AtlasListLadders.has(TileMapNode.get_cell_atlas_coords(TileMapCords_up)):
		if !Public.AtlasListLadders.has(TileMapNode.get_cell_atlas_coords(TileMapCords_down)) and not Input.is_action_pressed("Jump"+"_"+str(PlayerIndex)):
			$BodyCollition.disabled = false
			if Cooldown == 2:
				Cooldown = 0
				return
		
		#Check if init
		if Cooldown != 2:
			if direction > 0:
				Lock_Direction = 1
			else:
				Lock_Direction = -1
		
		_do_a_ladder()
	
	elif Public.AtlasListLadders.has(TileMapNode.get_cell_atlas_coords(TileMapCords_down)):
		if Input.is_action_pressed("Down"+"_"+str(PlayerIndex)) or Cooldown == 2:
			#Check if init
			if Cooldown != 2:
				if direction > 0:
					Lock_Direction = 1
				else:
					Lock_Direction = -1
			
			_do_a_ladder()
	
	else:
		if has_node("BodyCollition"):
			$BodyCollition.disabled = false
		if Cooldown == 2:
			Cooldown = 0

func _do_a_ladder():
	if is_on_floor() and not Input.is_action_pressed("Down"+"_"+str(PlayerIndex)):
		if Input.is_action_pressed("Jump"+"_"+str(PlayerIndex)):
			velocity.y += -10
		elif Cooldown == 2:
			Cooldown = 0
		$BodyCollition.disabled = false
		return
	
	$BodyCollition.disabled = true
	Cooldown = 2
	
	direction = Input.get_axis("Left"+"_"+str(PlayerIndex),"Right"+"_"+str(PlayerIndex))
	var direction_y = Input.get_axis("Jump"+"_"+str(PlayerIndex),"Down"+"_"+str(PlayerIndex))
	
	velocity.x = lerpf(velocity.x,(direction * MaxSpeedLader)/2, get_process_delta_time() * 24)
	
	if !Public.AtlasListLadders.has(TileMapNode.get_cell_atlas_coords(round(global_position)/32)) or !Public.AtlasListLadders.has(TileMapNode.get_cell_atlas_coords(TileMapCords_up)):
		velocity.x = 0
		global_position.x = lerpf(global_position.x,round(previeus_global_position.x/32)*32+16*Lock_Direction, get_process_delta_time() * 18)
	
	velocity.y = lerpf(velocity.y,(direction_y * MaxSpeedLader), get_process_delta_time() * 12)
	
	return
	
	#while true:
		#position.y -= speed * get_process_delta_time()
		#
		#calculate_lader_varibles()
		#
		#if speed > 0:
			#if not Public.AtlasListLadders.has(TileMapNode.get_cell_atlas_coords(TileMapCords_up)) and not Public.AtlasListLadders.has(TileMapNode.get_cell_atlas_coords(TileMapCords_down)):
				#break
		#else:
			#if not Public.AtlasListLadders.has(TileMapNode.get_cell_atlas_coords(TileMapCords_down)):
				#break
	

#Paintables
var current_paintable

var PainterGame = preload("res://Player/Painter/Painter.tscn")

func painting(delta):
	if current_paintable and not Cooldown > 0:
		$"AnimatedSprite2D/Paintable Button".show()
	else:
		$"AnimatedSprite2D/Paintable Button".hide()
		
	
	if current_paintable != null and Input.is_action_just_pressed("interact"+"_"+str(PlayerIndex)) and not Cooldown > 0:
		velocity = Vector2(0,0)
		$Ghost.global_position = self.global_position
		
		$"AnimatedSprite2D/Paintable Button".hide()
		
		Cooldown = 1
		
		var InitPainterGame = PainterGame.instantiate()
		InitPainterGame._start()
		add_child(InitPainterGame)
		
func _on_painterminigame_compleation():
	Cooldown = 0
	
	if current_paintable == null:
		printerr("Wauw this is fuckup. current_paintable == null")
		return
	
	if current_paintable.has_method("_painted"):
		current_paintable._painted()

func _on_painterminigame_failed():
	Cooldown = 0

func _entered_paintable(paintable:Area2D):
	current_paintable = paintable

func _exited_paintable():
	current_paintable = null

#Escape
var escaping = false
func _escape():
	if escaping:
		$"AnimatedSprite2D/escape Button".show()
	
		if Input.is_action_just_pressed("interact"+"_"+str(PlayerIndex)):
			BodyCollition.queue_free()
			$"../Transition".get_child(0).play("Close")
			await $"../Transition".get_child(0).animation_finished
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file("res://scene/Shop/Shop.tscn")
		
	else:
		$"AnimatedSprite2D/escape Button".hide()
	
	

func _entered_escape():
	escaping = true

func _exited_escape():
	escaping = false
	
