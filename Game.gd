extends Node2D

const PLAYER = preload("res://player.tscn")

func _ready():
	var p1 = PLAYER.instantiate()
	p1.position = Vector2(-300,0)
	p1.name = "p1"
	add_child(p1, true)
	print_tree_pretty()
