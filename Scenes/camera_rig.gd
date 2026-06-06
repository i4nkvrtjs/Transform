extends Node3D

@export var follow_speed := 5.0

var target : Node3D

func _ready():

	target = get_tree().get_first_node_in_group("player")

func _process(delta):

	if target == null:
		return

	global_position = global_position.lerp(
		target.global_position,
		follow_speed * delta
	)
