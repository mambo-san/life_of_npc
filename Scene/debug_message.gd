extends RigidBody2D
class_name DebugMessage


var _message: String
const text_velocity := Vector2(-75, 0)
var collided = false

func _init(message: String="Debug Message not set"):
	_message = message

func with_message(message: String) ->DebugMessage:
	_message = message
	return self

func _ready():
	$CollisionShape2D/RichTextLabel.text = _message
	gravity_scale = 0
	apply_impulse(Vector2(-30,0))

func _on_body_entered(body):
	Global.debug("Debug Message Collided with " + str(body.name))
	gravity_scale = 0.05

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
