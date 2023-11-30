extends CanvasLayer

signal close

func _on_button_pressed():
	emit_signal("close")

func set_text(text: String):
	$Control/RichTextLabel.text = text
