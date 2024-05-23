extends CharacterBody2D

@export var speed = 20
@export var limit = 0.5
@export var endPoint: Marker2D

@onready var animations = $AnimationPlayer

var startPosition
var endPosition
var isDead: bool = false
func _ready():
	startPosition = position
	endPosition = endPoint.global_position

func updateVelocity():
	var moveDirection = (endPosition - position)
	if moveDirection.length() < limit:
		changeDirection()
	velocity = moveDirection.normalized() * speed

func changeDirection():
	var tempEnd = endPosition
	endPosition = startPosition
	startPosition = tempEnd

func updateAnimation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"

		animations.play("walk" + direction)


func _physics_process(delta):
	if isDead: return
	updateVelocity()
	move_and_slide()
	updateAnimation()


func _on_hurt_box_area_entered(area):
	if area == $hitBox: return
	$hitBox.set_deferred("monitorable", false)
	isDead = true
	animations.play("death")
	await animations.animation_finished
	queue_free()
