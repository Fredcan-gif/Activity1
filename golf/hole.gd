extends Area2D

func _on_body_entered(body):
	# Check if the thing that entered is actually our Golf Ball
	if body.name == "GolfBall" or body is RigidBody2D:
		print("Goal reached!")
		
		# Option A: Immediate disappearance
		body.queue_free() 
		
		# Option B: Smooth "falling into hole" effect
		# var tween = create_tween()
		
		# Move ball to the exact center of the hole and shrink it
		# tween.parallel().tween_property(body, "global_position", global_position, 0.2)
		# tween.parallel().tween_property(body, "scale", Vector2.ZERO, 0.2)
		
		# Remove the ball once the animation finishes
		# tween.finished.connect(func(): body.queue_free())
