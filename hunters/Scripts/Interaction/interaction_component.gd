extends Node

#This is defined on individual objects in the game

enum InteractionType
{
	DEFAULT,
}

@export var objectRef: Node3D 
@export var interactionType: InteractionType = InteractionType.DEFAULT

#If the player can interact
var canInteract: bool = true

var isInteracting: bool = false

var playerHand: Marker3D

func _ready() -> void:
	pass
	

#Run once, when the player FIRST clicks on an object to interact with
func preInteract() -> void:
	isInteracting = true
	match interactionType:
		InteractionType.DEFAULT:
			#Get all the nodes in the scene, starting from the root, find a node named "Hand", it searches recursivly and it doesn't need to be owned
			playerHand = get_tree().get_root().find_child("Hand", true, false)

#Run every frame, and perform some logic on this object
func interact() -> void:
	if not canInteract:
		return
	match interactionType:
		InteractionType.DEFAULT:
			_defaultInteract()

#Runs once, when the player LAST interacts with an object
func postInteract() -> void:
	isInteracting = false

func _input(event: InputEvent) -> void:
	pass
	
func _defaultInteract() -> void:
	#Where the item is in the world
	var objectCurrentPosition: Vector3 = objectRef.global_transform.origin
	#Where the players hand is
	var playerHandPosition: Vector3 = playerHand.global_transform.origin
	#The distance in between the two
	var objectDistance: Vector3 = playerHandPosition - objectCurrentPosition
	#Object is throwable and interacts with world
	var rigidBody3D: RigidBody3D = objectRef as RigidBody3D
	#If rigidBody3D isn't null
	if rigidBody3D:
		#Pickup logic                               Gives the object weight, heavier objects move slower when held
		rigidBody3D.set_linear_velocity((objectDistance)* (5/rigidBody3D.mass))
	
	
	
	
	
	
	
	
