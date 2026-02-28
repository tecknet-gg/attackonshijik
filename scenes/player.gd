extends CharacterBody2D

@export var player_hp: float = 20.0
@export var speed: float = 300.0
@export var damage: float = 1.0


@export var bullet_scene = preload("res://scenes/bullet.tscn")
@export var mag_size: int = 25
@export var reload_time: float = 1.5
var current_ammo: int = 10
var is_reloading: bool = false

# UI 
@onready var health_label = $HealthLabel

func _ready() -> void:
	add_to_group("player") 
	update_hp_text()

func _process(_delta: float) -> void:
	look_at(get_global_mouse_position())

func _physics_process(_delta: float) -> void:
	if health_label:
		health_label.rotation = -rotation

	var move_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if move_dir != Vector2.ZERO:
		velocity = move_dir.normalized() * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed / 5.0)
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"): 
		shoot()
	if event.is_action_pressed("reload") and current_ammo < mag_size:
		start_reload()

func shoot():
	if is_reloading or current_ammo <= 0: return
	current_ammo -= 1
	var b = bullet_scene.instantiate()
	b.damage = damage 
	b.global_position = global_position
	b.global_rotation = global_rotation
	get_parent().add_child(b) 

func start_reload():
	if is_reloading: return
	is_reloading = true
	await get_tree().create_timer(reload_time).timeout
	current_ammo = mag_size
	is_reloading = false


func update_hp_text():
	if health_label:
		health_label.text = "HP: " + str(player_hp)

func take_damage(amount: float):
	player_hp -= amount
	
	update_hp_text()
	print("PLAYER HIT! Current HP: ", player_hp) 
	if player_hp <= 0:
		get_tree().reload_current_scene()
