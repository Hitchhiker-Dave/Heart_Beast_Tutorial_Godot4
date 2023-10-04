#template for Character Body 2d
#Stopped tutorial at 38:55 mark
extends CharacterBody2D

#Variables not from the template
const ACCELERATION = 800
const FRICTION = 1000

#template variables
const SPEED = 100.0
const JUMP_VELOCITY = -250.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta 

func handle_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY #move and slide applies delta when changing velocity
			
	else: #Handling for Short Hops
		if Input.is_action_just_released("ui_accept") and velocity.y < JUMP_VELOCITY / 2: #If in the air and the jump key is released
			velocity.y = JUMP_VELOCITY / 2

func apply_friction(direction, delta):
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func handle_acceleration(direction, delta):
	if direction != 0: #Ie is a direction key being pressed
		velocity.x = move_toward(velocity.x, SPEED * direction, ACCELERATION * delta)

#physics process updates a set amount of times per second; default is 60fps
func _physics_process(delta):

	apply_gravity(delta)

	handle_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	handle_acceleration(direction, delta)
	
	apply_friction(direction, delta)

	move_and_slide()
