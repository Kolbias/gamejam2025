extends Area2D

@export var water_textures : Array[CompressedTexture2D]

func _ready() -> void:
	%Sprite.texture = water_textures.pick_random()
