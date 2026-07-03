extends Node2D

@onready var h_box_container: HBoxContainer = $"2nd Screen/HBoxContainer"
@onready var singleplayer_button: Button = $VBoxContainer/Singleplayer
@onready var multiplayer_button: Button = $VBoxContainer/Multiplayer

@onready var enet_tab: VBoxContainer = $"2nd Screen/EnetTab"
@onready var ip_field: LineEdit = $"2nd Screen/EnetTab/IP"

@onready var steam_tab: VBoxContainer = $"2nd Screen/SteamTab"
@onready var steam_lobby_list: VBoxContainer = $"2nd Screen/SteamTab/steam_lobby_list"


func _ready() -> void:
	# Reagiert, sobald eine Steam-Lobbyliste vom Netzwerk-Autoload zurückkommt
	Network.lobbies_fetched.connect(_on_lobbies_fetched)


func _on_multiplayer_button_pressed() -> void:
	h_box_container.show()
	multiplayer_button.hide()


func _on_singleplayer_button_pressed() -> void:
	singleplayer_button.hide()
	# TODO: Hier Singleplayer-Szene laden, z.B.:
	# get_tree().change_scene_to_file("res://scenes/singleplayer.tscn")


func _on_enet_pressed() -> void:
	Network.set_network_type(NetworkEnet)
	h_box_container.hide()
	enet_tab.show()


func _on_steam_pressed() -> void:
	if not SteamInfo.steam_api:
				print("Steam not available (not enabled or Steam client is not running). Skipping Steam mode.")
				print("Steam nicht verfügbar (nicht aktiviert oder Steam-Client läuft nicht). Überspringe Steam-Modus.")
				return

	Network.set_network_type(NetworkSteam)
	h_box_container.hide()
	steam_tab.show()
	_refresh_steam_lobbies()


func _on_back_pressed() -> void:
	enet_tab.hide()
	steam_tab.hide()
	h_box_container.show()
	Network.disconnect_from_server()


#region ENet
func _on_enet_ip_submitted(new_text: String) -> void:
	_join_enet(new_text)


func _on_enet_join_pressed() -> void:
	_join_enet(ip_field.text)


func _join_enet(ip: String) -> void:
	if ip.is_empty():
		ip = "localhost"
	Network.active_network.join_as_client(ip)


func _on_enet_host_pressed() -> void:
	Network.active_network.become_host()
#endregion


#region Steam
func _on_steam_host_pressed() -> void:
	Network.active_network.become_host()


func _on_steam_refresh_pressed() -> void:
	_refresh_steam_lobbies()


func _refresh_steam_lobbies() -> void:
	for child in steam_lobby_list.get_children():
		child.queue_free()
	Network.active_network.list_lobbies()


func _on_lobbies_fetched(lobbies: Array) -> void:
	for child in steam_lobby_list.get_children():
		child.queue_free()

	if lobbies.is_empty():
				var empty_label := Label.new()
				empty_label.text = "Keine Lobbys gefunden."
				empty_label.text = "No lobbies found."
				steam_lobby_list.add_child(empty_label)
				return

	for lobby_id in lobbies:
		var lobby_name: String = SteamInfo.steam_api.getLobbyData(lobby_id, "name")
		var member_count: int = SteamInfo.steam_api.getNumLobbyMembers(lobby_id)

		var button := Button.new()
		button.text = "%s (%d Spieler)" % [lobby_name, member_count]
		button.pressed.connect(_on_lobby_button_pressed.bind(lobby_id))
		steam_lobby_list.add_child(button)


func _on_lobby_button_pressed(lobby_id: int) -> void:
	Network.active_network.join_as_client(lobby_id)
#endregion
