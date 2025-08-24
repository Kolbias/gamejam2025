extends Control
class_name DogDisplay

@export var dog : DogResource

@onready var happiness_bar: ProgressBar = %HappinessBar
@onready var water_button: Button = %WaterButton
@onready var water_bowl: TextureProgressBar = %WaterBowl



func _ready() -> void:
	%HappinessTimer.wait_time = randf_range(1.0, 2.5)
	
	%Dog.position += Vector2(16,16)
	
func _process(delta: float) -> void:
	if dog:
		happiness_bar.value = dog.happiness
		water_bowl.value = dog.happiness
		if dog.happiness > 25:
			%SweatParticles.emitting = false
		if dog.happiness < 50:
			%Dog.texture = dog.frames["thirst"][0]
			
func set_display(new_dog : DogResource) -> void:
	dog = new_dog
	dog.setup_frames()
	dog.happiness = randi_range(20,50)
	if dog.happiness < 50:
		%Dog.texture = dog.frames["thirst"][0]
	if dog.happiness > 50 and dog.happiness < 100:
		%Dog.texture = dog.frames["happy"][1]
	#if dog.happiness > 50 and dog.happiness < 75:
		#%Dog.texture = dog.frames["happy"][2]
	#if dog.happiness > 75 and dog.happiness < 100:
		#%Dog.texture = dog.frames["happy"][3]
	%HappinessBar.value = dog.happiness


func _on_happiness_timer_timeout() -> void:
	%HappinessTimer.wait_time = randf_range(5.0, 12.5)
	dog.happiness -= 2
	if dog.happiness < 10:
		dog.happiness = 10
	if dog.happiness < 25:
		%SweatParticles.emitting = true
		


func _on_water_button_pressed() -> void:
	if Globals.water >= 25:
		Globals.water -= 25
		dog.happiness +=10


func _on_anim_timer_timeout() -> void:
	if dog.happiness > 50:
		if %Dog.texture == dog.frames["happy"][0]:
			%Dog.texture = dog.frames["happy"][1]
		else:
			%Dog.texture = dog.frames["happy"][0]
