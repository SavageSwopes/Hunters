class_name CameraController
extends Node3D

var player_controller: PlayerController
var input_rotation: Vector3
var mouse_input: Vector2
var mouse_sensitivity: float = 0.005

var anchor: Marker3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_controller = get_parent()
	anchor = player_controller.get_node("Rig_Medium/Marker3D")
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input.x += -event.screen_relative.x * mouse_sensitivity
		mouse_input.y += -event.screen_relative.y * mouse_sensitivity
		
func _process(delta: float) -> void:
	input_rotation.x = clampf(input_rotation.x + mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
	input_rotation.y += mouse_input.x
	
	anchor.transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))
	
	
	#Rotate camera controller up and down
	transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))
	
	#rotate player left and right
	if player_controller:
		var target_basis = Basis.from_euler(Vector3(0.0, input_rotation.y, 0.0))
		player_controller.global_transform.basis = target_basis.scaled(player_controller.global_transform.basis.get_scale())
	
	global_transform.origin = anchor.global_transform.origin
	
	mouse_input = Vector2.ZERO
