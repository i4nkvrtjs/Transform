extends CharacterBody3D

class_name Player

enum State
{
	NORMAL,
	TRANSFORMED,
	DASHING
}

@export var stats : PlayerStats
@export var slam_indicator_scene : PackedScene
@export var shrine_director_path : NodePath

@onready var shrine_arrow_pivot = $ShrineArrowPivot
@onready var animation_player : AnimationPlayer = $Visuals/Cha_42/AnimationPlayer
@onready var visuals : Node3D = $Visuals
@onready var damage_area : Area3D = $Area3D
@onready var animation_tree = $Visuals/Cha_42/AnimationTree

var state_machine : AnimationNodeStateMachinePlayback

var current_state : State = State.NORMAL

var current_health : int

var transform_timer : float = 0.0

var knockback_velocity : Vector3 = Vector3.ZERO

var hit_stun_timer : float = 0.0

var invulnerability_timer : float = 0.0

var transformed_velocity := Vector3.ZERO

var dash_timer := 0.0

var dash_cooldown_timer := 0.0

var dash_direction := Vector3.ZERO

var slam_timer := 0.0

var slam_active:= false

var shrine_director

signal health_changed(current_health, max_health)

signal enemy_consumed(world_position, heal_amount)

func _ready():

	add_to_group("player")

	current_health = stats.max_health

	shrine_director = get_node_or_null(shrine_director_path)

	health_changed.emit(
		current_health,
		stats.max_health
	)

	damage_area.body_entered.connect(
		_on_damage_area_body_entered
	)

	animation_tree.active = true

	state_machine = animation_tree.get(
		"parameters/playback"
	)

func _physics_process(delta):

	handle_transformation(delta)

	update_hit_stun(delta)

	update_invulnerability(delta)

	update_dash_cooldown(delta)

	handle_ability_input()

	handle_movement(delta)

	update_dash(delta)

	update_slam(delta)

	update_knockback(delta)

	update_shrine_arrow()

	move_and_slide()

func handle_movement(delta):

	if current_state == State.DASHING:
		return

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

	if current_state in [
		State.NORMAL,
		State.DASHING
	]:

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

	elif current_state == State.TRANSFORMED:

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

	if !is_transformed():
		return

	transform_timer -= delta

	if transform_timer <= 0.0:
		end_transformation()

func start_transformation():

	current_state = State.TRANSFORMED

	transform_timer = (
		stats.transformed_duration
	)

	state_machine.travel("Transformacion_Fisica_v2")

	print("TRANSFORMED")

func end_transformation():

	current_state = State.NORMAL

	transformed_velocity = Vector3.ZERO

	state_machine.travel("Transformacion_Reverse")

	print("NORMAL")

func is_transformed() -> bool:

	return current_state == State.TRANSFORMED

func take_damage(amount : int):

	if invulnerability_timer > 0:
		return

	invulnerability_timer = stats.invulnerability_time

	current_health -= amount

	health_changed.emit(
		current_health,
		stats.max_health
	)

	state_machine.travel(
		"TakeDamage"
	)

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

func handle_ability_input():

	if !Input.is_action_just_pressed(
		"ability"
	):
		return

	if current_state == State.NORMAL:

		start_dash()

	elif current_state == State.TRANSFORMED:

		start_slam()

func start_dash():

	if dash_cooldown_timer > 0:
		return

	var input_dir := Vector2(
		Input.get_axis(
			"ui_left",
			"ui_right"
		),
		Input.get_axis(
			"ui_up",
			"ui_down"
		)
	)

	if input_dir == Vector2.ZERO:
		return

	dash_direction = Vector3(
		input_dir.x,
		0,
		input_dir.y
	).normalized()

	current_state = State.DASHING

	dash_timer = stats.dash_duration

	dash_cooldown_timer = (
		stats.dash_cooldown
	)

func update_dash(delta):

	if current_state != State.DASHING:
		return

	dash_timer -= delta

	velocity.x = (
		dash_direction.x *
		stats.dash_speed
	)

	velocity.z = (
		dash_direction.z *
		stats.dash_speed
	)

	if dash_timer <= 0.0:

		velocity = Vector3.ZERO

		current_state = State.NORMAL

func start_slam():

	if slam_active:
		return

	slam_active = true

	slam_timer = stats.slam_duration

	velocity = Vector3.ZERO

	state_machine.start("Slam")
	#animation_player.play("slam")

func update_slam(delta):

	if !slam_active:
		return

	slam_timer -= delta

	if slam_timer <= 0.0:

		do_slam_damage()
		slam_active = false
		current_state = State.TRANSFORMED

func do_slam_damage():

	if slam_indicator_scene:

		var indicator = slam_indicator_scene.instantiate()

		get_parent().add_child(indicator)

		indicator.global_position = global_position

		indicator.setup(stats.slam_radius)

	var enemies = get_tree().get_nodes_in_group(
		"enemy"
	)

	for enemy in enemies:

		if enemy.global_position.distance_to(
			global_position
		) <= stats.slam_radius:

			consume_enemy(enemy)

func update_dash_cooldown(delta):

	if dash_cooldown_timer > 0.0:

		dash_cooldown_timer -= delta

func update_shrine_arrow():

	if shrine_director == null:
		return

	var shrine = shrine_director.get_current_shrine()

	if shrine == null:

		shrine_arrow_pivot.visible = false

		return

	shrine_arrow_pivot.visible = true

	var direction = (
		shrine.global_position -
		global_position
	)

	direction.y = 0

	if direction.length_squared() < 0.01:
		return

	shrine_arrow_pivot.look_at(
		global_position + direction,
		Vector3.UP
	)

	var time = (
		Time.get_ticks_msec()
		* 0.001
	)

	shrine_arrow_pivot.position.y = (
		3.0 +
		sin(time * 4.0) * 0.25
	)
