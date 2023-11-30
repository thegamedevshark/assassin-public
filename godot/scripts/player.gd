extends CharacterBody2D
class_name Player


const WALK_SPEED = 125.0
const ROLL_SPEED = 125.0
const CROUCH_SPEED = 75.0
const JUMP_VELOCITY = -400.0
const CLIMB_SPEED = 100.0

var conveyor_speed = 0
var on_conveyor = false

@onready var previous_position = position
@onready var pivot = $Pivot
@onready var animation_player = $AnimationPlayer
@onready var ledge_scanner = $Pivot/LedgeScanner
@onready var bar_scanner = $BarScanner
@onready var forward_bar_scanner = $Pivot/ForwardBarScanner
@onready var swing_timer = $SwingTimer
@onready var drop_timer = $DropTimer
@onready var ladder_scanner = $LadderScanner
@onready var ladder_exit_timer = $LadderExitTimer
@onready var stand_cast = $StandCast
@onready var stand_cast2 = $StandCast2

var speed = WALK_SPEED
var on_ledge = false
var grabbed_ledge = null
var flipped = false

var state = "normal"

var can_camera_follow = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2

var killed = false
var kill_confirmed = false

var ladder = null

func _physics_process(delta):
	if kill_confirmed == true:
		do_gravity(delta)
		move_and_slide()
		return
	elif killed:
		velocity = Vector2.ZERO
		return
	
	match state:
		"normal":
			do_gravity(delta)
			do_movement(delta)
			do_jump()
			do_flip()
			do_ladder_grabbing()
			animate_normal()
			if on_conveyor:
				velocity.x += conveyor_speed
		"ledge":
			velocity = Vector2.ZERO
			do_ledge()
		"climb":
			if not animation_player.is_playing():
				# Move player to climbed position.
				if grabbed_ledge != null:
					if flipped:
						position = grabbed_ledge.position + Vector2(-8, 0)
					else:
						position = grabbed_ledge.position + Vector2(8, 0)
					var direction = Input.get_axis("left", "right")
					if direction > 0 and flipped == false:
						# Roll right.
						animation_player.play("roll")
					elif direction < 0 and flipped == true:
						# Roll left.
						animation_player.play("roll")
					else:
						# Get up.
						animation_player.play("land")
				state = "normal"
		"bar":
			velocity = Vector2.ZERO
			do_bar()
		"ladder":
			do_ladder()

	var current = animation_player.current_animation
	if current == "roll" or current == "land_roll" or current == "end_roll":
		speed = ROLL_SPEED
	elif current == "crouch_idle" or current == "crouch_walk":
		speed = CROUCH_SPEED
	else:
		speed = WALK_SPEED

	if (is_on_floor() or state == "climb") and velocity.y >= 0:
		can_camera_follow = true
	elif state == "ladder":
		can_camera_follow = true
	else:
		can_camera_follow = false

	previous_position = position
	move_and_slide()
	

func kill():
	killed = true
	kill_confirmed = false
	animation_player.play("death")
	animation_player.pause()
	velocity = Vector2.ZERO
	sfx_shoot()

func confirm_kill():
	kill_confirmed = true
	animation_player.play()

func completely_dead():
	get_tree().reload_current_scene()

func do_ladder_grabbing():
	if not ladder_exit_timer.is_stopped():
		return
	if Input.is_action_pressed("climb") and ladder != null:
		state = "ladder"
		position.x = ladder.position.x
		velocity = Vector2.ZERO

func do_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func do_ladder():
	if Input.is_action_just_pressed("jump"):
		state = "normal"
		jump()
		ladder_exit_timer.start()
		return
	if Input.is_action_pressed("climb") or Input.is_action_pressed("drop"):
		print("CLIMKLFNB")
		if Input.is_action_pressed("climb"):
			velocity.y = -CLIMB_SPEED
		else:
			velocity.y = CLIMB_SPEED
		animation_player.play("climb")
	else:
		velocity.y = 0
		print("PAUSDED")
		animation_player.pause()
	return

func do_movement(delta):
	var direction = Input.get_axis("left", "right")
	var current = animation_player.current_animation
	if direction:
		velocity.x = direction * speed
	elif current == "roll" or current == "land_roll" or current == "end_roll":
		if flipped:
			velocity.x = -1 * speed
		else:
			velocity.x = 1 * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func do_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()

func jump():
	velocity.y = JUMP_VELOCITY

func do_flip():
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		if direction < 0:
			flip(true)
		else:
			flip(false)

