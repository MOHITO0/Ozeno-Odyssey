extends Area2D

@onready var sound = $pickUp
@onready var animations = $AnimatedSprite2D

func _ready():
	animations.play("default")


func collect():
	queue_free()
	sound.play()
