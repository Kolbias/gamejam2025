extends RichTextLabel

func _ready() -> void:
	Globals.connect("new_dog_collected", notify)
	Globals.connect("notification_sent", notify)
	Globals.connect("send_warning", display_warning)
	Globals.connect("disable_warning", disable_warning)
	
func notify(phrase:String):
	var tween = get_tree().create_tween()
	self.text = "[wave][center]\n\n" + phrase
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.5)
	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5)

func display_warning():
	
	if !is_inside_tree() or get_tree().is_paused(): #this code prevents a weird crash on closing the game window
		return
	var tween = get_tree().create_tween()
	self.text = "[wave][center]\n\n Turn Back!" 
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.5)
	
func disable_warning():
	if !is_inside_tree() or get_tree().is_paused():
		return
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5)
