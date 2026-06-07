extends Label

var velocity := Vector2(
	0,
	-50
)

func _ready():

	modulate.a = 1.0

	var tween = create_tween()

	tween.parallel().tween_property(
		self,
		"position",
		position + Vector2(0,-50),
		0.8
	)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		0.8
	)

	await tween.finished

	queue_free()
