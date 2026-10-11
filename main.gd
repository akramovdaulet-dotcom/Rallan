extends Node2D

const SKY := Color("#a9ddff")
const GRASS := Color("#83c96b")
const ROAD := Color("#565b63")
const YELLOW := Color("#ffdf5d")
const RED := Color("#e53935")

var car_x := 480.0
var car_y := 365.0
var speed := 0.0
var stars := 0
var learning_open := false
var pressed_left := false
var pressed_right := false
var pressed_gas := false

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	if pressed_left:
		car_x -= 220.0 * delta
	if pressed_right:
		car_x += 220.0 * delta
	if pressed_gas:
		speed = minf(speed + 100.0 * delta, 260.0)
	else:
		speed = maxf(speed - 80.0 * delta, 0.0)
	car_x = clampf(car_x, 110.0, 850.0)
	queue_redraw()

func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), SKY)
	draw_rect(Rect2(0, 205, size.x, 335), GRASS)
	# Road and lane markings
	draw_colored_polygon(PackedVector2Array([Vector2(280, 205), Vector2(680, 205), Vector2(900, 540), Vector2(60, 540)]), ROAD)
	for i in range(5):
		var y := 245.0 + i * 70.0
		draw_rect(Rect2(475, y, 10, 34), Color.WHITE)
	# Distant Ufa-inspired skyline and monument silhouette
	draw_circle(Vector2(145, 125), 38, Color("#fff0a8"))
	for i in range(6):
		var bx := 35.0 + i * 145.0
		draw_rect(Rect2(bx, 170, 58, 48), Color("#7ca6b8"))
		draw_rect(Rect2(bx + 10, 180, 8, 12), Color("#d8f3ff"))
		draw_rect(Rect2(bx + 32, 180, 8, 12), Color("#d8f3ff"))
	# A simple monument landmark
	draw_rect(Rect2(790, 145, 12, 63), Color("#6d7780"))
	draw_colored_polygon(PackedVector2Array([Vector2(776, 145), Vector2(816, 145), Vector2(796, 110)]), Color("#6d7780"))
	# Car body, windows, wheels
	draw_rect(Rect2(car_x - 42, car_y - 28, 84, 54), RED)
	draw_rect(Rect2(car_x - 28, car_y - 42, 56, 28), Color("#b92728"))
	draw_rect(Rect2(car_x - 22, car_y - 37, 44, 19), Color("#bce9f7"))
	draw_rect(Rect2(car_x - 48, car_y - 19, 10, 19), Color("#202329"))
	draw_rect(Rect2(car_x + 38, car_y - 19, 10, 19), Color("#202329"))
	draw_rect(Rect2(car_x - 32, car_y + 18, 18, 12), Color("#202329"))
	draw_rect(Rect2(car_x + 14, car_y + 18, 18, 12), Color("#202329"))
	draw_rect(Rect2(car_x - 35, car_y - 20, 8, 7), Color("#fff2b0"))
	draw_rect(Rect2(car_x + 27, car_y - 20, 8, 7), Color("#fff2b0"))
	# HUD
	draw_rect(Rect2(16, 14, 270, 62), Color("#ffffffd9"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 40), "ПРИКЛЮЧЕНИЯ РАЛЛАНА", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#263746"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 62), "⭐ Звёзды: %d   Скорость: %d" % [stars, int(speed)], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#263746"))
	# Touch controls
	_draw_button(Rect2(24, 430, 100, 82), "◀", pressed_left)
	_draw_button(Rect2(136, 430, 100, 82), "▶", pressed_right)
	_draw_button(Rect2(740, 430, 190, 82), "ЕХАТЬ", pressed_gas)
	_draw_button(Rect2(700, 18, 230, 58), "УЧИТЬСЯ", learning_open)
	if learning_open:
		draw_rect(Rect2(235, 110, 490, 250), Color("#fffdf2"))
		draw_string(ThemeDB.fallback_font, Vector2(270, 150), "УЧИМСЯ И ИГРАЕМ!", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#263746"))
		draw_string(ThemeDB.fallback_font, Vector2(270, 196), "Буквы: А   Б   В   Г", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#263746"))
		draw_string(ThemeDB.fallback_font, Vector2(270, 232), "Математика: 2 + 3 = ?", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#263746"))
		draw_string(ThemeDB.fallback_font, Vector2(270, 268), "Нажми на звезду, чтобы получить награду!", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#263746"))
		_draw_button(Rect2(405, 292, 150, 48), "⭐ +1", false)

func _draw_button(rect: Rect2, label: String, active: bool) -> void:
	var fill := Color("#ffd45a") if active else Color("#fff8dd")
	draw_rect(rect, fill)
	draw_rect(rect, Color("#8d6a27"), false, 3.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(14, rect.size.y * 0.63), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 28, 25, Color("#253746"))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event.position, event.pressed)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_touch(event.position, event.pressed)

func _handle_touch(pos: Vector2, down: bool) -> void:
	if not down:
		pressed_left = false
		pressed_right = false
		pressed_gas = false
		return
	if Rect2(24, 430, 100, 82).has_point(pos):
		pressed_left = true
	elif Rect2(136, 430, 100, 82).has_point(pos):
		pressed_right = true
	elif Rect2(740, 430, 190, 82).has_point(pos):
		pressed_gas = true
	elif Rect2(700, 18, 230, 58).has_point(pos):
		learning_open = not learning_open
	elif learning_open and Rect2(405, 292, 150, 48).has_point(pos):
		stars += 1
	queue_redraw()
