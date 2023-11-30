extends CharacterBody2D
class_name Guard


const SPEED = 50.0
const JUMP_VELOCITY = -400.0

enum LoopStyle { REPEAT, PING_PONG }

@export
var loop_style = LoopStyle.PING_PONG

@export var notch_parent: Node

@onready
var pivot = $Pivot
@onready
var animation_player = $AnimationPlayer
var notches
var current_notch: Notch = null
var index = -1
var loop_direction = 1

@onready var rc1 = $Pivot/RayCast2D
@onready var rc2 = $Pivot/RayCast2D2
@onready var rc3 = $Pivot/RayCast2D3

var paused = false
var flipped = false
var shooting = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var to_kill = null

func _ready():
	notches = notch_parent.get_children()
	next_notch()

func _physics_process(delta):
	if shooting == true:
		return
	
	if rc1.is_colliding():
		if rc1.get_collider() is Player:
			to_kill = rc1.get_collider()
			kill_player()
			return
	if rc2.is_colliding():
		if rc2.get_collider() is Player:
			to_kill = rc2.get_collider()
			kill_player()
			return
	if rc3.is_colliding():
		if rc3.get_collider() is Player:
			to_kill = rc3.get_collider()
			kill_player()
			return
	
	if current_notch == null:
		return
	
	if paused:
		velocity = Vector2.ZERO
		if current_notch.pause_timer.is_stopped():
			paused = false
			next_notch()
		return
	
	if current_notch.access == current_notch.Access.WALK:
		var direction = current_notch.position - position
		direction = direction.normalized()
		velocity = direction * SPEED
		if position.distance_to(current_notch.position) < 1:
			reached_notch()

	do_flip()
	animate()
	move_and_slide()
	

func kill_player():
	shooting = true
	animation_player.play("shoot")
	Engine.time_scale = 0.35
	to_kill.kill()

func confirm_kill():
	if to_kill != null:
		to_kill.confirm_kill()
	Engine.time_scale = 1

func animate():
	if velocity.x == 0:
		animation_player.play("idle")
	else:
		animation_player.play("walk")
		

func do_flip():
	if velocity.x != 0:
		if velocity.x < 0:
			flip(true)
		else:
			flip(false)

func flip(b: bool):
	if b == true:
		pivot.scale.x = -1
	else:
		pivot.scale.x = 1
	flipped = b

func reached_notch():
	position = current_notch.position
	velocity = Vector2.ZERO
	paused = true
	current_notch.pause_timer.start(current_notch.pause)

func next_notch():
	index += loop_direction
	if index >= len(notches) or index < 0:
		if loop_style == LoopStyle.PING_PONG:
			loop_direction *= -1
			index += loop_direction * 2
		else:
			# Repeat.
			index = 0
	current_notch = notches[index]
