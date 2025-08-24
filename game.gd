extends Control

var temp 

@export var dog_display_scene : PackedScene
@export var dog_master_list: DogMasterList
@export var max_water_spawns: int = 15
@export var max_dog_spawns: int = 2
@export var water_pickup: PackedScene
@export var dog_pickup: PackedScene
@export var bark_sounds: Array[AudioStreamOggVorbis]

@onready var dog_spawn_timer: Timer = %DogSpawnTimer
@onready var water_spawn_timer: Timer = %WaterSpawnTimer
@onready var map_background: Sprite2D = %MapBackground
@onready var water_sfx: AudioStreamPlayer = %WaterSFX
@onready var bark_sfx: AudioStreamPlayer = $BarkSFX


enum GameState {TITLE, DOGS, MENU, MAP}

var state := GameState.TITLE
var mouse_on_map := false
var spawn_area
var current_water_pickups = 0
var current_dog_pickups = 0

var opened_map = false
var dog_menu_opened = false


func _ready() -> void:
	Globals.available_dogs = dog_master_list.dog_master_list
	Globals.connect("change_state", change_state)
	Globals.connect("disable_next", disable_next_button)
	Globals.connect("disable_prev", disable_prev_button)
	Globals.connect("remove_remaining_dogs", remove_remaining_dogs)
	%SFXButton.button_pressed = true
	%MusicButton.button_pressed = true
	spawn_area = map_background.get_rect().size
	print("Spawn Area :" + str(spawn_area))
	for i in max_water_spawns:
		spawn_water()
	for i in max_dog_spawns:
		spawn_dog()
		

func _process(delta: float) -> void:
	%WaterBar.value = Globals.water
	%TempGauge.value = 0
	var dogs_temp = 0
	var temp_max = 0
	for i in Globals.dogs:
		temp_max += 100
		dogs_temp += 100 - i.happiness
		%TempGauge.max_value = temp_max
		%TempGauge.value = dogs_temp
		if dogs_temp >= temp_max:
			dogs_temp = temp_max
		if dogs_temp <= 25 and Globals.all_dogs_collected:
			%WinScreen.show()
			#await get_tree().create_timer(2.0)
			#get_tree().paused = true
	
	match state:
		GameState.TITLE:
			%Title.show()
			
		GameState.DOGS:
			%Menu.hide()
			%Map.hide()
			%DogCollection.show()

		GameState.MAP:
			%Menu.hide()
			%DogCollection.hide()
			%Map.show()
			
		GameState.MENU:
			%Title.hide()
			%DogCollection.hide()
			%Map.hide()
			%Menu.show()
			
	if mouse_on_map:
		var mouse_pos = get_global_mouse_position()
		#var tween = get_tree().create_tween()
		if Input.is_action_just_pressed("left_click"):
			print("mouse pos on click: " + str(mouse_pos))
			var dir = (get_viewport().get_mouse_position() - get_viewport_rect().size / 2).normalized()
			var speed = 15.0
			var target = %MapBackground.position - dir * speed
			print(target)
			print("map pos" + str(%MapBackground.position))
			var tween = get_tree().create_tween()
			tween.tween_property(%MapBackground, "position", target, 0.5)
			
			
func collect_new_dog(dog: DogResource):
	Globals.dogs.append(dog)

	var instance = dog_display_scene.instantiate()
	dog.setup_frames()
	%TabContainer.add_child(instance)
	instance.set_display(dog)
	
func spawn_water():
	var instance = water_pickup.instantiate()
	var rand_pos_x = randf_range(-115.0, 115.0)
	var rand_pos_y = randf_range(-115.0, 115.0)
	map_background.add_child(instance)
	instance.position.x = rand_pos_x
	instance.position.y = rand_pos_y
	current_water_pickups += 1
	print("Current Water Pickups: " + str(current_water_pickups))

func spawn_dog():
	var instance = dog_pickup.instantiate()
	var rand_pos_x = randf_range(-115.0, 115.0)
	var rand_pos_y = randf_range(-115.0, 115.0)
	map_background.add_child(instance)
	instance.position.x = rand_pos_x
	instance.position.y = rand_pos_y
	current_dog_pickups += 1
	print("Current Dogs Pickups: " + str(current_water_pickups))

