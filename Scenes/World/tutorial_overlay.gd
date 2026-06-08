extends Control

func _ready():

	get_tree().paused = true

	visible = true

func _unhandled_input(event):

	if event.is_action_pressed("ability") \
	or event.is_action_pressed("ui_accept"):

		close_tutorial()

func close_tutorial():

	get_tree().paused = false

	queue_free()
