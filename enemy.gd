extends CharacterBody2D

var speed = 40
	
var player_chase = false
var player = null 

func _physics_process(delta):
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
	pass # Replace with function body.
