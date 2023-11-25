#Modded template for Character Body 2d
## Bookmark: Part 13
extends CharacterBody2D

@export var movement_data : PlayerMovementData
var air_jump = false
var just_wall_jumped = false
var was_wall_normal = Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var wall_jump_timer = $WallJumpTimer
@onready var starting_position = global_position

#Movement Variables
@onready var ACCELERATION = movement_data.acceleration
@onready var FRICTION = movement_data.friction
@onready var SPEED = movement_data.speed
@onready var JUMP_VELOCITY = movement_data.jump_velocity
@onready var AIR_ACCELERATION = movement_data.air_acceleration

func _ready():
	
	
	
	pass

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta 

func handle_wall_jump():
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0: return
	
	var wall_normal = get_wall_normal() #detect where wall is pointing
	
	#Stores previous wall normal for wall coyote time
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
	
	if Input.is_action_just_pressed("jump") and wall_normal:
		velocity.x = wall_normal.x * SPEED 
		velocity.y = JUMP_VELOCITY
		just_wall_jumped = true
		
func handle_jump():
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		
		if Input.is_action_pressed("jump"): #used instead of is_action_just pressed for jump buffering
			velocity.y = JUMP_VELOCITY #move and slide applies delta when changing velocity
			
	#Must be an elif so that coyote time isn't overridden by the double jump
	elif not is_on_floor(): #Handling for Short Hops; not an else statement due to coyote time condition above
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY / 2: #If in the air and the jump key is released
			velocity.y = JUMP_VELOCITY / 2
			coyote_jump_timer.stop()
			
		#Double Jump
		if Input.is_action_just_pressed('jump') and air_jump and not just_wall_jumped:
			velocity.y = JUMP_VELOCITY * .9 #move and slide applies delta when changing velocity
			air_jump = false

func apply_friction(direction, delta):
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func handle_acceleration(direction, delta):
	if is_on_floor() and direction != 0: #Ie is a direction key being pressed
			velocity.x = move_toward(velocity.x, SPEED * direction, ACCELERATION * delta)
			
	if not is_on_floor() and direction != 0:
			velocity.x = move_toward(velocity.x, SPEED * direction, AIR_ACCELERATION * delta)
		
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

	handle_wall_jump()

	handle_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	
	handle_acceleration(direction, delta)
	
	apply_friction(direction, delta)

	#check if player was on floor before the move_and_slide update for Coyote Time
	var was_on_floor = is_on_floor() 
	var was_on_wall = is_on_wall_only()

	if was_on_wall:
		was_wall_normal = get_wall_normal()

	

	move_and_slide()
	
	#Coyote Time Handler
	#Normal Coyote Jumping
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()	

	just_wall_jumped = false
	
	#Coyote Wall Jump
	var just_left_wall = was_on_wall and not is_on_wall()
	if just_left_wall:
		wall_jump_timer.start()
		
	update_animations(direction)

#detect hazard; do not need to specifiy area as long as HazardDetector node looks towards the hazard layer
func _on_hazard_detector_area_entered(_area):
	#basically simulate instant death by "respawning" player at the starting position
	global_position = starting_position
