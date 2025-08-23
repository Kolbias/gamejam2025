extends Control
class_name DogDisplay

@export var dog : DogResource

func _ready() -> void:
	%Dog.position += Vector2(16,16)
func set_display(new_dog : DogResource) -> void:
	dog = new_dog
	dog.setup_frames()
	if dog.happiness < 25:
		%Dog.texture = dog.frames["happy"][0]
	if dog.happiness > 25 and dog.happiness < 50:
		%Dog.texture = dog.frames["happy"][1]
	if dog.happiness > 50 and dog.happiness < 75:
		%Dog.texture = dog.frames["happy"][2]
	if dog.happiness > 75 and dog.happiness < 100:
		%Dog.texture = dog.frames["happy"][3]
	%HappinessBar.value = dog.happiness
