extends CharacterBody3D

class_name Enemy

enum State
{
	CHASE,
	FLEE
}

@export var stats : EnemyStats

@onready var navigation_agent : NavigationAgent3D = (
	$NavigationAgent3D
)

@onready var hit_area : Area3D = $Area3D

var current_state : State = State.CHASE

var player : Player

func _ready():

	player = get_tree().get_first_node_in_group(
		"player"
	)

	hit_area.body_entered.connect(
		_on_hit_area_body_entered
	)

func _physics_process(_delta):

	if player == null:
		return

	update_state()

	update_navigation_target()

	move_enemy()

	move_and_slide()

func update_state():

	if player.is_transformed():
		current_state = State.FLEE
	else:
		current_state = State.CHASE

func update_navigation_target():

	match current_state:

		State.CHASE:

			navigation_agent.target_position = (
				player.global_position
			)

		State.FLEE:

			var flee_direction := (
				global_position -
				player.global_position
			).normalized()

			navigation_agent.target_position = (
				global_position +
				flee_direction * 20.0
			)

func move_enemy():

	var next_position := (
		navigation_agent.get_next_path_position()
	)

	var direction := (
		next_position -
		global_position
	).normalized()

	var speed := stats.move_speed

	if current_state == State.FLEE:

		speed *= stats.flee_multiplier

	velocity = direction * speed

func die():

	queue_free()

func _on_hit_area_body_entered(body):

	if !body.is_in_group("player"):
		return

	if body.is_transformed():
		return

	body.take_damage(
		stats.contact_damage
	)

	var knockback_direction = (
		body.global_position -
		global_position
	).normalized()

	body.apply_knockback(
	knockback_direction *
	stats.knockback_force,
	body.stats.hit_stun_duration
	)
