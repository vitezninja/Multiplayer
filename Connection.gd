extends Node

var address: String = "127.0.0.1"

var port: int = 8000
var peer: ENetMultiplayerPeer

# Contains peer Id (int) as key and player Id as value (int).
var peers: Dictionary = {}

# TODO
# This is for testing only will be removed from release
signal updateMenu
signal putHostIp
signal putPeerIp


# Sets up signal connections.
func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


# Called on host and peers on new peer connecting. Adds the new peer to the servers list of peers.
func peer_connected(id: int) -> void:
	if multiplayer.is_server():
		peers[id] = peers.size()
	
	print("Player connected: " + str(id))


# Called on host and peers on peer disconnecting. Removes the peer from the servers list of peers.
func peer_disconnected(id: int) -> void:
	if multiplayer.get_unique_id() == id:
		peer = null
		multiplayer.multiplayer_peer = null
	
	print("Player disconnected: " + str(id))


# Called only on the peer that connected.
func connected_to_server() -> void:
	print("Connected to server")


# Called only on the peer who failed to connect.
func connection_failed() -> void:
	print("Connection failed")


# Creates the host.
func creatHost() -> void:
	if peer != null:
		print("Already host")
		return
	
	peer = ENetMultiplayerPeer.new()
	
	var error: Error = peer.create_server(port, 4)
	
	if error != OK:
		printerr("Server can't host: ", error)
		return
	
	multiplayer.multiplayer_peer = peer
	putHostIp.emit()


# Creates the peer.
func creatPeer() -> void:
	if peer != null:
		print("Already peer")
		return
	
	peer = ENetMultiplayerPeer.new()
	
	var error: Error = peer.create_client(address, port)
	
	if error != OK:
		printerr("Peer can't join: ", error)
		return
		
	multiplayer.multiplayer_peer = peer
	putPeerIp.emit()


# Host deletes a peer, and disconects them.
@rpc("any_peer", "call_local", "reliable", 0)
func deletePeer(id: int = 0) -> void:
	if not multiplayer.is_server():
		return
	
	if id == 0:
		id = multiplayer.get_remote_sender_id()
	
	if id == 1:
		return
	
	multiplayer.disconnect_peer(id)
	peers.erase(id)


# Disconects the caller from server
func disconectFromServer() -> void:
	deletePeer.rpc_id(1)
	peer = null
	port = 8000
	multiplayer.multiplayer_peer = peer


# Disconects the host
func stopHosting() -> void:
	if peer == null or not multiplayer.is_server():
		return
	
	for key in peers:
		deletePeer(key)
		
	peers.clear()
	peer = null
	port = 8000
	multiplayer.multiplayer_peer = peer


# Change the status if peers can connect to the server to value.
func setNewConnectionStatus(value: bool) -> void:
	if not multiplayer.is_server():
		return
	
	multiplayer.multiplayer_peer.set_refuse_new_connections(value)


# TODO
# This is for testing only, will be removed from release
@rpc("any_peer", "call_local", "reliable", 1)
func updateMenuFunc() -> void:
	updateMenu.emit()
