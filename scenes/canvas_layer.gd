extends CanvasLayer

@onready var texto_ganaste = $ganaste
@onready var label_puntos: Label = $Label # Ajusta el nombre si tu nodo se llama distinto
var puntos : int = 0


func _ready() -> void:
	actualizar_texto()
	texto_ganaste.hide()

func _process(delta: float) -> void:
	if puntos >= 3:
		texto_ganaste.show()

func sumar_punto(cantidad: int = 1) -> void:
	puntos += cantidad
	actualizar_texto()

func actualizar_texto() -> void:
	label_puntos.text = "Puntos: " + str(puntos)
