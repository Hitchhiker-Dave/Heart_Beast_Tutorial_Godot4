#template for Character Body 2d
#Stopped tutorial at 30:37 mark
extends CharacterBody2D

#Variables not from the template
const ACCELERATION = 800
const FRICTION = 1000

#template variables
const SPEED = 100.0
const JUMP_VELOCITY = -250.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#physics process updates a set amount of times per second; default is 60fps
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY #move and slide applies delta when changing velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0: #Ie is a direction key bing pressed
		velocity.x = move_toward(velocity.x, SPEED * direction, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	move_and_slide()
