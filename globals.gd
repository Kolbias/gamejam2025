extends Node

signal change_state(state)
signal notification_sent(String)
signal add_dog(DogResource)
signal feed_dog
signal set_dog_collection
signal new_dog_collected(String)

signal next_dog
signal prev_dog

var available_dogs : Array[DogResource]
var dogs : Array[DogResource] = []
var water : int = 0
var bones : int = 0

func _process(delta: float) -> void:
	if water >= 100:
		water = 100
