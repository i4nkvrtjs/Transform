extends Node

@export var player : Player

@onready var normal_music = $NormalMusic
@onready var transformed_music = $TransformedMusic

var transformed_playing := false

func _ready():

	normal_music.play()

func _process(_delta):

	if player == null:
		return

	if player.is_transformed():

		if !transformed_playing:

			switch_to_transformed()

	else:

		if transformed_playing:

			switch_to_normal()

func switch_to_transformed():

	transformed_playing = true

	normal_music.stop()

	transformed_music.play()

func switch_to_normal():

	transformed_playing = false

	transformed_music.stop()

	normal_music.play()
