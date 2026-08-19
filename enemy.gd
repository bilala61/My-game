extends CharacterBody2D

var speed = 40
var player_chase = false
var player = null 
var health = 100
var player_inattack_zone = false
var can_take_damage = true


func _physics_process(delta):
	deal_with_damage()
	
	if player_chase and player:
		# 1. Calculate the direction vector towards the player
		var direction = (player.position - position).normalized()
		
		# 2. Set the velocity (adjust 'speed' multiplier as needed)
		velocity = direction * speed 
		
		# 3. Move using physics (this makes it collide with trees/walls!)
		move_and_slide()
		
		$AnimatedSprite2D.play("walk")
		
		if(player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
		
		# Stop movement when not chasing
		velocity = Vector2.ZERO
		move_and_slide()
		
		$AnimatedSprite2D.play("idle")


	
func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null 
	player_chase = false
	

func enemy():
	pass


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		health = health - 20
		print ("slime health = ", health)
		if health <= 0:
			self.queue_free()

 


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
