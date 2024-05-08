# TODO
# This is for testing only, will be removed from release
extends CanvasLayer

var hosting: bool = false
var joining: bool = false

@onready var container: VBoxContainer = %Container
@onready var hosting_label: Label = %Hosting
@onready var joining_label: Label = %Joining
@onready var line_edit = %LineEdit
const GAME = preload("res://Game.tscn")

# Update labels containg if client is hosting or is a peer
func _process(delta) -> void:
	hosting_label.text = "Hosting: " + str(hosting)
	joining_label.text = "Joining: " + str(joining)
	if line_edit.text != "":
		Connection.address = line_edit.text

# Start hosting
func _on_host_pressed() -> void:
	if hosting or joining:
		print("Already hosting or joined")
		return
	hosting = true
	
	Connection.updateMenu.connect(addLabel)
	Connection.putHostIp.connect(addHostIpLabel)
	
	Connection.creatHost()


# Join as a peer
func _on_join_pressed() -> void:
	if hosting or joining:
		print("Already hosting or joined")
		return
	joining = true
	
	Connection.updateMenu.connect(addLabel)
	Connection.putPeerIp.connect(connectedToHostsIp)
	
	Connection.creatPeer()


# TODO
# Start game doesn't work
func _on_start_game_pressed() -> void:
	if multiplayer.is_server() and hosting:
		print("Game start")
		Connection.setNewConnectionStatus(true)
		get_tree().get_first_node_in_group("To add").add_child(GAME.instantiate(), true)
		deletemenu.rpc()
	else:
		print("Only host can start")


# Deletes Menu
@rpc("authority", "call_local", "reliable")
func deletemenu():
	queue_free()


# Discontect
func _on_disconect_pressed() -> void:
	if multiplayer.is_server():
		Connection.stopHosting()
		Connection.setNewConnectionStatus(false)
	else:
		Connection.disconectFromServer()
	hosting = false
	joining = false
	Connection.updateMenu.disconnect(addLabel)
	Connection.putHostIp.disconnect(addHostIpLabel)
	Connection.putPeerIp.disconnect(connectedToHostsIp)
	clearLabels()


# Send label update
func _on_update_pressed() -> void:
	Connection.updateMenuFunc.rpc()


# Add label
func addLabel() -> void:
	var label: Label = Label.new()
	label.text = "Update"
	container.add_child(label)


# Adds the hosts Ip to the labels
func addHostIpLabel():
	if not multiplayer.is_server():
		return
	var label: Label = Label.new()
	label.text = "Host Ip: " + Connection.address + ":" + str(Connection.port)
	container.add_child(label)


# Adds connection informatil to the peers labels
func connectedToHostsIp():
	if multiplayer.is_server():
		return
	var label: Label = Label.new()
	if line_edit.text != "":
		label.text = "Connected to Ip: " + line_edit.text + ":" + str(Connection.port)
	else:
		label.text = "Connected to Ip: 127.0.0.1:" + str(Connection.port)
	container.add_child(label)


# Clears labels
func clearLabels() -> void:
	for label in container.get_children():
		label.queue_free()
