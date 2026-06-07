extends Node3D

@onready var mesh := $MeshInstance3D

var target_radius := 1.0

func setup(radius : float):

	target_radius = radius

	scale = Vector3.ZERO

	var tween = create_tween()

	tween.tween_property(
		self,
		"scale",
		Vector3(radius,1,radius),
		0.2
	)

	await get_tree().create_timer(1.0).timeout

	queue_free()
