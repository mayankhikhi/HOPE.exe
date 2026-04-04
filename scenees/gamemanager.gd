extends Node

var total_required = 0
var destroyed = 0
var triggered = false

func register_destroy(type):
    destroyed += 1
    print("Destroyed:", destroyed)

    if destroyed >= total_required and not triggered:
        triggered = true
        start_horror()

func start_horror():
    print("HORROR START")

    # 🔊 baby cry
    $"../ANGRYBABY".play()

    # 💡 dim lights
    for light in get_tree().get_nodes_in_group("lights"):
        light.energy = 0.3

    # 🎨 desaturate
    var env = get_tree().get_first_node_in_group("env")
    if env:
        env.environment.adjustment_saturation = 0.2

    # 🚪 enable door
    for d in get_tree().get_nodes_in_group("door"):
        d.set("locked", false)

    # 🌍 shake
    shake_floor()