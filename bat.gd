extends CharacterBody2D

@export var speed = 150.0
@export var accel = 7.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D = null

func _ready():
	nav_agent.path_desired_distance = 15.0
	nav_agent.target_desired_distance = 15.0

func _physics_process(delta):
	if player:
		# 1. Update the navigation target to the player's position
		nav_agent.target_position = player.global_position
		
		if not nav_agent.is_navigation_finished():
			# 2. Find the next point in the path
			var next_path_pos = nav_agent.get_next_path_position()
			
			# 3. Calculate velocity towards that point
			var new_velocity = global_position.direction_to(next_path_pos) * speed
			
			# 4. Smooth movement (Acceleration)
			velocity = velocity.lerp(new_velocity, accel * delta)
			
			# Flip sprite based on movement
			sprite.flip_h = velocity.x < 0
			
			move_and_slide()

# --- Detection Logic ---
func _on_detection_range_body_entered(body):
	if body.is_in_group("Player"): # Make sure your Player is in the "Player" group
		player = body

func _on_detection_range_body_exited(body):
	if body == player:
		player = null
		velocity = Vector2.ZERO # Stop moving if player escapes


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not body.is_dead:
		# 1. Deal Damage
		body.health -= 20
		
		# 2. Update the HUD (Synchronize the health bar)
		if body.health_bar:
			body.health_bar.value = body.health
		
		# 3. Play Player's Hurt Sound/Effects
		if body.has_method("shake_camera"):
			body.shake_camera(4.0, 0.2)
		if body.hurt_sound:
			body.hurt_sound.play()

		# 4. Small Knockback
		# We calculate the direction from the Bat to the Player
		var knockback_direction = global_position.direction_to(body.global_position)
		var knockback_strength = 500.0
		body.velocity = knockback_direction * knockback_strength
		
		# 5. Check for Death
		if body.health <= 0:
			body.die()
