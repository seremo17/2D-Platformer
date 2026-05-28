extends CharacterBody2D

signal OnUpdateHealth (health : int)
signal OnUpdateScore (score : int)

@export var move_speed : float = 100
@export var acceleration : float = 50
@export var braking : float = 20
@export var gravity : float = 500
@export var jump_force : float = 200

@export var health : int = 3

var move_input : float 

@onready var sprite : Sprite2D = $Sprite
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var audio : AudioStreamPlayer = $AudioStreamPlayer


var hurt_sound_end := -1.0
var take_damage_sfx : AudioStream = preload("res://Audio/Hurt_sound_effect.mp3")
var coin_sfx : AudioStream = preload("res://Audio/Coin_Collect.mp3")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta 
	
	move_input = Input.get_axis("move_left", "move_right")
	
	if move_input != 0:
		velocity.x = lerp(velocity.x, move_input * move_speed, acceleration * delta)
	
	else:
		velocity.x = lerp(velocity.x, 0.0, braking * delta)
	
	
	
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -jump_force 
	
	move_and_slide()
	
func _process(delta):
	
	if Input.is_action_pressed("move_left"):
		sprite.flip_h = true
	if Input.is_action_pressed("move_right"):
		sprite.flip_h = false
	
	
	if hurt_sound_end > 0 and audio.get_playback_position() >= hurt_sound_end:
		audio.stop()
		hurt_sound_end = -1.0
	
	
	
	if global_position.y >200:
		game_over()
	
	_manage_animation()
	
	
	
func _manage_animation ():
	if not is_on_floor():
		anim.play("jump")
	elif move_input != 0:
		anim.play("move")
	else:
		anim.play("idle")
	
func take_damage(amount : int):
	health -= amount
	OnUpdateHealth.emit(health)
	_damage_flash()
	
	
	if health <= 0:
		await dead_sound_cut()
		game_over()
	else:
		take_damage_sound_cut(1.77, 2.08)
	
	
func game_over ():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
	
func increase_score (amount : int):
	PlayerStats.score += amount
	OnUpdateScore.emit(PlayerStats.score)
	play_sound(coin_sfx)


func _damage_flash ():
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	sprite.modulate = Color.WHITE

func play_sound (sound : AudioStream):
	audio.stream = sound
	audio.play()
	
	

func take_damage_sound_cut(start_time: float, end_time: float):
	audio.stream = take_damage_sfx
	audio.play(1.77)
	hurt_sound_end = 2.08



func dead_sound_cut():
	var start := 3.05
	var end := 3.95
	var duration := 0.2
	
	audio.stream = take_damage_sfx
	audio.play(3.05)
	
	await get_tree().create_timer(duration).timeout
	audio.stop()
