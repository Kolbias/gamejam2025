extends Node

signal change_state(state)
signal notification_sent(String)
signal add_dog(DogResource)
signal feed_dog
signal set_dog_collection

signal next_dog
signal prev_dog

var dogs : Array[DogResource] = []
var water : int = 0
var bones : int = 0
