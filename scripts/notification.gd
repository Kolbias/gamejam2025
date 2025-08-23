extends RichTextLabel



func notify(phrase:String):
	var tween = get_tree().create_tween()
	self.text = "[wave][center]\n\n" + phrase
	
