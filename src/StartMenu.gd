extends Node

onready var hostname_node = $Content/List/JoinLobbyContainer/Hostname
onready var joinlobby_node = $Content/List/JoinLobbyContainer/JoinLobby
onready var startlobby_node = $Content/List/StartLobby
onready var playername_node = $Content/List/PlayerName

var current_scene

func _ready():
	pass

func open_client(is_server):
	var client = Global.Client.instance()
	client.init(is_server, playername_node.text, hostname_node.text)
	open_child(client)

func open_options():
	var options = Global.OptionsMenu.instance()
	open_child(options)

func open_child(scene):
	current_scene = scene
	add_child(current_scene)
	$Content.visible = false

func close_child():
	$Content.visible = true
	current_scene.queue_free()

func _on_StartLobby_pressed():
	if is_settings_valid():
		open_client(true)

func _on_JoinLobby_pressed():
	if is_settings_valid():
		open_client(false)

func is_settings_valid():
	return len(playername_node.text) > 0

func _on_PlayerName_text_changed(_new_text):
	var valid = is_settings_valid()
	joinlobby_node.disabled = !valid
	startlobby_node.disabled = !valid

func _on_Options_pressed():
	open_options()
