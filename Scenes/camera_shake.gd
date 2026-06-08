extends Node3D

@export var trauma_decay := 3.0
@export var max_shake := 2.5

var trauma := 0.0

func _process(delta):

	trauma = max(
		trauma - trauma_decay * delta,
		0.0
	)

	var strength = trauma * trauma

	position = Vector3(
		randf_range(-max_shake, max_shake) * strength,
		randf_range(-max_shake, max_shake) * strength,
		0.0
	)

func add_trauma(amount : float):

	trauma = min(
		trauma + amount,
		1.0
	)
