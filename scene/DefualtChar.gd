extends CharacterBody2D

@export var TileMapNode:TileMapLayer

@export var PlayerIndex:int

@export var Aceleration:float = 7.0
@export var MaxSpeed:float = 300.0
@export var MaxSpeedSlope:float = 350.0
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

#Debug
@onready var DebugLabelCooldown = $"../CanvasLayer/Cooldown"
@onready var DebugLabelAnimation = $"../CanvasLayer/Animation"

func is_player() -> void:
	return


var SlopeMomentum:float
var SlopeInitVelocity:float

func _physics_process(delta) -> void:
	#RESET FLOOR SNAP. SEE Slope fix for why
	floor_snap_length = 15
	
	#Get Slop normal angel
	var SlopNormal = rad_to_deg(get_floor_normal().angle())+90
	var IsOnSlop:bool = abs(SlopNormal) > 42 and abs(SlopNormal) < 47
	
	#handle movement/deceleration.
	if not Cooldown > 0:
		if is_on_floor():
			direction = lerp(direction, Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex)), delta * 10)
		else:
			direction = lerp(direction, Input.get_axis("Left"+"_"+str(PlayerIndex), "Right"+"_"+str(PlayerIndex)), delta * 3)
		
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
			if IsOnSlop and SlopeMomentum < 0.1:
				velocity.x -= (velocity.x*1.1) *direction
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Slope fix :) 
	if IsOnSlop:
		if Input.is_action_pressed("Down"+"_"+str(PlayerIndex)):
			
			if SlopNormal > 0:
				direction = 1
			else:
				direction = -1
			
			#Have you slowed down?
			if (direction > 0 and velocity.x > 5) or (direction < 0 and velocity.x < 5) or velocity.y > 300:
				if abs(velocity.x) > 800.0:
					print("STYLE POINTS")
				
				if SlopeMomentum == 0.0911:
					SlopeMomentum += clamp(abs(velocity.y/660) ,0,9990.7)
					
					var prevelocity:Vector2 = velocity
					
					velocity.x += abs(prevelocity.y)*direction * 1.1
					velocity.y += abs(prevelocity.x)*1
				else:
					var prevelocity:Vector2 = velocity
					
					velocity.x += ( SlopeInitVelocity + abs(prevelocity.x) *SlopeMomentum*0.1 )*direction
					velocity.y += abs(prevelocity.x) + SlopeInitVelocity
					pass
				
				SlopeMomentum = lerpf(SlopeMomentum, 0.4, delta*0.3)
				SlopeInitVelocity = lerpf(SlopeInitVelocity,0.0,delta*14)
				print(SlopeMomentum)
				
				if Input.is_action_just_pressed("Jump"+"_"+str(PlayerIndex)):
					print("s:" + str(velocity.x))
					velocity.y += (abs(1+velocity.x)*(1+SlopeMomentum))/1.2 *-1
					velocity.x += (abs(1+velocity.x)*(1+SlopeMomentum))/3 * direction
					
				else:
					floor_snap_length = 9999
					apply_floor_snap()
			else:
				velocity.x = lerpf(velocity.x, 0 , delta * 11)
	else:
		SlopeMomentum = 0.0911
		if Input.is_action_pressed("Down"+"_"+str(PlayerIndex)) and is_on_floor():
			velocity.x = lerpf(velocity.x, 0 , delta * 11)
	
	_lader_step()
	
	move_and_slide()
	
	
	# Visualize moving dicretion
	if direction > 0.1:
		VisualNode.scale.x = 2
	elif direction < -0.1:
		VisualNode.scale.x = -2

func _on_damage_dealt(DealtDamage:float,Agressor):
	print(str(self) + "	" + str(DealtDamage) + "	Damage by	" + str(Agressor))

func _process(delta) -> void:
	_Ghost_controle(delta) #This is for the camera so it knows how much to zoom
	
	animate(delta)
	PrevieusFrame = VisualNode.frame
	PrevieusAnimation = VisualNode.animation
	
	pixel_perfect()
	
	PrevieusAction = VisualNode.animation
	
	painting(delta)
	
	DebugLabelAnimation.text = VisualNode.animation

func _Ghost_controle(delta) -> void:
	$Ghost.global_position = lerp($Ghost.global_position,self.global_position+Vector2(2*velocity.x,-0.5*velocity.y),2*delta)

#Fighting/Doge shit
var Cooldown:float
var CurrentAttack:String
#TODO Cobmo jabs (Dont use this anymore. i hate this)

#Visual
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

#Laders
var LadderAtlasList:Array = [
	Vector2i(3, 0), #DEBUG LADER
	]

var TileMapCords_up   : Vector2i
var TileMapCords_down : Vector2i
func calculate_lader_varibles():
	TileMapCords_up   = Vector2i(
		round( ( $Lader_up.global_position + Vector2(-16,-16) ) /32 )
		)
	TileMapCords_down = Vector2i(
		round( ( $Lader_down.global_position + Vector2(-16,-16) ) /32 )
		)

func _lader_step():
	calculate_lader_varibles()
	
	#TODO FIX ATLES CORDS THAT MATCH LADDER IN A GENERAL SCRIPT
	if LadderAtlasList.has(TileMapNode.get_cell_atlas_coords(TileMapCords_up)):
		$"AnimatedSprite2D/Ladder Button".show()
		if Input.is_action_just_pressed("interact"+"_"+str(PlayerIndex)):
			$"AnimatedSprite2D/Ladder Button".hide()
			_do_a_ladder(1)
	
	elif LadderAtlasList.has(TileMapNode.get_cell_atlas_coords(TileMapCords_down)):
		$"AnimatedSprite2D/Ladder Button".show()
		if Input.is_action_just_pressed("interact"+"_"+str(PlayerIndex)):
			$"AnimatedSprite2D/Ladder Button".hide()
			_do_a_ladder(-1)
	
	else:
		$"AnimatedSprite2D/Ladder Button".hide()

func _do_a_ladder(speed):
	while true:
		position.y -= speed * get_process_delta_time()
		
		calculate_lader_varibles()
		
		if speed > 0:
			if not LadderAtlasList.has(TileMapNode.get_cell_atlas_coords(TileMapCords_up)) and not LadderAtlasList.has(TileMapNode.get_cell_atlas_coords(TileMapCords_down)):
				break
		else:
			if not LadderAtlasList.has(TileMapNode.get_cell_atlas_coords(TileMapCords_down)):
				break
		

#Paintables
var current_paintable

var PainterGame = preload("res://Player/Painter/Painter.tscn")

func painting(delta):
	if current_paintable and Cooldown == 0:
		$"AnimatedSprite2D/Paintable Button".show()
	else:
		$"AnimatedSprite2D/Paintable Button".hide()
		
	
	if current_paintable != null and Input.is_action_just_pressed("interact"+"_"+str(PlayerIndex)) and Cooldown == 0:
		velocity = Vector2(0,0)
		$Ghost.global_position = self.global_position
		
		$"AnimatedSprite2D/Paintable Button".hide()
		
		Cooldown = 1
		
		var InitPainterGame = PainterGame.instantiate()
		InitPainterGame._start()
		add_child(InitPainterGame)
		
func _on_painterminigame_compleation():
	Cooldown = 0
	
	if current_paintable.has_method("_painted"):
		current_paintable._painted()

func _on_painterminigame_failed():
	Cooldown = 0

func _entered_paintable(paintable:Area2D):
	current_paintable = paintable

func _exited_paintable():
	current_paintable = null
