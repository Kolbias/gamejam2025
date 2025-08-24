extends Node

signal change_state(state)
signal notification_sent(String)
signal add_dog(DogResource)
signal feed_dog
signal set_dog_collection
signal new_dog_collected(String)
signal send_warning
signal disable_warning

signal next_dog
signal prev_dog
signal disable_next
signal enable_next
signal disable_prev
signal enable_prev

var available_dogs : Array[DogResource]
var dogs : Array[DogResource] = []
var water : int = 0
var bones : int = 0
var all_dogs_collected := false

func _process(delta: float) -> void:
	if water >= 100:
		water = 100
