extends CharacterBody2D

# Movement & Jump Settings
const SPEED = 300.0
const JUMP_VELOCITY = -350.0

# Fall damage settings
const MIN_FALL_DAMAGE_SPEED = 1000.0
const MAX_FALL_DAMAGE_SPEED = 1400.0
const MAX_FALL_DAMAGE = 100

# State Variables
var max_fall_speed = 0.0
var was_on_floor = false
var health = 100
var is_dead = false
var facing_direction := 1

# Node References
@onready var offset_node: Node2D = $OffsetNode
@onready var sprite: AnimatedSprite2D = $OffsetNode/AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $OffsetNode/CollisionShape2D

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	var currently_on_floor = is_on_floor()

	# Gravity & Fall Speed Tracking
	if not currently_on_floor:
		var gravity = get_gravity()
		# Snappy Gravity: Faster fall than rise
		if velocity.y > 0:
			velocity += gravity * 1.5 * delta 
		else:
			velocity += gravity * delta
		
		# Track highest downward speed for fall damage
		max_fall_speed = max(max_fall_speed, velocity.y)

	# Landing check for Fall Damage
	if currently_on_floor and not was_on_floor:
		check_fall_damage()
		max_fall_speed = 0.0

	# --- INPUTS ---

	# Jump Logic
	if Input.is_action_just_pressed("go_jump") and currently_on_floor:
		velocity.y = JUMP_VELOCITY

	# --- MOVEMENT (LEFT/RIGHT DISABLED) ---
	# Manual horizontal input is ignored; friction brings player to a stop
	velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Flip the visual node based on facing direction
	if facing_direction != 0:
		offset_node.scale.x = facing_direction

	update_animation(currently_on_floor)
	was_on_floor = currently_on_floor

# =========================
# Animation Logic
# =========================

func update_animation(currently_on_floor: bool):
	if is_dead: return

	if not currently_on_floor:
		if velocity.y < 0:
			if sprite.animation != "jump": sprite.play("jump")
		else:
			if sprite.animation != "fall": sprite.play("fall")
	elif abs(velocity.x) > 10:
		if sprite.animation != "run": sprite.play("run")
	else:
		if sprite.animation != "idle": sprite.play("idle")

# =========================
# Fall Damage
# =========================

func check_fall_damage():
	if max_fall_speed > MIN_FALL_DAMAGE_SPEED:
		var damage_ratio = clamp(
			(max_fall_speed - MIN_FALL_DAMAGE_SPEED) /
			(MAX_FALL_DAMAGE_SPEED - MIN_FALL_DAMAGE_SPEED),
			0.0, 1.0
		)

		var damage = damage_ratio * MAX_FALL_DAMAGE
		health -= damage
		
		print("Fall damage: ", damage, " | Remaining Health: ", health)
		
		if health <= 0:
			die()

# =========================
# Death & Particles
# =========================

func die():
	if is_dead: return
	is_dead = true
	sprite.visible = false
	collision_shape.set_deferred("disabled", true) 
	velocity = Vector2.ZERO
	spawn_death_particles()
	
	# Wait for 1 second so the player sees the death, then reload
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func spawn_death_particles():
	var particles = GPUParticles2D.new()
	particles.amount = 40
	particles.lifetime = 2.0
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.process_material = create_particle_material()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true

func create_particle_material():
	var mat = ParticleProcessMaterial.new()
	mat.color = Color.RED
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 180
	mat.initial_velocity_min = 100
	mat.initial_velocity_max = 200
	mat.gravity = Vector3(0, 500, 0)
	mat.scale_min = 3.0
	mat.scale_max = 4.0
	return mat
