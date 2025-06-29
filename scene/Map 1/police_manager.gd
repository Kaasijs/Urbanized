extends Node2D

var innit := false

func _process(delta):
	if innit == false:
		if float(Public.Score) > float(400):
			innit = true
			innit_p()
	

func innit_p():
	var dir = Public.CurrentPlayer.Lock_Direction
	dir = round(dir)
	if dir == 0:
		dir = 1
	
	$PoliceDrone.global_position = Public.CurrentPlayer.global_position + Vector2(dir * -330 , 0)
	$PoliceDrone.TargetPreviuesPosition = $PoliceDrone.global_position
	$PoliceDrone/AnimatedSprite2D.show()
	
	$AudioStreamPlayer.play()
	await $AudioStreamPlayer.finished
	
	$PoliceDrone.freeze = false
	
	var phantom_camera:PhantomCamera2D = $"../PhantomCamera2D"
	phantom_camera.follow_mode = PhantomCamera2D.FollowMode.GROUP
	phantom_camera.append_follow_targets($PoliceDrone)
