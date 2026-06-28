extends CharacterBody3D

const HOOK_AVAILIBLE_TEXTURE = preload("res://grappling_hook_3d/example/hook_availible.png")
const HOOK_NOT_AVAILIBLE_TEXTURE = preload("res://grappling_hook_3d/example/hook_not_availible.png")

@onready var camera := $Camera
@onready var hook_raycast: RayCast3D = $"Camera/Hook Raycast"
@onready var gun_raycast: RayCast3D = $"Camera/Gun Raycast"
@onready var crosshair: TextureRect = $HUD/Crosshair

@export var movement_speed := 2.0
@export var friction_ground := 0.8
@export var friction_air := 0.85
@export var jump_force := 10.0
@export var gravity := 0.8
@export var mouse_sensetivity := 1.0

@onready var hook_controller: HookController = $HookController

var kills = 0

func _physics_process(delta: float) -> void:
	$HUD/Label.text = "Jollies annihilated: " + str(kills)

	# Horizontal movement
	var movement_direction: Vector2 = Input.get_vector("Left", "Right", "Backward", "Forward")
	var movement_vector: Vector3 = (transform.basis * Vector3(movement_direction.x, 0, -movement_direction.y)).normalized()

	velocity += movement_vector * movement_speed * delta * 60

	if is_on_floor():
		velocity *= Vector3(friction_ground, 1, friction_ground)
	else:
		velocity *= Vector3(friction_air, 1, friction_air)

	# Gravity & Jumping
	if not is_on_floor():
		velocity.y -= gravity
	elif Input.is_action_pressed("ui_accept"):
		velocity.y = jump_force

	if Input.is_action_just_pressed("Lmb"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		var bullet = preload("res://Player/bullet.tscn").instantiate()
		bullet.position = gun_raycast.position
		bullet.rotation = camera.rotation
		add_child(bullet)

		# Fixed: use the Gun Raycast collider and check for null
		if gun_raycast.is_colliding():
			var body = gun_raycast.get_collider()

			if body != null and body.name in ["Jolly", "Jolly2", "Jolly3", "Jolly4", "Jolly5"]:
				kills += 1

				var respawn = randi_range(1, 5)

				match respawn:
					1:
						body.position = Vector3(0, 0.47, -5.16)
					2:
						body.position = Vector3(12.3, 2.309, 15.34)
					3:
						body.position = Vector3(-26.2, 3.855, -23.9)
					4:
						body.position = Vector3(52.60, 3.997, 11.95)
					5:
						body.position = Vector3(22.19, 6.216, 43.94)

	elif Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	move_and_slide()

	# UI
	crosshair.texture = HOOK_AVAILIBLE_TEXTURE if hook_raycast.is_colliding() and not hook_controller.is_hook_launched else HOOK_NOT_AVAILIBLE_TEXTURE


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * 0.06 * mouse_sensetivity

		camera.rotation_degrees.x -= event.relative.y * 0.06 * mouse_sensetivity
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
