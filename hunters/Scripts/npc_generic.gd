extends CharacterBody3D

class_name NPCGeneric

@export var destinations_array:Array[Marker3D]
@export var speed = 2

#How the npc finds a path to marker
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
#How long the npc is idle
@onready var idle_timer: Timer = $IdleTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


enum NPCState{
	Idle,
	Walking
}
"""
Npc's should have variables to track their needs so that they can be assigned the correct state
- Hunger variable
- Exhaustion variable
- Bordom varivable
They should also have different variable to assign personalities/habbits
Not all npc's should have the same habit.
"""
var current_state:NPCState = NPCState.Idle
var current_destination:Marker3D


func _ready() -> void:
	_set_state(NPCState.Idle)
	

#Change npc state
func _set_state(new_state:NPCState) -> void:
	current_state = new_state
	
	match current_state:
		NPCState.Idle:
			animation_player.play("T-Pose")
			idle_timer.start(2.0 + randf())
		NPCState.Walking:
			animation_player.play("Walking_A")

func _physics_process(delta: float) -> void:
		match current_state:
			NPCState.Idle:
				animation_player.play("T-Pose")
			NPCState.Walking:
				#Sets the next path possible equal to the navigation agent 3ds next position
				var next_path_pos:Vector3 = navigation_agent_3d.get_next_path_position()
				var new_velocity:Vector3 = global_position.direction_to(next_path_pos) * speed
				velocity = new_velocity
				#Make npc look forward
				var look_at_target:Vector3 = Vector3(next_path_pos.x, global_position.y, next_path_pos.z)
				if not global_position.is_equal_approx(look_at_target):
					look_at(look_at_target)
				move_and_slide()
				animation_player.play("Walking_A")
func _on_idle_timer_timeout() -> void:
	decide_next_state()

#If idle, calls get_new_target and _set_state
func decide_next_state() -> void:
	if current_state == NPCState.Idle:
		get_new_target()
		_set_state(NPCState.Walking)

#Sets the current destination to a random marker
#Sets the 3d navigation agents target position to the global position of current destination
func get_new_target():
	current_destination = destinations_array.pick_random()
	navigation_agent_3d.target_position = current_destination.global_position
	

#The npc got as close to the target as it could
func _on_navigation_agent_3d_navigation_finished() -> void:
	_set_state(NPCState.Idle)
