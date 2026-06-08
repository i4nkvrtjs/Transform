extends Control

@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton

var play_normal
var play_hover

var quit_normal
var quit_hover

func _ready() -> void:

	play_normal = play_button.texture_normal
	play_hover = play_button.texture_hover

	quit_normal = quit_button.texture_normal
	quit_hover = quit_button.texture_hover

	play_button.grab_focus()

	play_button.pressed.connect(
		_on_play_pressed
	)

	quit_button.pressed.connect(
		_on_quit_pressed
	)

	$AudioStreamPlayer.play()

	update_button_visuals()

func _process(_delta):

	if get_viewport().gui_get_focus_owner() == null:

		play_button.grab_focus()

	update_button_visuals()

func _unhandled_input(event):
	if event.is_action_pressed("ability"):

		var focused = (
			get_viewport()
			.gui_get_focus_owner()
		)

		if focused is BaseButton:

			focused.pressed.emit()

func update_button_visuals():

	var focused = (
		get_viewport()
		.gui_get_focus_owner()
	)

	if focused == play_button:

		play_button.texture_normal = play_hover

	else:

		play_button.texture_normal = play_normal

	if focused == quit_button:

		quit_button.texture_normal = quit_hover

	else:

		quit_button.texture_normal = quit_normal

func _on_play_pressed():

	$AudioButton.play()

	get_tree().change_scene_to_file(
		"res://Scenes/World/main.tscn"
	)

func _on_quit_pressed():

	$AudioButton.play()

	await $AudioButton.finished

	get_tree().quit()
