extends Control

func _ready() -> void:
	$ScoreLabel.text = "SCORE: " + str(GameData.final_score)
	
	$RetryButton.pressed.connect(_on_retry_pressed)
	$QuitButton.pressed.connect(_on_quit_pressed)
	$AudioStreamPlayer.play()

func _on_retry_pressed():
	$AudioButton.play()
	get_tree().change_scene_to_file("res://Scenes/World/main.tscn")

func _on_quit_pressed():
	$AudioButton.play()
	await $AudioButton.finished
	get_tree().quit()
