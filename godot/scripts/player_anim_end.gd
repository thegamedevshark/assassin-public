extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = -400.0

@export var notch_parent: Node

@onready
var pivot = $Pivot
@onready
var animation_player = $AnimationPlayer
var notches
var current_notch: Notch = null
var index = -1
var loop_direction = 1
var has_shot = false

var paused = false
var flipped = false
var shooting = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	notches = notch_parent.get_children()
	next_notch()
	print(current_notch)

func _physics_process(delta):
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

func animate():
	if animation_player.current_animation == "shoot" and not has_shot:
		return
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
		# SHOOT!
		animation_player.play("shoot")
		#get_tree().reload_current_scene()
	else:
		current_notch = notches[index]

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


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		print("ENDDD")
		has_shot = true
		animation_player.play("idle")
		velocity.x = 0
