extends Node2D

onready var local = $Positions/Local
onready var remotes = $Positions/Remote
onready var town = $Positions/Town
onready var ui = $Positions/UI

func _ready():
	pass

func get_local_player_position() -> Vector2:
	return local.get_node("Player").position

func get_remote_player_position(i: int) -> Vector2:
	return remotes.get_child(i).position

func get_town_card_position(i: int) -> Vector2:
	return town.get_child(i).position

