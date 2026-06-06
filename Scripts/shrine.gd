extends Area3D

signal shrine_consumed

func _on_body_entered(body):

	if body.is_in_group("player"):

		body.start_transformation()
		shrine_consumed.emit()
		queue_free()
