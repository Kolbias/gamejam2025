extends Area2D

#@export var dogs : Array[DogResource]

var selected_dog : DogResource = null

func _ready() -> void:
	Globals.connect("hide_dog", hide_dog)
	%MapIcon.frame = randi_range(0,7)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("dog collected!")

func get_dog_from_map() -> DogResource:
	if Globals.available_dogs.is_empty():
		return null
	selected_dog = Globals.available_dogs.pop_at(randi_range(0, Globals.available_dogs.size() - 1))
	return selected_dog

func hide_dog():
	%MapIcon.hide()
