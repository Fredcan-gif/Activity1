extends RigidBody2D

@export var is_my_turn: bool = true
@export var max_force: float = 500.0
@export var stop_threshold: float = 2.0 

var dragging = false
var drag_start = Vector2.ZERO

func _input(event):
	# 1. Block EVERYTHING if it's not your turn
	if not is_my_turn:
		dragging = false # Safety: Stop any active drags if turn is lost
		return
		
	# 2. Block input if the ball is still rolling
	if linear_velocity.length() > stop_threshold:
		dragging = false 
		return

	# 3. Handle the dragging logic
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if position.distance_to(get_global_mouse_position()) < 30:
				dragging = true
				drag_start = get_global_mouse_position()
		
		elif not event.pressed and dragging:
			dragging = false
			var drag_end = get_global_mouse_position()
			var direction = (drag_start - drag_end)
			apply_central_impulse(direction.limit_length(max_force))

func _process(_delta):
	queue_redraw()

func _draw():
	if dragging:
		var drag_current = get_global_mouse_position()
		var drag_vector = drag_current - drag_start
		var limited_vector = drag_vector.limit_length(100)
		
		# We rotate the line by the NEGATIVE of the ball's rotation.
		# This ensures the line stays pointed at the mouse even if the ball spins.
		var final_direction = (-limited_vector).rotated(-rotation)
		
		draw_line(Vector2.ZERO, final_direction, Color.WHITE, 2.0)
