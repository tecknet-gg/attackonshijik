extends CharacterBody2D

@export var enemy_hp: float = 10.0
@export var agro_range: float = 200.0
@export var speed: float = 150.0 
@export var stopping_distance: float = 65.0 
@onready var health_label = $HealthLabel 
@export var attack_damage: float = 1.0 

var target_position: Vector2
var is_chasing: bool = false
var alarm_0: float = 0.5
var damage_timer: float = 0.0 

func _ready() -> void:
	target_position = global_position
	update_hp_text()

func _physics_process(delta: float) -> void:
	if health_label:
		health_label.global_position = global_position + Vector2(-20, -50)
		health_label.rotation = 0 

	if alarm_0 > 0:
		alarm_0 -= delta
		if alarm_0 <= 0:
			_update_logic()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist_to_player = global_position.distance_to(player.global_position)
		
		if dist_to_player <= agro_range:
			is_chasing = true
			target_position = player.global_position
			
			if dist_to_player <= stopping_distance + 10.0:
				damage_timer += delta
				if damage_timer >= 1.0:
					if player.has_method("take_damage"):
						player.take_damage(attack_damage)
					damage_timer = 0.0
			else:
				damage_timer = 0.0 
		else:
			is_chasing = false

	var dist_to_target = global_position.distance_to(target_position)
	var limit = stopping_distance if is_chasing else 10.0
	
	if dist_to_target > limit:
		var move_dir = global_position.direction_to(target_position)
		velocity = velocity.move_toward(move_dir * speed, speed * 8.0 * delta)
		if dist_to_target > limit + 5:
			look_at(target_position)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 8.0 * delta)
	
	move_and_slide()

func _update_logic() -> void:
	if not is_chasing:
		if global_position.distance_to(target_position) < 20:
			var wander_range = 150.0
			target_position = global_position + Vector2(
				randf_range(-wander_range, wander_range),
				randf_range(-wander_range, wander_range)
			)
		alarm_0 = randf_range(1.0, 2.5)
	else:
		alarm_0 = 0.2

func update_hp_text():
	if health_label:
		health_label.text = str(enemy_hp)

func handle_hit(damage: float) -> void:
	enemy_hp -= damage
	update_hp_text()
	if enemy_hp <= 0:
		queue_free()
