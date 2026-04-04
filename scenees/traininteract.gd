extends Area3D

var player_inside = false

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
	if player_inside and Input.is_action_just_pressed("interact"):
		destroy_train()

func destroy_train():
	var train = get_parent()
	train.rotation_degrees.z = 45
	await get_tree().create_timer(0.5).timeout
