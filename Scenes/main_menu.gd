extends Control

func _ready() -> void:
	
	$PlayButton.pressed.connect(
		_on_play_pressed
	)
	$AudioStreamPlayer.play()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/World/main.tscn")
