extends Area2D

@export var dogs : Array[DogResource]

var selected_dog : DogResource

func _ready() -> void:
	selected_dog = dogs.pick_random()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("dog collected!")

func get_dog_from_map() -> DogResource:
	return selected_dog
	
