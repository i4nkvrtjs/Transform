extends CharacterBody3D

class_name Player

enum State
{
	NORMAL,
	TRANSFORMED
}

@export var stats : PlayerStats

@onready var visuals : Node3D = $Visuals
@onready var damage_area : Area3D = $Area3D

var current_state : State = State.NORMAL

var current_health : int

var transform_timer : float = 0.0

var knockback_velocity : Vector3 = Vector3.ZERO

var hit_stun_timer : float = 0.0

var invulnerability_timer : float = 0.0

func _ready():

	add_to_group("player")

	current_health = stats.max_health

	damage_area.body_entered.connect(
		_on_damage_area_body_entered
	)

func _physics_process(delta):

	handle_transformation(delta)

	update_hit_stun(delta)

	update_invulnerability(delta)

	handle_movement(delta)

	update_knockback(delta)

	move_and_slide()

func handle_movement(_delta):

	var input_dir := Vector2.ZERO

	input_dir.x = Input.get_axis(
		"ui_left",
		"ui_right"
	)

	input_dir.y = Input.get_axis(
		"ui_up",
		"ui_down"
	)

	var direction := Vector3(
		input_dir.x,
		0.0,
		input_dir.y
	)

	if direction.length() > 0.0:
		direction = direction.normalized()
		update_visual_rotation(direction)

	var move_velocity := Vector3.ZERO

	if hit_stun_timer <= 0.0:

		move_velocity = (
			direction *
			stats.move_speed
		)

	velocity.x = (
		move_velocity.x +
		knockback_velocity.x
	)

	velocity.z = (
		move_velocity.z +
		knockback_velocity.z
	)

func update_knockback(delta):

	knockback_velocity = knockback_velocity.lerp(
		Vector3.ZERO,
		stats.knockback_decay * delta
	)

func handle_transformation(delta):

	if current_state != State.TRANSFORMED:
		return

	transform_timer -= delta

	if transform_timer <= 0.0:
		end_transformation()

func start_transformation():

	current_state = State.TRANSFORMED

	transform_timer = (
		stats.transformed_duration
	)

	print("TRANSFORMED")

func end_transformation():

	current_state = State.NORMAL

	print("NORMAL")

func is_transformed() -> bool:

	return current_state == State.TRANSFORMED

func take_damage(amount : int):

	if invulnerability_timer > 0:
		return

	invulnerability_timer = stats.invulnerability_time
	current_health -= amount

	print(
		"HP: ",
		current_health,
		"/",
		stats.max_health
	)

	if current_health <= 0:
		die()

func apply_knockback(
	force : Vector3,
	stun_duration : float = 0.2
):

	knockback_velocity += force

	hit_stun_timer = max(
		hit_stun_timer,
		stun_duration
	)

func die():

	print("GAME OVER")

func _on_damage_area_body_entered(body):

	if !is_transformed():
		return

	if body.has_method("die"):
		body.die()

func update_hit_stun(delta):

	if hit_stun_timer > 0.0:
		hit_stun_timer -= delta

func update_invulnerability(delta):

	if invulnerability_timer > 0.0:
		invulnerability_timer -= delta

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
