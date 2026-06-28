extends CharacterBody3D

@export var speed = 2.0
@onready var nav_agent = $NavigationAgent3D
@onready var player = $"../Player" # Adjust path to your player node

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	self.look_at(player.position)
	self.rotation.x = 0
	
	if can_see_player():
		nav_agent.target_position = player.global_position
		move_towards_target(delta)
		move_and_slide()
	
func can_see_player() -> bool:
	return global_position.distance_to(player.global_position) < 100.0 # Detection range

func move_towards_target(delta):
	
	if nav_agent.is_target_reachable():
		var next_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_pos)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
