extends Control

@export var player : Player

@export var floating_text_scene : PackedScene

@onready var health_bar = $HealthBar

@onready var transform_timer = $TransformTimer

@onready var floating_container = (
	$FloatingTextContainer
)

@onready var score_label = $ScoreLabel

func _ready():

	player.score_changed.connect(
		_on_score_changed
	)

	player.enemy_consumed.connect(
		_on_enemy_consumed
	)

func _process(_delta):
	update_transform_timer()

func _on_score_changed(score):
	score_label.text = (
		"SCORE: " + str(score)
	)

func _on_enemy_consumed(
	world_position,
	heal_amount
):

	spawn_floating_heal(
		world_position,
		heal_amount
	)

func spawn_floating_heal(
	world_position : Vector3,
	heal_amount : int
):

	var camera = (
		get_viewport()
		.get_camera_3d()
	)

	if camera == null:
		return

	var screen_pos = (
		camera.unproject_position(
			world_position
		)
	)

	var text = (
		floating_text_scene.instantiate()
	)

	floating_container.add_child(
		text
	)

	text.text = "+" + str(heal_amount)

	text.position = screen_pos

func update_transform_timer():

	if !player.is_transformed():

		transform_timer.visible = false

		return

	transform_timer.visible = true

	transform_timer.max_value = (
		player.stats.transformed_duration
	)

	transform_timer.value = (
		player.transform_timer
	)
