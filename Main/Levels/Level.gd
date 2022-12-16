extends Node2D

const PlayerScene = preload("res://Main/Scenes/Player.tscn")

var player_spawn_location = Vector2.ZERO

onready var camera: = $Camera2D
onready var player: = $Player
onready var timer = $Timer

func _ready():
	VisualServer.set_default_clear_color(Color.aqua) #bytter bakgrunns fargen til lyse blå
	player.connect_camera(camera)
	player_spawn_location = player.global_position #stores player start postion
	Events.connect("player_died", self, "_on_player_died") #object that contains signal, object with function, function  called
	Events.connect("hit_checkpoint", self, "_on_hit_checkpoint")
func _on_player_died(): #player dies and emits signal
	timer.start(1.0)
	yield(timer, "timeout")
	var player = PlayerScene.instance() #instances player
	player.position = player_spawn_location #makes new player spawn there
	add_child(player) #adds to world
	player.connect_camera(camera)
	
func _on_hit_checkpoint(checkpoint_position):
	player_spawn_location = checkpoint_position
	
