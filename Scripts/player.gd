extends CharacterBody3D

class_name Player

enum State
{
	NORMAL,
	TRANSFORMED
}

@export var stats : PlayerStats

@onready var animation_player : AnimationPlayer = $Visuals/Cha_43/AnimationPlayer
@onready var visuals : Node3D = $Visuals
@onready var damage_area : Area3D = $Area3D

var current_state : State = State.NORMAL

var current_health : int

var transform_timer : float = 0.0

var knockback_velocity : Vector3 = Vector3.ZERO

var hit_stun_timer : float = 0.0

var invulnerability_timer : float = 0.0

var transformed_velocity := Vector3.ZERO

signal health_changed(current_health, max_health)

signal enemy_consumed(world_position, heal_amount)

func _ready():

	add_to_group("player")

	current_health = stats.max_health
	health_changed.emit(
	current_health,
	stats.max_health
	)

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

func handle_movement(delta):

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

	if current_state == State.NORMAL:

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

	else:

		var accel = stats.transformed_acceleration

		if direction != Vector3.ZERO and transformed_velocity.length() > 0.1:

			var dot_value = transformed_velocity.normalized().dot(
				direction
			)

			if dot_value < 0.0:
				accel = stats.transformed_braking

		if direction != Vector3.ZERO:

			transformed_velocity += (
				direction *
				accel *
				delta
			)

			if transformed_velocity.length() > stats.transformed_speed:

				transformed_velocity = (
					transformed_velocity.normalized()
					* stats.transformed_speed
				)

		transformed_velocity = (
			transformed_velocity.move_toward(
				Vector3.ZERO,
				stats.transformed_friction * delta
			)
		)

		velocity.x = transformed_velocity.x
		velocity.z = transformed_velocity.z

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

	animation_player.play("Transformacion_Fisica_v2")

	print("TRANSFORMED")

func end_transformation():

	current_state = State.NORMAL
	transformed_velocity = Vector3.ZERO
	animation_player.play("Transformacion_Reverse")
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

func heal(amount : int):

	current_health = min(
		current_health + amount,
		stats.max_health
	)

	health_changed.emit(
		current_health,
		stats.max_health
	)

func consume_enemy(enemy):

	heal(enemy.stats.heal_on_consumed)

	enemy_consumed.emit(
		enemy.global_position,
		enemy.stats.heal_on_consumed
	)

	enemy.die()

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
		consume_enemy(body)

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
