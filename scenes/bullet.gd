extends Area2D

@export var bullet_speed: float = 100.0  
var damage: float = 1.0

func _physics_process(delta: float) -> void:
	position += transform.x * bullet_speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("handle_hit"):
		body.handle_hit(damage) 
	
	if not body.is_in_group("player"):
		queue_free()
