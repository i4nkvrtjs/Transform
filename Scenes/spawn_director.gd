extends Node

@export var enemy_scene : PackedScene

@export var spawn_interval := 2.0
@export var max_enemies := 20

@export var difficulty_interval := 30.0
@export var spawn_acceleration := 0.9

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

	var spawn_points = get_tree().get_nodes_in_group(
		"spawn_point"
	)

	if spawn_points.is_empty():
		return

	var point = spawn_points.pick_random()

	var enemy = enemy_scene.instantiate()

	get_parent().add_child(enemy)

	enemy.global_position = point.global_position

func get_enemy_count() -> int:

	return get_tree().get_nodes_in_group("enemy").size()
