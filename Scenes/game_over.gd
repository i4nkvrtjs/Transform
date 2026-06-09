extends Control

@onready var retry_button = $RetryButton
@onready var quit_button = $QuitButton
@onready var score_label = $ScoreLabel

var retry_normal
var retry_hover

var quit_normal
var quit_hover

func _ready():

	score_label.text = "SCORE: " + str(GameData.final_score)

	retry_normal = retry_button.texture_normal
	retry_hover = retry_button.texture_hover

	quit_normal = quit_button.texture_normal
	quit_hover = quit_button.texture_hover

	retry_button.grab_focus()

	retry_button.pressed.connect(
		_on_retry_pressed
	)

	quit_button.pressed.connect(
		_on_quit_pressed
	)

	update_button_visuals()

func _process(_delta):

	if get_viewport().gui_get_focus_owner() == null:

		retry_button.grab_focus()

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

	if focused == retry_button:

		retry_button.texture_normal = retry_hover

	else:

		retry_button.texture_normal = retry_normal

	if focused == quit_button:

		quit_button.texture_normal = quit_hover

	else:

		quit_button.texture_normal = quit_normal

func _on_retry_pressed():

	$AudioButton.play()

	await $AudioButton.finished

	get_tree().change_scene_to_file(
		"res://Scenes/World/main.tscn"
	)

func _on_quit_pressed():

	$AudioButton.play()

	await $AudioButton.finished

	get_tree().quit()
