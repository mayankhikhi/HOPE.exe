extends Node3D

# Setup script for train - auto-plays the running sound

func _ready():
	var running_sound = get_node_or_null("RunningSound")
	
	if running_sound:
		# Start playing - looping should be set in AudioStreamPlayer inspector
		running_sound.play()
		print("Train running sound started")
	else:
		print("WARNING: RunningSound not found on train - add AudioStreamPlayer3D named 'RunningSound'")
