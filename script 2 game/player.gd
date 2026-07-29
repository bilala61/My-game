extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true 
var health = 100
var player_alive = true 


const speed = 100
var current_dir = "none"

func _ready():
	$AnimatedSprite2D.play("Front Idle") 



func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	
	if health <= 0:
		player_alive = false #go back to menu 
		health = 0 
		print ("player has been killed")
		self.queue_free()

func player_movement(delta):
	pass
	if Input.is_action_pressed("right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed 
		velocity.y = 0
	elif Input.is_action_pressed("left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed 
		velocity.y = 0
	elif Input.is_action_pressed("down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = speed 
		velocity.x = 0
	elif Input.is_action_pressed("up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -speed 
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0 
		velocity.y = 0 
	
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	 
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("Side walk")
		elif movement == 0:
			anim.play("Side Idle")
	
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("Side walk")
		elif movement == 0:
			anim.play("Side Idle")
	
	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("Front walk")
		elif movement == 0:
			anim.play("Front Idle")
			
	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("Back walk")
		elif movement == 0:
			anim.play("Back Idle")

func player():
	pass 


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	print("Something entered: ", body.name) #
	if body.has_method("enemy"):
	#if body.is_in_group("enemy"):
		enemy_inattack_range = true 


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false


func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health - 20
		enemy_attack_cooldown = false
		$"attack cooldown".start()
		print(health)





func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
