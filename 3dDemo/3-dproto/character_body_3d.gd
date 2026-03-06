extends CharacterBody3D

@export var mouse_sensitivity = 0.002
@onready var spring_arm = $SpringArm3D # Ensure this matches your node name

const SPEED = 7.0
const JUMP_VELOCITY = 5.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Hide the mouse cursor and lock it to the center of the screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# 1. Rotate the whole player left/right (Y-axis)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# 2. Rotate the SpringArm up/down (X-axis)
		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		
		# 3. Clamp the vertical rotation so the camera doesn't flip upside down
		# Use radians: -1.2 (looking up) to 0.5 (looking down)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -1.2, 0.5)

	# Press 'Escape' to see your mouse again
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction (WASD/Arrow keys)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
