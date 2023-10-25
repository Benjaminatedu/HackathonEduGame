extends Node2D



var time_left: int = 5
var timer
var timerLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	var timer = $Timer
	timer.wait_time = 1.0
	timer.autostart = true
	timer.start()
	timer.connect("timeout", Callable(self, "_on_timer_timeout" ))
	
	_update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _update_label():
	timerLabel = $timeLabel
	
	var minutes: int = time_left / 60
	var seconds: int = time_left % 60
	timerLabel.text = "%02d:%02d" % [minutes, seconds]


func _on_timer_timeout():
	time_left -= 1
	_update_label()
	
	if time_left <=0:
		get_tree().change_scene_to_file("res://Scenes/quiz.tscn")

func _on_button_pressed():
	print(GlobalData.json_data_)
	pass # Replace with function body.
	print(GlobalData.getFirstQuestion())
	print(GlobalData.removeFirstQuestion())

