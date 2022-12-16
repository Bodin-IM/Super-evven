extends KinematicBody2D

var direction = Vector2.RIGHT #(1, 0) * -1 = (-1, 0) direction is originally 1 so mulitplying it by -1 will cause it to become -1 and 0
var velocity = Vector2.ZERO

onready var ledgeCheckRight: = $LedgeCheckRight
onready var ledgeCheckLeft: = $LedgeCheckLeft
onready var sprite: = $AnimatedSprite

func _physics_process(delta):
	var found_wall = is_on_wall() #checks if on wall
	var found_ledge = not ledgeCheckRight.is_colliding() or not ledgeCheckLeft.is_colliding() #if ledge is found check for not colliding
	if found_wall or found_ledge: #if a wall/ledge is found it will flip direction
		direction *= -1
	
	sprite.flip_h = direction.x > 0 #flip_h is true when greater than 0
	
	velocity = direction * 25
	move_and_slide(velocity, Vector2.UP) #uses vector to determine if something is a wall or not
