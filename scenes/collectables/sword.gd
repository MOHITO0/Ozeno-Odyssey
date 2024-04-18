extends "res://scenes/collectables/collectable.gd"

@onready var animations = $AnimationPlayer

func collect():
	animations.play("spin")
	await  animations.animation_finished
	super.collect()
