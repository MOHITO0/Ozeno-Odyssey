extends CharacterBody2D

signal healthChanged
@onready var weapon = $Weapon
@export var speed: int = 350
@onready var animations = $AnimationPlayer
@onready var effects = $Effects
@onready var hurtBox = $hurtBox
@export var maxHealth: int = 3
@onready var currentHealth: int = maxHealth
@onready var hurtTimer = $hurtTimer
@export var knockbackPower: int = 300

@export var inventory: Inventory

var isHurt: bool = false
var lastAnimDirection: String = "Down"
var isAttacking: bool = false



func _ready():
	effects.play("RESET")

func getInput():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed
	
	if Input.is_action_just_pressed("attack"):
		attack()
	
func attack():
	animations.play("attack"+lastAnimDirection)
	isAttacking = true
	weapon.visible = true
	await animations.animation_finished
	weapon.visible = false
	isAttacking = false

func updateAnimation():
	if isAttacking: 
		return
	if velocity.length() == 0:
		animations.stop()
	else: 
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
		animations.play("walk" + direction)
		lastAnimDirection = direction


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
		for area in hurtBox.get_overlapping_areas():
			if area.name == "hitBox":
				hurtByEnemy(area)

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
	if area.has_method("collect"):
		area.collect(inventory)
		


func knockback(enemyVelocity: Vector2):
	var knockbackDirection = (enemyVelocity - velocity).normalized() * knockbackPower
	velocity = knockbackDirection
	move_and_slide()
	print_debug(currentHealth)


func _on_hurt_box_area_exited(area):
	pass
