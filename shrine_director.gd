extends Node

@export var shrine_scene : PackedScene

@export var min_distance_from_player := 25.0

var current_shrine : Node

var player : Player

func _ready():

	player = get_tree().get_first_node_in_group(
		"player"
	)

	call_deferred("spawn_shrine")

func spawn_shrine():

	if player.is_transformed():
		return
		
	if current_shrine:
		return

	var valid_points = []

	for point in get_tree().get_nodes_in_group(
		"shrine_spawn"
	):

		if point.global_position.distance_to(
			player.global_position
		) < min_distance_from_player:

			continue

		valid_points.append(point)

	if valid_points.is_empty():
		return

	var spawn_point = valid_points.pick_random()

	current_shrine = shrine_scene.instantiate()

	get_parent().add_child(current_shrine)

	current_shrine.global_position = spawn_point.global_position

	current_shrine.shrine_consumed.connect(
		_on_shrine_consumed
	)

func _on_shrine_consumed():
	current_shrine = null

	await get_tree().create_timer(
		randf_range(3,7)
	).timeout

	while player.is_transformed():
		await get_tree().process_frame

	spawn_shrine()

func get_current_shrine():

	return current_shrine

func remove_current_shrine():
	if current_shrine == null:
		return

	current_shrine.queue_free()

	current_shrine = null
