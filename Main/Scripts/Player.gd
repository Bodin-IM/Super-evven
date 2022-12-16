extends KinematicBody2D
class_name Player
#liste av konstanter
enum {MOVE, CLIMB} #2 consts

#Player skin load
export(Resource) var moveData = preload("res://Main/Resources/DefaultPlayerMovementData.tres") as PlayerMovementData

#variabler
var velocity = Vector2.ZERO
var fast_fell = false
var state = MOVE
var double_jump = 1
var buffered_jump = false
var coyote_jump = false

#onready variabler
onready var animatedSprite = $AnimatedSprite
onready var ladderCheck = $LadderCheck
onready var jumpBufferTimer = $JumpBufferTimer
onready var coyoteJumpTimer = $CoyoteJumpTimer
onready var remoteTransform2D: = $RemoteTransform2D

#functions
func _physics_process(_delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state: #if the state matches move or climb it will call function
		MOVE: move_state(input)
		CLIMB: climb_state(input)

func move_state(input):
	
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB
		
	apply_gravity()
	if input.x == 0:
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = input.x > 0
		
	if is_on_floor():
		double_jump = moveData.DOUBLE_JUMP_COUNT #reset double jump
	
	if is_on_floor() or coyote_jump:
		fast_fell = false
		
		input_jump()
	else:
		animatedSprite.animation = "Jump"
		if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE_FORCE:
			velocity.y = moveData.JUMP_RELEASE_FORCE
		
		if Input.is_action_just_pressed("ui_up") and double_jump > 0:
			velocity.y = moveData.JUMP_FORCE
			double_jump -= 1
			
			
		if Input.is_action_just_pressed("ui_up"):
			buffered_jump = true
			jumpBufferTimer.start()
		
		if velocity.y  > 10 and not fast_fell:
			velocity.y += moveData.ADDITINOAL_FALL_GRAVITY
			fast_fell = true
	var was_in_air = is_on_floor()
	var was_on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	var just_landed = is_on_floor() and not was_in_air
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()

func input_jump():
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		velocity.y = moveData.JUMP_FORCE
		buffered_jump = false		

func climb_state(input):
	if not is_on_ladder(): state = MOVE
	if input.length() != 0: #if the lenght isnt 0 it will change animation
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)

func player_die():
	SoundPlayer.play_sound()
	queue_free()
	Events.emit_signal("player_died")

func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path

func is_on_ladder(): #determines if on ladder
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true
	
func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, 300)
	
func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)
	
func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false
