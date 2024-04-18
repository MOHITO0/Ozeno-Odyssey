extends CharacterBody2D

signal healthChanged

@export var speed: int = 350
@onready var animations = $AnimationPlayer
@onready var effects = $Effects

@export var maxHealth: int = 3
@onready var currentHealth: int = maxHealth
@onready var hurtTimer = $hurtTimer
@export var knockbackPower: int = 300
var isHurt: bool = false

var enemyCollisions = []

func _ready():
	effects.play("RESET")

func getInput():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed
	

func updateAnimation():
	if velocity.length() == 0:
		animations.stop()
	else: 
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
		animations.play("walk" + direction)


func handleCollision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

func _physics_process(delta):
	getInput()
	move_and_slide()
	updateAnimation()
	handleCollision()
	if !isHurt:
		for enemyArea in enemyCollisions:
			hurtByEnemy(enemyArea)

func hurtByEnemy(area):
	currentHealth -= 1
	if currentHealth < 0:
		currentHealth = maxHealth
	healthChanged.emit(currentHealth)
	isHurt = true
	
	knockback(area.get_parent().velocity)
	effects.play("effectBlink")
	hurtTimer.start()
	await hurtTimer.timeout
	effects.play("RESET")
	isHurt = false
	
func _on_hurt_box_area_entered(area):
	if area.name == 'hitBox':
		enemyCollisions.append(area)
		


func knockback(enemyVelocity: Vector2):
	var knockbackDirection = (enemyVelocity - velocity).normalized() * knockbackPower
	velocity = knockbackDirection
	move_and_slide()
	print_debug(currentHealth)


func _on_hurt_box_area_exited(area):
	enemyCollisions.erase(area)
