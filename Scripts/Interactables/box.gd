extends Node

var target: Node3D
var being_held := false

var stiffness := 100.0
var damping := 8.0

@onready var box: RigidBody3D = $".."
@onready var box_collision: CollisionShape3D = $"../CollisionShape3D"

func _ready():
	var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
	if player:
		target = player.get_node("Neck/Hold Point")
		target.pick_up.connect(_on_pickup)
		target.drop_item.connect(_on_drop_item)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("interact") and being_held:
			being_held = false

func _on_pickup():
	being_held = true
	box.gravity_scale = 0
	
	box.set_collision_layer_value(1, false)
	box.set_collision_layer_value(3, true)
	
func _on_drop_item():
	being_held = false
	box.gravity_scale = 1.0
	
	box.set_collision_layer_value(1, true)
	box.set_collision_layer_value(3, false)
	
	
func _physics_process(delta):
	if being_held:
		# Position match
		var pos_error = target.global_position - box.global_position
		var vel_error = -box.linear_velocity
		
		var force = pos_error * stiffness + vel_error * damping
		box.apply_central_force(force)

		# Rotation match
		var parent_rot = target.global_rotation
		var box_rot = box.global_rotation

		var target_yaw = parent_rot.y
		var target_pitch = 0.0
		var target_roll = 0.0

		var new_pitch = lerp_angle(box_rot.x, target_pitch, 50.0 * delta)
		var new_yaw = lerp_angle(box_rot.y, target_yaw, 50.0 * delta)
		var new_roll = lerp_angle(box_rot.z, target_roll, 50.0 * delta)

		box.global_rotation = Vector3(new_pitch, new_yaw, new_roll)
