extends RichTextLabel

func _ready() -> void:
	Globals.connect("new_dog_collected", notify)
	Globals.connect("notification_sent", notify)

func notify(phrase:String):
	var tween = get_tree().create_tween()
	self.text = "[wave][center]\n\n" + phrase
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.5)
	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5)
