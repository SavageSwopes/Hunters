class_name PlayerController
extends CharacterBody3D


#Variables for player movement
var input_dir: Vector2
var direction
@export var walkingSpeed = 5.0
@export var jump_velocity = 4
@export var half_jump = 0.5
@export var runSpeed = 7
@export var crouchSpeed = 2
@export var crawlSpeed = 1
@export var currentSpeed : float
var is_crawling: bool = false
var is_crouching: bool = false
var is_running: bool
var is_moving
var crouch
@export var crouchDepth: float = -0.6
@export var headHight: float = 0
@export var crawlDepth: float = -1.2


@onready var head: Node3D = $RootNode
@onready var camera: Camera3D = $RootNode/Camera3D
@onready var camera_origin = camera.transform.origin
@onready var camera_running: Vector3 = Vector3(-0.004, 1.648, -0.197)
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var standing_check: RayCast3D = $RayCast3D
@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision
@onready var crawling_collision: CollisionShape3D = $CrawlingCollision

#Player Settings
@export var base_fov: float = 85
@export var sensitivity = 0.002


#camera bob variables
const bobFreq = 2.0
const bobAmp = 0.08
const BASE_FOV = 75.0
const FOV_CHANGE = 1.2
var _bob = 0
@export var lerpSpeed : float = 10.0

enum PlayerState
{
	IDLE_STAND,
	IDLE_CROUCH,
	IDLE_CRAWL,
	CROUCHING, 
	CRAWLING,
	WALKING,
	RUNNING,
	AIR
}
var player_state: PlayerState = PlayerState.IDLE_STAND

#Camera position

func _ready():
	#Captures the mouse, makes it invisible and locks it to the center of the window.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crouching_collision.disabled = true
	
#Checks every time the player does anything
func _unhandled_input(event):
	#Check for mouse motion 
	if event is InputEventMouseMotion:
		#Keeps the camera from rotating around the z axis
		#Rotates the camera 
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-55), deg_to_rad(85))



		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	updatePlayerState()
	updateCamera(delta)
	
	if not is_on_floor():
		if velocity.y >= 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 2

	# Handle jump.
	if is_on_floor():
		if !standing_check.is_colliding():
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity
	#If the player is not on the floor and is still going up and the jump button was released
	#Multiply by the half_jump variable
	elif not is_on_floor():
		if velocity.y > 0 and Input.is_action_just_released("jump"):
			velocity.y *= half_jump
	
	if Input.is_action_just_pressed("pause"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Get the input direction and handle the movement/deceleration.
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#If not zero
	if direction:
		#If the player is holding the run input and is grounded, then increase speed by the runSpeed
		if Input.is_action_pressed("run") and is_on_floor():
			velocity.x = direction.x * (currentSpeed)
			velocity.z = direction.z * (currentSpeed)
		else:
			#else keep regular speed
			velocity.x = direction.x * (currentSpeed)
			velocity.z = direction.z * (currentSpeed)
	else:
		#Suppose to add friction but just stops the player
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)
	#If the player is moving and on floor


	
	move_and_slide()
		

func _headbob(time) -> Vector3:
	#Using sin for vertical camera bob and cos for horizontal camera bob
	var pos = Vector3.ZERO
	pos.y = sin(time*bobFreq) * bobAmp
	pos.x = cos(time* bobFreq / 2) * bobAmp
	return pos

func updatePlayerState() -> void:
	is_moving = (input_dir != Vector2.ZERO)
	
	if not is_on_floor():
		player_state = PlayerState.AIR
	else:
		if Input.is_action_just_pressed("crawl"):
			is_crawling = !is_crawling
			is_crouching = false
		elif Input.is_action_pressed("crouch"):
			is_crouching = true
			is_crawling = false
		elif not Input.is_action_just_pressed("crouch") and !is_crawling:
			is_crouching = false 
		#If the player is holding crouch assign state depending on if they are moving
		if is_crawling:
			if not is_moving:
				player_state = PlayerState.IDLE_CRAWL
			else:
				player_state = PlayerState.CRAWLING
		elif is_crouching:
			if not is_moving:
				player_state = PlayerState.IDLE_CROUCH
			else:
				player_state = PlayerState.CROUCHING
		#If they are able to uncrouch based on the RayCast3D
		elif !standing_check.is_colliding():
			if !is_crawling:
				if not is_moving:
					player_state = PlayerState.IDLE_STAND
					animation_player.play("CharacterArmature|Idle")
				elif Input.is_action_pressed("run"):
					player_state = PlayerState.RUNNING
					animation_player.play("CharacterArmature|Run")
				else:
					player_state = PlayerState.WALKING
					animation_player.play("CharacterArmature|Walk")
	updatePlayerColShape(player_state)
	updatePlayerSpeed(player_state)

func updatePlayerColShape(_player_state: PlayerState) -> void:
	#If the player is crouching turn off standing collision and turn on crouching collision
		#Else if they are crawling turn off standing and crouching collision and turn on crawling collision
		if _player_state == PlayerState.IDLE_CRAWL or _player_state == PlayerState.CRAWLING:
			standing_collision.set_deferred("disabled", true)
			crouching_collision.set_deferred("disabled", true)
			crawling_collision.set_deferred("disabled", false)
		elif _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH:
			standing_collision.set_deferred("disabled", true)
			crouching_collision.set_deferred("disabled", false)
			crawling_collision.set_deferred("disabled", true	)
		else:
			standing_collision.set_deferred("disabled", false)
			crouching_collision.set_deferred("disabled", true)
			crawling_collision.set_deferred("disabled", true)
	
func updatePlayerSpeed(_player_state: PlayerState) -> void:
	if _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH:
		currentSpeed = crouchSpeed
	elif _player_state == PlayerState.CRAWLING or _player_state == PlayerState.IDLE_CRAWL:
		currentSpeed = crawlSpeed
	elif _player_state == PlayerState.WALKING:
		currentSpeed = walkingSpeed
	elif _player_state == PlayerState.RUNNING:
		currentSpeed = runSpeed

func updateCamera(delta: float) -> void:
	#head bob
	
	if player_state == PlayerState.CROUCHING or player_state == PlayerState.IDLE_CROUCH:
		#Lerp the head to the croching depth
		head.position.y = lerp(head.position.y, headHight + crouchDepth, delta*lerpSpeed)
	elif player_state == PlayerState.CRAWLING or player_state == PlayerState.IDLE_CRAWL:
		head.position.y = lerp(head.position.y, headHight + crawlDepth, delta*lerpSpeed)
	elif player_state == PlayerState.IDLE_STAND:
		head.position.y = lerp(head.position.y, headHight, delta*lerpSpeed)
	elif player_state == PlayerState.WALKING:
		head.position.y = lerp(head.position.y, headHight, delta*lerpSpeed)
	elif player_state == PlayerState.RUNNING:
		head.position.y = lerp(head.position.y, headHight, delta*lerpSpeed)
	#If the player is moving and is on the floor then call headbob
	if (!is_zero_approx(velocity.x) or !is_zero_approx(velocity.z)) and is_on_floor():
		_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(_bob) + camera_origin
	#Else if the player isn't moving, lerp the camera position to the original position
	else:
		_bob = move_toward(_bob, 0.0, delta * 6.0)
		camera.transform.origin = lerp(camera.transform.origin,camera_origin,0.2)
	#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, currentSpeed * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
