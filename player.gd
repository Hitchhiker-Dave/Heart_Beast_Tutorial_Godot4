#template for Character Body 2d
##rewatch Custom Resources vid; it's easy to understand I just didn't follow from the start like a fool
extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

#Variables not from the template
const ACCELERATION = 800
const FRICTION = 1000

#template variables
const SPEED = 100.0
const JUMP_VELOCITY = -250.0

#Custom Var
# var was_on_floor
# var just_left_ledge

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta 

func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY #move and slide applies delta when changing velocity
			
	if not is_on_floor(): #Handling for Short Hops; not an else statement due to coyote time condition above
		if Input.is_action_just_released("ui_accept") and velocity.y < JUMP_VELOCITY / 2: #If in the air and the jump key is released
			velocity.y = JUMP_VELOCITY / 2

func apply_friction(direction, delta):
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func handle_acceleration(direction, delta):
	if direction != 0: #Ie is a direction key being pressed
		velocity.x = move_toward(velocity.x, SPEED * direction, ACCELERATION * delta)

func update_animations(direction):
	#updates animation based on player velocity
	#following if-else tree works only in this order
	if direction != 0: #player is moving
		animated_sprite_2d.flip_h = (direction < 0) #flips sprite in direction of movement
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")

#physics process updates a set amount of times per second; default is 60fps
func _physics_process(delta):

	apply_gravity(delta)

	handle_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	handle_acceleration(direction, delta)
	
	apply_friction(direction, delta)

	#check if player was on floor before the move_and_slide update for Coyote Time
	var was_on_floor = is_on_floor() 

	update_animations(direction)

	move_and_slide()
	
	#Coyote Time Handler
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()	
