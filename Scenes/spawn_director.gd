extends Node

@export var enemy_scene : PackedScene

@export var player : Player
@export var camera : Camera3D

@export var spawn_interval := 2.0
@export var max_enemies := 20

@export var difficulty_interval := 30.0
@export var spawn_acceleration := 0.9

@export var minimum_spawn_distance := 20.0

var spawn_timer := 0.0
var difficulty_timer := 0.0


func _process(delta):

	update_difficulty(delta)
	update_spawning(delta)


func update_spawning(delta):

	spawn_timer += delta

	if spawn_timer < spawn_interval:
		return

	spawn_timer = 0.0

	if get_enemy_count() >= max_enemies:
		return

	spawn_enemy()


func update_difficulty(delta):

	difficulty_timer += delta

	if difficulty_timer < difficulty_interval:
		return

	difficulty_timer = 0.0

	spawn_interval *= spawn_acceleration

	max_enemies += 5

	print("Difficulty Increased")
	print("Spawn Interval: ", spawn_interval)
	print("Max Enemies: ", max_enemies)


func spawn_enemy():

	var point = get_valid_spawn_point()

	if point == null:
		return

	var enemy = enemy_scene.instantiate()

	get_parent().add_child(enemy)

	enemy.global_position = point.global_position


func get_enemy_count() -> int:

	return get_tree().get_nodes_in_group(
		"enemy"
	).size()


func get_valid_spawn_point():

	var candidates = []

	for point in get_tree().get_nodes_in_group(
		"spawn_point"
	):

		if point.global_position.distance_to(
			player.global_position
		) < minimum_spawn_distance:

			continue

		# Visible en pantalla
		if is_visible_to_player(point):

			continue

		candidates.append(point)

	if candidates.is_empty():
		return null

	candidates.sort_custom(
		func(a,b):
			return (
				a.global_position.distance_to(
					player.global_position
				)
				<
				b.global_position.distance_to(
					player.global_position
				)
			)
	)

	return candidates[0]


func is_visible_to_player(
	point : Node3D
) -> bool:

	if camera == null:
		return false

	var screen_pos = camera.unproject_position(
		point.global_position
	)

	var viewport_size = (
		get_viewport()
		.get_visible_rect()
		.size
	)

	return (
		screen_pos.x >= 0.0
		and screen_pos.x <= viewport_size.x
		and screen_pos.y >= 0.0
		and screen_pos.y <= viewport_size.y
	)
