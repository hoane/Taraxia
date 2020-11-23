extends Control


func _ready():
	pass # Replace with function body.


func remove():
	$AnimationPlayer.play("FadeOut")
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
