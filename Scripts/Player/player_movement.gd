extends CharacterBody3D

# Movement variables
const WALK_SPEED: float = 5.0
const SPRINT_SPEED: float = 7.5
const CROUCH_SPEED: float = 2.5
const ACCELERATION: float = 3.5
const DEACCELERATION: float = 5.0

var current_speed: float = WALK_SPEED

# Camera variables
const MOUSE_SENSITIVITY: float = 0.0025
const MOUSE_LOOK_UP_CLAMP: float = deg_to_rad(-80)
const MOUSE_LOOK_DOWN_CLAMP: float = deg_to_rad(90)
const CAMERA_ACCELERATION: float = 6.0

var wobble: float = 0.0
var wobble_speed:float = 8.0
var wobble_amount: float = 0.01

@onready var neck: Node3D = $Neck
var neck_position: Vector3
const NECK_STANDING_POSITION: Vector3 = Vector3(0.0, 0.75, 0.0)
const NECK_CROUCHING_POSITION: Vector3 = Vector3(0.0, 0.1, 0.0)

var look_input: Vector2 = Vector2.ZERO

@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision
@onready var standing_check: RayCast3D = $StandingCheck

# States
var crouching: bool = false
var sprinting: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_input.x -= event.relative.y * MOUSE_SENSITIVITY
		look_input.y += event.relative.x * MOUSE_SENSITIVITY
		
		look_input.x = clamp(look_input.x, MOUSE_LOOK_UP_CLAMP, MOUSE_LOOK_DOWN_CLAMP)

func _physics_process(delta: float) -> void:
	# Get input direction
	var input_direction: Vector2 = Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_back")
	
	# Set states
	if Input.is_action_pressed("crouch"):
		crouching = true
		sprinting = false
	elif Input.is_action_pressed("sprint"):
		crouching = false
		sprinting = true
	else:
		crouching = false
		sprinting = false
	
	# Apply crouch
	if crouching:
		crouching_collision.disabled = false
		standing_collision.disabled = true
		neck_position = NECK_CROUCHING_POSITION
	elif standing_check.is_colliding():
		crouching_collision.disabled = false
		standing_collision.disabled = true
		neck_position = NECK_CROUCHING_POSITION
		crouching = true
	else:
		crouching_collision.disabled = true
		standing_collision.disabled = false
		neck_position = NECK_STANDING_POSITION

	neck.position = lerp(neck.position, neck_position, CAMERA_ACCELERATION * delta)
	
		# Calculate current speed
	current_speed = CROUCH_SPEED if crouching else SPRINT_SPEED if sprinting else WALK_SPEED 
	
	# Calculate movement vector
	var movement_vector: Vector3 = Vector3(input_direction.x, 0.0, input_direction.y) * current_speed
	
	movement_vector = transform.basis * movement_vector
	
	# Accelerate when you are moving, deaccelerate when you are not
	if input_direction != Vector2.ZERO:
		velocity = lerp(velocity, movement_vector, ACCELERATION * delta)
	else:
		velocity = lerp(velocity, Vector3.ZERO, DEACCELERATION * delta)
	
	
	# Apply movement
	move_and_slide()
	
	# Apply camera movement
	neck.rotation.x = look_input.x
	rotation.y = -look_input.y

	if input_direction != Vector2.ZERO:
		wobble += wobble_speed * delta
	else:
		wobble = lerp(wobble, 0.0, 5.0 * delta)

	neck.position.y += sin(wobble) * wobble_amount
