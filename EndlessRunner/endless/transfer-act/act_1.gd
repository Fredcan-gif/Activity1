extends Node2D

@export var trap_scene: PackedScene 
@export var speed = 5.0 
@export var stage_2_threshold = 3 
@export var start_delay = 1.0 # Seconds to wait before first spawn
@export var score_multiplier: float = 12.3

var loops_completed = 0
var current_stage = 1
var can_spawn = false # Controlled by our timer
var score: float = 0.0

# Make sure you have this onready reference!
@onready var score_label = $UI/ScoreLabel # Adjust path if needed
@onready var tile_map_layer: TileMapLayer = $TileMapLayer2
@onready var stage_label = $UI/StageLabel
@onready var anim_player = $UI/AnimationPlayer

func _ready() -> void:
	# Create a one-shot timer to delay the first wave of traps
	await get_tree().create_timer(start_delay).timeout
	can_spawn = true
	_spawn_random_traps() # Initial spawn after delay

func _process(delta: float) -> void:
	tile_map_layer.position.x -= speed
	
	# 1. Update the score based on time and current speed
	# This rewards the player more for being in Stage 2 (higher speed)
	if not get_node("CharacterBody2D").is_dead:
		score += (speed * score_multiplier) * delta
		_update_score_display()
		
	if tile_map_layer.position.x < -800:
		# Clean up old traps
		for child in tile_map_layer.get_children():
			child.queue_free()

		tile_map_layer.position.x = 0
		loops_completed += 1
		_check_stage_transition()
		
		# Only spawn if the start_delay has passed
		if can_spawn:
			_spawn_random_traps()
			
func _update_score_display():
	# We use int() to remove decimals for a cleaner look
		score_label.text = "Score: " + str(int(score))

func _check_stage_transition():
	if loops_completed >= stage_2_threshold and current_stage == 1:
		current_stage = 2
		speed *= 1.5 
		
		# VISUAL CHANGE: Turn the world a bit darker/redder for Stage 2
		var tween = create_tween()
		tween.tween_property(tile_map_layer, "modulate", Color(0.65, 0.104, 0.186, 1.0), 1.5)
		# If you have a ParallaxBackground, you can dim it too
		if has_node("ParallaxBackground"):
			tween.parallel().tween_property($ParallaxBackground/ParallaxLayer5, "modulate", Color(0.807, 0.299, 0.308, 1.0), 1.5)
			tween.parallel().tween_property($ParallaxBackground/ParallaxLayer4, "modulate", Color(0.807, 0.299, 0.308, 1.0), 1.5)
			tween.parallel().tween_property($ParallaxBackground/ParallaxLayer2, "modulate", Color(0.807, 0.299, 0.308, 1.0), 1.5)
			tween.parallel().tween_property($ParallaxBackground/ParallaxLayer, "modulate", Color(0.807, 0.299, 0.308, 1.0), 1.5)
			tween.parallel().tween_property($ParallaxBackground/ParallaxLayer3, "modulate", Color(0.807, 0.299, 0.308, 1.0), 1.5)
			tween.parallel().tween_property($ParallaxBackground/ParallaxLayer6, "modulate", Color(0.807, 0.299, 0.308, 1.0), 1.5)
			tween.parallel().tween_property($ParallaxBackground/ParallaxLayer8, "modulate", Color(0.807, 0.299, 0.308, 1.0), 1.5)
		
		if anim_player.has_animation("show_stage"):
			anim_player.play("show_stage")
		else:
			_show_stage_notification("STAGE 2: DANGER")

func _show_stage_notification(text: String):
	stage_label.text = text
	# We rely entirely on the AnimationPlayer to handle visibility and timing
	anim_player.play("show_stage")

func _spawn_random_traps():
	if not can_spawn: return
	
	# DIFFICULTY SCALING: 
	# Stage 1: 1-2 traps | Stage 2: 2-4 traps
	var min_t = 1 if current_stage == 1 else 2
	var max_t = 2 if current_stage == 1 else 4
	var trap_count = randi_range(min_t, max_t) 
	
	var camera = get_viewport().get_camera_2d()
	var camera_x = camera.global_position.x if camera else 0.0
	
	for i in range(trap_count):
		# Increase spawn chance: 60% in Stage 1, 85% in Stage 2
		var spawn_chance = 0.6 if current_stage == 1 else 0.85
		
		if randf() < spawn_chance:
			var new_trap = trap_scene.instantiate()
			tile_map_layer.add_child(new_trap)
			
			# POSITIONING: 
			# In Stage 2, traps spawn slightly closer to each other (tighter gaps)
			var min_dist = 300 if current_stage == 1 else 200
			var max_dist = 600 if current_stage == 1 else 450
			
			var global_spawn_x = camera_x + randf_range(min_dist, max_dist)
			var global_spawn_y = global_position.y + 178 
			
			new_trap.global_position = Vector2(global_spawn_x, global_spawn_y)
			new_trap.z_index = 5
			
			print("Trap spawned ahead of player at: ", new_trap.global_position)
			
			print("Trap spawned at local: ", new_trap.position)
