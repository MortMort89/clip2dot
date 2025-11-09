@tool
extends EditorPlugin

const MENU_ITEM := "Paste Image"

var paste_button: Button

func _enter_tree() -> void:
	add_tool_menu_item(MENU_ITEM, Callable(self, "_on_paste_image"))

	paste_button = Button.new()
	paste_button.text = "📋 Paste Image"
	paste_button.tooltip_text = "Paste clipboard image into the selected folder or overwrite the selected image"
	paste_button.focus_mode = Control.FOCUS_NONE
	paste_button.pressed.connect(_on_paste_image)
	add_control_to_container(CONTAINER_TOOLBAR, paste_button)

func _exit_tree() -> void:
	remove_tool_menu_item(MENU_ITEM)
	if paste_button:
		remove_control_from_container(CONTAINER_TOOLBAR, paste_button)
		paste_button.queue_free()

func _on_paste_image() -> void:
	var img: Image = DisplayServer.clipboard_get_image()
	if img == null:
		push_error("No image in clipboard.")
		return

	var editor_interface := get_editor_interface()
	var selected_path: String = editor_interface.get_current_path()
	if selected_path.is_empty():
		selected_path = "res://"

	var save_path: String

	# Overwrite selected image if one is chosen
	if selected_path.to_lower().ends_with(".png") or selected_path.to_lower().ends_with(".jpg") or selected_path.to_lower().ends_with(".jpeg"):
		save_path = selected_path
	else:
		# Otherwise, create a random filename in the selected folder
		if not selected_path.ends_with("/"):
			selected_path = selected_path.get_base_dir()
		var random_id := str(randi() % 1000000)
		save_path = selected_path.path_join("pasted_image_" + random_id + ".png")

	var err := img.save_png(save_path)
	if err == OK:
		print("Saved image:", save_path)
		editor_interface.get_resource_filesystem().scan()
	else:
		push_error("Failed to save image.")
