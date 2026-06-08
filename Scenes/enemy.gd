extends CharacterBody3D

class_name Enemy

enum State
{
	CHASE,
	FLEE
}

@export var stats : EnemyStats

@onready var animation_player : AnimationPlayer = $Visuals/Enemy_1_42/AnimationPlayer
@onready var visuals : Node3D = $Visuals
@onready var navigation_agent : NavigationAgent3D = (
	$NavigationAgent3D
)

@onready var hit_area : Area3D = $Area3D

var current_animation := ""

var current_state : State = State.CHASE

var player : Player

func _ready():

	player = get_tree().get_first_node_in_group(
		"player"
	)
	
	play_animation("Walk")
	
	hit_area.body_entered.connect(
		_on_hit_area_body_entered
	)
	hit_area.body_exited.connect(
		_on_hit_area_body_exited
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

	update_visual_rotation(direction)

	var speed := stats.move_speed

	if current_state == State.FLEE:

		speed *= stats.flee_multiplier

	velocity = direction * speed

func die():
	if player:
		player.unregister_enemy_contact(self)

	queue_free()

func update_visual_rotation(direction : Vector3):

	if direction.length_squared() < 0.01:
		return

	var target_rotation = atan2(
		direction.x,
		direction.z
	)

	visuals.rotation.y = lerp_angle(
		visuals.rotation.y,
		target_rotation,
		10.0 * get_physics_process_delta_time()
	)

func play_animation(anim_name : String):

	if current_animation == anim_name:
		return

	current_animation = anim_name

	animation_player.play(anim_name)

func _on_hit_area_body_entered(body):

	if !body.is_in_group("player"):
		return

	body.register_enemy_contact(self)

func _on_hit_area_body_exited(body):

	if !body.is_in_group("player"):
		return

	body.unregister_enemy_contact(self)
