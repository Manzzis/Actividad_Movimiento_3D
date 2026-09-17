extends Node3D
class_name CamaraControl

@onready var Camara = $Camera3D
@export_range(0.001, 0.01) var sensibilidad: float = 0.003
@export var min_pitch: float = -85.0 # Límite para mirar hacia abajo
@export var max_pitch: float = 85.0  # Límite para mirar hacia arriba

var pitch: float = 0.0
var yaw: float = 0.0

func _ready() -> void:
	# Oculta y fija el cursor al centro de la pantalla al comenzar
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	# 1. Alternar captura/liberación del mouse con la tecla ESC
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# 2. Rotación con el movimiento del mouse (solo si el cursor está capturado)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * sensibilidad
		pitch -= event.relative.y * sensibilidad
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

		# Si la cámara es independiente o de primera persona:
		rotation.x = pitch
		
		# Opción A: Rotar horizontalmente la cámara misma (Primera persona / Libre)
		rotation.y = yaw
		
		# Opción B: Si la cámara está dentro del personaje y quieres rotar el cuerpo entero, 
		# comenta 'rotation.y = yaw' arriba y descomenta esta línea:
		# get_parent().rotation.y = yaw
