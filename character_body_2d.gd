extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -450.0

# Dodge settings
const DODGE_SPEED = 900.0
const DODGE_TIME = 0.2
const DODGE_COOLDOWN = 0.6

# Camera Shake
var shake_time = 0.0
var shake_strength = 0.0

# Fall damage settings
const MIN_FALL_DAMAGE_SPEED = 1000.0
const MAX_FALL_DAMAGE_SPEED = 1400.0
const MAX_FALL_DAMAGE = 100

var is_dodging = false
var dodge_timer = 0.0
var dodge_cooldown_timer = 0.0
var dodge_direction = 0.0

var max_fall_speed = 0.0
var was_on_floor = false

var health = 100
var is_dead = false
var facing_direction := 1

# --- NEW NODE REFERENCES ---
# These variables ensure we find the nodes in their new locations
@onready var offset_node: Node2D = $OffsetNode
@onready var sprite: AnimatedSprite2D = $OffsetNode/AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $OffsetNode/CollisionShape2D
@onready var camera: Camera2D = $Camera2D

func _physics_process(delta: float) -> void:
	update_camera_shake(delta)

	if is_dead:
		return

	var currently_on_floor = is_on_floor()

	# Dodge timers
	if dodge_timer > 0:
		dodge_timer -= delta
		if dodge_timer <= 0:
			is_dodging = false

	if dodge_cooldown_timer > 0:
		dodge_cooldown_timer -= delta

		
		# Apply gravity
	if not currently_on_floor:
		var gravity = get_gravity()
	
	# If falling (velocity.y is positive), multiply gravity
		if velocity.y > 0:
			velocity += gravity * 1.5 * delta  # Change 1.5 to your liking
		else:
			velocity += gravity * delta
		
		max_fall_speed = max(max_fall_speed, velocity.y)

	# Landing check
	if currently_on_floor and not was_on_floor:
		check_fall_damage()
		max_fall_speed = 0.0

	# Jump
	if Input.is_action_just_pressed("go_jump") and currently_on_floor and not is_dodging:
		velocity.y = JUMP_VELOCITY

	# Start dodge
	if Input.is_action_just_pressed("go_dodge") and not is_dodging and dodge_cooldown_timer <= 0:
		var input_dir := Input.get_axis("go_left", "go_right")
		if input_dir == 0:
			input_dir = facing_direction
		is_dodging = true
		dodge_timer = DODGE_TIME
		dodge_cooldown_timer = DODGE_COOLDOWN
		dodge_direction = input_dir

	# Movement
	var direction := Input.get_axis("go_left", "go_right")
	if is_dodging:
		velocity.x = dodge_direction * DODGE_SPEED
	else:
		if direction:
			velocity.x = direction * SPEED
			facing_direction = sign(direction)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# 1. Flip the node (Handles both sprite and hitbox)
	if facing_direction != 0:
		offset_node.scale.x = facing_direction

	# 2. Update animations
	update_animation(currently_on_floor)

	# 3. Update floor state
	was_on_floor = currently_on_floor


# =========================
# Animation
# =========================

func update_animation(currently_on_floor: bool):
	if is_dead:
		return

	if is_dodging:
		if sprite.animation != "dash":
			sprite.play("dash")
	elif not currently_on_floor:
		if velocity.y < 0:
			if sprite.animation != "jump":
				sprite.play("jump")
		else:
			if sprite.animation != "fall":
				sprite.play("fall")
	elif abs(velocity.x) > 10:
		if sprite.animation != "run":
			sprite.play("run")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")


# =========================
# Camera Shake
# =========================

func shake_camera(strength: float, duration: float):
	shake_strength = strength
	shake_time = duration


func update_camera_shake(delta):
	if shake_time > 0:
		shake_time -= delta
		var current_strength = shake_strength * (shake_time / 0.3)
		camera.offset = Vector2(
			randf_range(-current_strength, current_strength),
			randf_range(-current_strength, current_strength)
		)
	else:
		camera.offset = Vector2.ZERO


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
		
		# --- ADD THIS LINE BACK ---
		print("Fall damage: ", damage, " | Remaining Health: ", health)
		# --------------------------
		
		if damage > 20:
			shake_camera(6.0, 0.2)

		if health <= 0:
			die()


# =========================
# Death
# =========================

func die():
	if is_dead:
		return

	is_dead = true
	shake_camera(15.0, 0.4)

	sprite.visible = false
	collision_shape.set_deferred("disabled", true) # Use set_deferred for physics safety
	velocity = Vector2.ZERO

	spawn_death_particles()


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
