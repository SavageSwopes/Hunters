extends CharacterBody3D

class_name NPCGeneric

@export var destinations_array:Array[Marker3D]

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
