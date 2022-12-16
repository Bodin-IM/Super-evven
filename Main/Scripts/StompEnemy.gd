extends Node2D

enum {HOVER, FALL, LAND, RISE}

var state = HOVER

onready var start_position = global_position
onready var timer = $Timer
onready var raycast: = $RayCast2D
onready var animatedSprite = $AnimatedSprite
onready var particles: = $Particles2D

func _physics_process(delta): #defines four states 
	match state: #each state has own function that defines behaviour
		HOVER: hover_state() #match is used to execute function corresponding to current state
		FALL: fall_state(delta)
		LAND: land_state()
		RISE: rise_state(delta)

func hover_state():
	state = FALL
	
func fall_state(delta): 
	animatedSprite.play("Falling") #plays falling animation
	position.y += 100 * delta #moves downard by 100 units per second
	if raycast.is_colliding(): #checks if object is colliding with someting using raycast
		var collision_point = raycast.get_collision_point() #object position is set to collision point and state changes
		position.y = collision_point.y
		state = LAND
		timer.start(1.0)
		particles.emitting = true
		
func land_state(): #just checks if timer has run out. if it has the state changes
	if timer.time_left == 0:
		state = RISE
	
	
func rise_state(delta): #plays animation and oves object toward starting position.
	animatedSprite.play("Rising")
	position.y = move_toward(position.y, start_position.y, 20 * delta)		
	if position.y == start_position.y:
		state = HOVER #changes state back to hover
