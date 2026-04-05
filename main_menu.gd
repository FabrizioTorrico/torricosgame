# main_menu.gd
extends Control

const PORT := 9999

@onready var ip_input = $VBoxContainer/IpInput # Tu LineEdit
@onready var host_btn = $VBoxContainer/HostBtn
@onready var join_btn = $VBoxContainer/JoinBtn

func _ready():
	host_btn.pressed.connect(_on_host_pressed)
	join_btn.pressed.connect(_on_join_pressed)

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 2) # Máximo 2 jugadores
	multiplayer.multiplayer_peer = peer
	
	# El creador siempre será el Jugador 1
	NetworkManager.local_player_id = 1 
	print("Hosteando en puerto ", PORT)
	
	# Esperamos a que alguien se conecte
	multiplayer.peer_connected.connect(_on_player_connected)

func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	var ip = ip_input.text if ip_input.text != "" else "127.0.0.1"
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	
	# El que se une siempre será el Jugador 2
	NetworkManager.local_player_id = 2
	print("Intentando conectar a ", ip)
	
	multiplayer.connected_to_server.connect(_start_game)

func _on_player_connected(_id):
	# El Host detecta que alguien entró, ¡arranca el juego!
	_start_game()

func _start_game():
	get_tree().change_scene_to_file("res://Game.tscn")
