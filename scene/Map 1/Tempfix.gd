extends Camera2D

@onready var player_1 = $"../Player 1"


func _process(delta):
	global_position = player_1.global_position
