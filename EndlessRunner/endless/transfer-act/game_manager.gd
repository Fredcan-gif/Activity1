# GameManager.gd (Autoload)
extends Node

var start_position = Vector2(100, 500) # Set this to your starting coordinates
var player_node = null

func respawn_player():
	if player_node:
		player_node.global_position = start_position
		# Optional: Reset velocity if using CharacterBody2D
		if player_node.has_method("reset_physics"):
			player_node.reset_physics()
