extends Node

# underscore at the end of variable name is how to show that the var is global
# var pos_subjects_ = ["Math", "Science", "English"]

var categoryDict_ = {
	"Natural Science": 17,
	"Geography": 22,
	# "Math": 19,
	"Computer Science": 18,
	"History": 23
}

var difficultyList_ = [
	"easy",
	"medium",
	"hard"
]


var level_scene = preload("res://Scenes/Level.tscn")
var player_scene = preload("res://Scenes/Player.tscn")

# Game State
enum GameMode { NORMAL, BATTLE }
var current_game_mode

# Player variables
var player
var color: Array = ["blue", "grey", "orange"]

# Level variables
var current_level = 1

var htmlEntitesReplacement_ = {
	"&#039;": "'",
	"&Sigma;": "Σ",
	"&Omicron;": "ο",
	"&Pi;": "π",
	"&Nu;": "ν",
	"&quot;": '"',
	"&rsquo;": "’"
}


var type_of_question_ = ["multiple", "boolean"]
var number_of_quesions_ = 2
var selected_catagory_ # this is the value not the key
var selected_difficulty_ = "easy"

var subject_studying_

var json_data_
var json_wrong_ = {"results":[]}


var maze_time_ = 30

var maze_level_ = 1



func getCorrectAnswer(index):
	return json_data_["results"][index]["correct_answer"]

func getQuestionsLength():
	return len(json_data_["results"])

func getFirstQuestion():
	if (len(json_data_["results"]) > 0):
		#print (json_data_)
		return json_data_["results"][0]["question"]
	else:
		print("outOfQuestions")
		return null
		
func getQuestion(index):
	if (len(json_data_["results"]) > 0 and json_data_["results"][index]!= null):
		#print (json_data_)
		return json_data_["results"][index]["question"]
	else:
		print("outOfQuestions")
		return null
		
func getFirstAnswers():
	if (len(json_data_["results"]) > 0):
		#print (json_data_)
		var correctAnswer = json_data_["results"][0]["correct_answer"]
		var incorrectAnswers = json_data_["results"][0]["incorrect_answers"]

		var answers = incorrectAnswers + [correctAnswer]
		answers.shuffle()
		return answers
	else:
		print("outOfQuestions")
		return null

func getAnswers(index):
	if (len(json_data_["results"]) > 0 and json_data_["results"][index]!= null):
		#print (json_data_)
		var correctAnswer = json_data_["results"][index]["correct_answer"]
		var incorrectAnswers = json_data_["results"][index]["incorrect_answers"]

		var answers = incorrectAnswers + [correctAnswer]
		answers.shuffle()
		return answers
	else:
		print("outOfQuestions")
		return null
#func removeFirstQuestion():
#	if (len(json_data_["results"]) > 0):
#		print ("removing")
#		json_carrier_["results"].append(json_data_["results"][0]["question"])
#		json_data_["results"].remove_at(0)
#		return json_carrier_["results"][len(json_carrier_["results"])-1]
#	else:
#		print("outOfQuestions")
#		return null

func removeFirstQuestion():
	if (len(json_data_["results"]) > 0):
		# print ("removing")
		json_wrong_["results"].append(json_data_["results"][0]["question"])
		# json_data_["results"].remove_at(0)
		return json_wrong_["results"][len(json_wrong_["results"])-1]
	else:
		print("outOfQuestions")
		return null
