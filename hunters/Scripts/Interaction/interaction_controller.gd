extends Node

@onready var interactionController: Node = %InteractionController
@onready var interactionRaycast: RayCast3D = %InteractionRaycast
@onready var playerCamera: Camera3D = %PlayerCamera


#Current object we are already interacting with
var currentObject: Object

#A reference to the last thine we could have been interacting with
var lastPotentialObject: Object

#A reference to the interaction compoentent. The node on the object
var interactionComponent: Node

func _process(delta: float) -> void:
	
	#If on the previous frame we were interacting with another object,
	#Keep interacting with another object
	if currentObject:
		if Input.is_action_pressed("primary attack"):
			if interactionComponent:
				interactionComponent.interact()
		else:
			if interactionComponent:
				interactionComponent.postInteract()
				currentObject = null
	else: #we weren't interacting with something, see if we can
		#Returns what raycast hits
		var potentialObject: Object = interactionRaycast.get_collider()
		
		#If colliding with object and the object is interactable
		if potentialObject and potentialObject is Node: 
			#Check if object has interaction compontent and return object or null
			interactionComponent = potentialObject.get_node_or_null("InteractionComponent")
			if interactionComponent:
				#If not allowed to be interacted with
				if interactionComponent.canInteract == false:
					return
					
				lastPotentialObject = currentObject
				
				if Input.is_action_just_pressed("primary attack"):
					currentObject = potentialObject
					interactionComponent.preInteract()
