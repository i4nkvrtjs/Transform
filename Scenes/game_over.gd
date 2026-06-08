extends Control

func _ready() -> void:
	$ScoreLabel.text = "SCORE: " + str(GameData.final_score)
	
	$RetryButton.pressed.connect(_on_retry_pressed)
	
	$AudioStreamPlayer.play()

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://Scenes/World/main.tscn")
