extends Node2D

@export var ball_1: RigidBody2D
@export var ball_2: RigidBody2D
@export var turn_label: Label # Drag your TurnLabel here in the Inspector!

var active_ball: RigidBody2D
var player_turn: int = 1

func _ready():
	active_ball = ball_1
	ball_1.is_my_turn = true
	ball_2.is_my_turn = false
	update_ui()

func _process(_delta):
	# 1. Check if the active_ball still exists in the game
	if not is_instance_valid(active_ball):
		return # Stop running this function if the ball was deleted
	
	# Check if ball is moving, then check if it has slowed to a stop
	if active_ball.linear_velocity.length() > 0.1 and active_ball.linear_velocity.length() < 5.0:
		active_ball.linear_velocity = Vector2.ZERO
		switch_turn()

func switch_turn():
	active_ball.is_my_turn = false
	
	if player_turn == 1:
		player_turn = 2
		active_ball = ball_2
	else:
		player_turn = 1
		active_ball = ball_1
	
	active_ball.is_my_turn = true
	update_ui()

func update_ui():
	turn_label.text = "Player " + str(player_turn) + "'s Turn"
	
	# Optional: Change text color to match the ball color
	if player_turn == 1:
		turn_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		turn_label.add_theme_color_override("font_color", Color.CYAN)