func flip(b: bool):
	if b == true:
		pivot.scale.x = -1
	else:
		pivot.scale.x = 1
	flipped = b

func do_ledge():
	if Input.is_action_just_pressed("drop"):
		# Drop down.
		state = "normal"
	elif Input.is_action_pressed("right") and Input.is_action_just_pressed("jump") and flipped == false:
		# Climb up (RIGHT).
		animation_player.play("ledge_climb")
		state = "climb"
	elif Input.is_action_pressed("left") and Input.is_action_just_pressed("jump") and flipped == true:
		# Climb up (LEFT).
		animation_player.play("ledge_climb")
		state = "climb"
	elif Input.is_action_just_pressed("jump"):
		# Jump up.
		state = "normal"
		jump()
		if flipped:
			velocity.x = speed
		else:
			velocity.x = -speed

func do_bar():
	var current = animation_player.current_animation
	if Input.is_action_just_pressed("drop"):
		# Drop down.
		state = "normal"
		drop_timer.start()
	elif Input.is_action_pressed("right") and flipped == true:
		flip(false)
		animation_player.play("bar_grab")
	elif Input.is_action_pressed("left") and flipped == false:
		flip(true)
		animation_player.play("bar_grab")
	elif Input.is_action_pressed("right") and current != "bar_grab":
		# Move to next bar.
		attempt_swing()
	elif Input.is_action_pressed("left") and current != "bar_grab":
		# Move to next bar.
		attempt_swing()

func attempt_swing():
	if len(forward_bar_scanner.bars) > 0 and swing_timer.is_stopped():
		swing_to_bar(forward_bar_scanner.bars[0])
		swing_timer.start()
	else:
		if swing_timer.is_stopped() and Input.is_action_pressed("jump"):
			# Jump off.
			state = "normal"

func swing_to_bar(bar):
	# Snap to ledge scanner position.
	var difference = global_position - bar_scanner.global_position
	position = bar.position + difference

var air = 125
func animate_normal():
	var current = animation_player.current_animation
	if not is_on_floor():
		if velocity.y < air and velocity.y > -air:
			animation_player.play("air")
			return
		if velocity.y < 0:
			animation_player.play("jump")
			return
		if velocity.y > 0:
			animation_player.play("fall")
			return
	if is_on_floor():
		if current == "jump" or current == "air" or current == "fall":
			if abs(velocity.x) > 0.1: animation_player.play("land_roll")
			else: 
				animation_player.play("land")
			return
		if current == "land" and Input.is_action_pressed("crouch"):
			animation_player.play("crouch_idle")
		if current == "land" and not animation_player.is_playing():
			animation_player.play("idle")
			return
		if current == "land" or current == "roll" or current == "land_roll" or current == "end_roll":
			if abs(velocity.x) > 0.1:
				animation_player.play("land_roll")
			elif current == "land_roll":
				animation_player.play("end_roll")
			return
		if abs(velocity.x) > 0.1 and abs(position.x - previous_position.x) > 0.1:
			if Input.is_action_pressed("crouch") or stand_cast.is_colliding() or stand_cast2.is_colliding():
				animation_player.play("crouch_walk")
			else:
				animation_player.play("walk")
			return
		if Input.is_action_pressed("crouch") or stand_cast.is_colliding() or stand_cast2.is_colliding():
			animation_player.play("crouch_idle")
		else:
			animation_player.play("idle")

func _on_ledge_scanner_area_entered(area):
	if killed:
		return
	state = "ledge"
	animation_player.play("ledge_grab")
	grabbed_ledge = area
	
	# Snap to ledge scanner position.
	var difference = global_position - ledge_scanner.global_position
	position = area.position + difference

func _on_bar_scanner_area_entered(area):
	if killed:
		return
	if not drop_timer.is_stopped():
		return
	state = "bar"
	animation_player.play("bar_grab")
	swing_timer.start()
	
	# Snap to ledge scanner position.
	var difference = global_position - bar_scanner.global_position
	position = area.position + difference

func _on_ladder_scanner_area_entered(area):
	if killed:
		return
	ladder = area

func _on_ladder_scanner_area_exited(area):
	if killed:
		return
	ladder = null
	state = "normal"
	ladder_exit_timer.start()

func sfx_step():
	$Footstep.play()

func sfx_jump():
	$Jump.play()

func sfx_swing():
	$Footstep.play()

func sfx_shoot():
	$Shoot.play()

func sfx_thump():
	$Thump.play()
