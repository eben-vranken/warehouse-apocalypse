extends Node3D

var holding_item: bool = false
@onready var interact_zone: Area3D = $"Interact Zone"

signal pick_up()
signal drop_item()
@onready var hold_point: Node3D = $"."
var is_holding: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("interact") and not is_holding:
			var overlapping_areas: Array[Area3D] = interact_zone.get_overlapping_areas()
			
			for area in overlapping_areas:
				if area.is_in_group("box"):
					holding_item = true
					pick_up.emit()
					is_holding = true
					
		elif Input.is_action_just_pressed("interact") and is_holding:
			var overlapping_areas: Array[Area3D] = interact_zone.get_overlapping_areas()
			
			for area in overlapping_areas:
				if area.is_in_group("box"):
					holding_item = true
					drop_item.emit()
					is_holding = false
