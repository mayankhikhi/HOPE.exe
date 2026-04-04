extends Area3D

@export var type := "plushie"   # train / paper / etc
var player = null

func _ready():
	body_entered.connect(_enter)
	body_exited.connect(_exit)

func _enter(body):
	if body.name == "ProtoController":
		player = body
		player.set_interactable(self)

func _exit(body):
	if body.name == "ProtoController":
		player = null
		body.set_interactable(null)

func interact():
	var obj = get_parent()

	# snap / rotate
	obj.rotation_degrees.z = 60

	# enable physics
	if obj is RigidBody3D:
		obj.freeze = false
		obj.apply_impulse(Vector3.ZERO, Vector3(0,2,-6))

	# notify manager
	get_node("/root/GameManager").register_destroy(type)
