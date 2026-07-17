extends Node3D

@onready var temp_mp_menu: PanelContainer = $"Mutliplayer temp menu/tempMPMenu"
@onready var adress_entry: LineEdit = $"Mutliplayer temp menu/tempMPMenu/VBoxContainer/AdressEntry"

#oh frick jetzt kommt die erste network scheisse
const tempPlayerScene = preload("res://scenes/player.tscn")
const PORT = 9999 #lol
var enet_peer = ENetMultiplayerPeer.new() #erstellt ein multiplayer peer element und gibt einen zeiger drauf bevor es ohne die var in den abyss verschwindet


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _on_host_pressed() -> void:
	temp_mp_menu.hide()
	
	enet_peer.create_server(PORT) # erstellt einen ENet-Server auf diesem Port.
	# Dieser Spieler wird dadurch zum Host.
	# In einem Host-Client-P2P-System ist jeder grundsätzlich ein Peer,
	# aber der Host ist der besondere Peer, der den Server betreibt
	# und normalerweise die Autorität über den Spielzustand hat.
	# Seine Peer-ID ist meistens 1.
	# ja kein echtes true decentrilaized p2p aber fick mich ich nem nur das was ez in der high level scheisse drin ist nein danke. (ander e wäre highkey eh einfach nur ein sumppf gewesen (bruh ich habe einen 90m minütigen exkurs betrieben dafür alr?)
	multiplayer.multiplayer_peer = enet_peer


func _on_join_pressed() -> void:
	pass

func add_player(peer_id):
	var player = tempPlayerScene.instantiate()
	player.name = str(peer_id)
