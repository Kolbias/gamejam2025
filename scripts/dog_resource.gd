extends Resource
class_name DogResource

@export var dog_texture: CompressedTexture2D
@export var dog_name: String
@export var dog_icon: CompressedTexture2D
@export var happiness: int

# Dictionary mapping states to AtlasTexture frames
var frames: Dictionary = {}

func setup_frames():
	# Each tile is 32x32 in a 128x128 texture
	var states = ["happy", "thirst", "hungry", "alternate"]
	for row in states.size():
		var key = states[row]
		frames[key] = []
		for col in range(4):
			var tex = AtlasTexture.new()
			tex.atlas = dog_texture
			tex.region = Rect2(col * 32, row * 32, 32, 32)
			frames[key].append(tex)
