extends CharacterBody3D


#Variables for player movement
@export var speed = 5.0
@export var jump_velocity = 4.5
@export var runSpeed = 3
@export var sensitivity = 0.002

@onready var head = $Neck
@onready var camera = $Neck/Camera3D

#camera bob variables
const bobFreq = 2.0
const bobAmp = 0.08
var _bob = 0

func _ready():
	#Captures the mouse, makes it invisible and locks it to the center of the window.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#Checks every time the player does anything
func _unhandled_input(event):
	#Check for mouse motion 
	if event is InputEventMouseMotion:
		#Keeps the camera from rotating around the z axis
		#Rotates the camera 
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	##If not zero
	if direction:
		#If the player is holding the run input and is grounded, then increase speed by the runSpeed
		if Input.is_action_pressed("run") and is_on_floor():
			velocity.x = direction.x * (speed + runSpeed)
			velocity.z = direction.z * (speed + runSpeed)
		else:
			#else keep regular speed
			velocity.x = direction.x * (speed)
			velocity.z = direction.z * (speed)
	else:
		#Suppose to add friction but just stops the player
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	#head bob
	_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(_bob)
	
	#Using sin for vertical camera bob and cos for horizontal camera bob
	
	move_and_slide()

func _headbob(time) -> Vector3:
		var pos = Vector3.ZERO
		pos.y = sin(time*bobFreq) * bobAmp
		pos.x = cos(time* bobFreq / 2) * bobAmp
		return pos
