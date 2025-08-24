extends Control

var temp 

@export var dog_display_scene : PackedScene
@export var dog_master_list: DogMasterList
@export var max_water_spawns: int = 15
@export var max_dog_spawns: int = 2
@export var water_pickup: PackedScene
@export var dog_pickup: PackedScene

@onready var dog_spawn_timer: Timer = %DogSpawnTimer
@onready var water_spawn_timer: Timer = %WaterSpawnTimer
@onready var map_background: Sprite2D = %MapBackground


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
		else:
			Globals.emit_signal("notification_sent", "Water\nFULL!")
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
			collect_new_dog(new_dog)
			print("New dog collected! " + new_dog.dog_name)
			Globals.emit_signal("new_dog_collected", "New dog collected")
			found_new_dog = true
			break  # ✅ exit after adding a new dog

	# If we tried everything and still didn’t get a new one
	if not found_new_dog:
		print("No dogs available")

	#print("dogs: " + str(d.dog_name for d in Globals.dogs))
	area.queue_free()
	current_dog_pickups -= 1

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func change_state(new_state):
	print("new state: " + str(new_state))
	state = new_state

func _on_play_button_pressed() -> void:
	change_state(GameState.MENU)

func _on_menu_button_pressed() -> void:
	print("changing State to Menu")
	change_state(GameState.MENU)

func _on_collection_button_pressed() -> void:
	change_state(GameState.DOGS)
	
func _on_map_button_pressed() -> void:
	change_state(GameState.MAP)
	if opened_map == false:
		Globals.emit_signal("notification_sent", "Click to move!")
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

func _on_back_button_pressed() -> void:
	if GameState.DOGS:
		Globals.emit_signal("prev_dog")
		
func disable_next_button():
	%ForwardButton.disabled = true
	
func disable_prev_button():
	%BackButton.disabled = true
		
func enable_next_button():
	%ForwardButton.disabled = false
	
func enable_prev_button():
	%BackButton.disabled = false
	
func _on_water_timer_timeout() -> void:
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
			
			


func _on_water_spawn_timer_timeout() -> void:
	if current_water_pickups < max_water_spawns:
		spawn_water()
		water_spawn_timer.wait_time = randf_range(5.0, 20.0)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		Globals.emit_signal("disable_warning")


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		Globals.emit_signal("send_warning")
