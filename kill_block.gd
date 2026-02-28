extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Check if the thing that entered has a "die" function
	if body.has_method("die"):
		body.die()