func _on_player_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("water"):
		if !Globals.water > 90:
			Globals.water += 20
			Globals.emit_signal("notification_sent", "Water gained!")
			area.queue_free()
			current_water_pickups -= 1
			water_sfx.pitch_scale = randf_range(0.95,1.2)
			water_sfx.play()
		else:
			Globals.emit_signal("notification_sent", "Water\nFULL!")
		return
		
	if not area.is_in_group("dog"):
		return

	var new_dog: DogResource
	var found_new_dog := false

	while true:
		new_dog = area.get_dog_from_map()

		# Stop if there are no more dogs available in the map
		if new_dog == null:
			break

		# Check if this dog is already collected
		var duplicate := false
		for d in Globals.dogs:
			if d.dog_name == new_dog.dog_name:
				duplicate = true
				break

		if not duplicate:
			#if Globals.dogs.is_empty():
				##Globals.emit_signal("hide_dog")
				#Globals.emit_signal("notification_sent", "Use menu\nto see\ndogs!")
				#await get_tree().create_timer(2.0).timeout
				#Globals.emit_signal("notification_sent", "Give\ndogs water!")
			Globals.emit_signal("new_dog_collected", "New dog collected")
			collect_new_dog(new_dog)
			print("New dog collected! " + new_dog.dog_name)
			found_new_dog = true
			break 

	# If we tried everything and still didn’t get a new one
	if not found_new_dog:
		print("No dogs available")

	#print("dogs: " + str(d.dog_name for d in Globals.dogs))
	area.queue_free()
	bark_sfx.stream = bark_sounds.pick_random()
	bark_sfx.play()
	current_dog_pickups -= 1

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func change_state(new_state):
	print("new state: " + str(new_state))
	state = new_state

func _on_play_button_pressed() -> void:
	change_state(GameState.MENU)
	%MusicPlayer.play()

func _on_menu_button_pressed() -> void:
	print("changing State to Menu")
	change_state(GameState.MENU)
	play_ui_sound()

func _on_collection_button_pressed() -> void:
	change_state(GameState.DOGS)
	play_ui_sound()
	if Globals.dogs.is_empty() and !dog_menu_opened:
		Globals.emit_signal("notification_sent", "Use Map\nto find dogs!")
		dog_menu_opened = true
	
func _on_map_button_pressed() -> void:
	change_state(GameState.MAP)
	play_ui_sound()
	if opened_map == false:
		Globals.emit_signal("notification_sent", "Click to move!")
		await get_tree().create_timer(2.0).timeout
		Globals.emit_signal("notification_sent", "Look for\ndogs!")
		opened_map = true

func _on_control_mouse_entered() -> void:
	print("mouse on map")
	mouse_on_map = true

func _on_control_mouse_exited() -> void:
	print("mouse left map")
	mouse_on_map = false

func _on_forward_button_pressed() -> void:
	if GameState.DOGS:
		Globals.emit_signal("next_dog")
		play_ui_sound()

func _on_back_button_pressed() -> void:
	if GameState.DOGS:
		Globals.emit_signal("prev_dog")
		play_ui_sound()
		
func disable_next_button():
	%ForwardButton.disabled = true
	
func disable_prev_button():
	%BackButton.disabled = true
		
func enable_next_button():
	%ForwardButton.disabled = false
	
func enable_prev_button():
	%BackButton.disabled = false
	
func _on_water_timer_timeout() -> void:
	if Globals.all_dogs_collected == true:
		Globals.water += 5
	else:
		Globals.water += 1
	if Globals.water >= 100:
		Globals.water = 100
	


func _on_dog_spawn_timer_timeout() -> void:
	if current_dog_pickups < max_dog_spawns:
		if !Globals.available_dogs.is_empty():
			spawn_dog()
			dog_spawn_timer.wait_time = randf_range(20.0, 50.0)
		else:
			dog_spawn_timer.stop()
			Globals.emit_signal("notification_sent", "You got all Dogs!")
			Globals.all_dogs_collected = true
			#Globals.emit_signal("remove_remaining_dogs")
			
			


func _on_water_spawn_timer_timeout() -> void:
	if current_water_pickups < max_water_spawns:
		spawn_water()
		if Globals.all_dogs_collected:
			water_spawn_timer.wait_time = randf_range(1, 0.5)
		else:
			water_spawn_timer.wait_time = randf_range(5.0, 12.0)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		Globals.emit_signal("disable_warning")


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		Globals.emit_signal("send_warning")

func play_ui_sound():
	#%UISounds.pitch_scale = randf_range(0.9,1.05)
	%UISounds.play()


func _on_sfx_button_toggled(toggled_on: bool) -> void:
	var sfx_index = AudioServer.get_bus_index("SFX")
	print("SFX toggled = " + str(toggled_on))
	if toggled_on == false:
		AudioServer.set_bus_mute(sfx_index, true)
	else:
		AudioServer.set_bus_mute(sfx_index, false)

func _on_music_button_toggled(toggled_on: bool) -> void:
	var music_index = AudioServer.get_bus_index("Music")
	print("Music toggled = " + str(toggled_on))
	if !toggled_on:
		AudioServer.set_bus_mute(music_index, true)
	else:
		AudioServer.set_bus_mute(music_index, false)

func remove_remaining_dogs():
	for i in %MapBackground.get_children():
		if i.is_in_group("dog_pickup"):
			i.queue_free()
