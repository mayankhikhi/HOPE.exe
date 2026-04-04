extends Area3D

var player_inside = false
var is_done = false
func _ready():
	body_entered.connect(_enter)
	body_exited.connect(_exit)

func _enter(body):
	if body.name == "ProtoController":
		player_inside = true

func _exit(body):
	if body.name == "ProtoController":
		player_inside = false

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact") and not is_done:
		cinematic()

func cinematic():
	is_done = true

	var player = get_tree().get_first_node_in_group("player")
	var cam = player.get_node("Head/Camera3D")
	var teddy = get_parent()
	var sound = teddy.get_node("TeddySound")

	# lock movement
	player.can_move = false

	#move teddy in front of camera
	var target_pos = cam.global_position + cam.global_transform.basis.z * -1.5
	teddy.global_position = target_pos

	#face camera
	teddy.look_at(cam.global_position, Vector3.UP)

	await get_tree().create_timer(0.2).timeout

	#neck snap animation
	for i in range(10):
		teddy.rotation_degrees.z += 6
		await get_tree().create_timer(0.02).timeout

	#play crack sound
	if sound:
		sound.play()

	await get_tree().create_timer(0.3).timeout

	#throw teddy forward
	var throw_dir = cam.global_transform.basis.z * -1
	teddy.global_position += throw_dir * 3

	await get_tree().create_timer(0.3).timeout

	teddy.queue_free()

	player.can_move = true
