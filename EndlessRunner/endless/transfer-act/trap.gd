extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Use lowercase "player" or "Player" check to be safe
	if body.is_in_group("Player") or body.name.to_lower() == "player":
		if body.has_method("die"):
			body.die()
		
	print("DEBUG: Something touched the trap: ", body.name) # See this in the Output tab
	
	if body.is_in_group("Player"):
		print("DEBUG: It was the player! Killing now.")
		body.die()
