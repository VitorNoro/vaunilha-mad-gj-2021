extends Node2D

# pickable objects will be able to set a dialogue
# line when they are picked up.

class_name PickableObj

export var pickable_obj_resource : Resource

onready var main_node = get_node("../../../../../") # p: Objects, p: YScroll, p: Level0, p: Levels, p: Main
onready var player_node = main_node.get_node("Player")
onready var dialogue_node = get_tree().root.get_node("Control/CanvasLayer/Dialogue")
onready var pickup_sound : AudioStream

var sprite_node

var dialogue : Dialogue
var res : PickableObjData
var sentences : PoolStringArray

signal set_dialogue(text)
signal pickup(obj_name, resource)

var brick_me = false

func _ready():
	if brick_me:
		return
	
	res = pickable_obj_resource
	
	var snd_file=File.new()
	snd_file.open("res://Sounds/pickup.wav", File.READ)
	pickup_sound = AudioStreamSample.new()
	pickup_sound.format = AudioStreamSample.FORMAT_16_BITS
	pickup_sound.stereo = true
	pickup_sound.data = snd_file.get_buffer(snd_file.get_len())
	snd_file.close()
	
	sentences.push_back(res.dialogue_line)
	dialogue = Dialogue.new(sentences)
	
	sprite_node = $Sprite
	
	# set up this obj texture
	sprite_node.texture = res.texture
	sprite_node.position = Vector2(res.texture.get_width() / 2 * -1, res.texture.get_height() * -1)
	
	connect("pickup", GameState, "_on_item_pickup")

func _process(delta):
	if brick_me:
		return
	
	# pickup / dialogue triggers
	if Input.is_action_just_pressed("player_interact"):
		
		var trigger_area : Area2D  = player_node.get_node("TriggerArea")
		
		if trigger_area.overlaps_area($TriggerArea) and !player_node.is_holding_item:
			if !res.dialogue_line.empty():
				dialogue_node.emit_signal("dialogue_interact", dialogue, pickup_sound)
			emit_signal("pickup", res)
			player_node.is_holding_item = true
			queue_free()
			

