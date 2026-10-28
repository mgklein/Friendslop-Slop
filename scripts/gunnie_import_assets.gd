@tool # Needed so it runs in editor.
extends EditorScenePostImport
var colshape: Shape3D
# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	# Change all node names to "modified_[oldnodename]"
	iterate(scene)
	return scene # Remember to return the imported scene

# Recursive function that is called on every node
# (for demonstration purposes; EditorScenePostImport only requires a `_post_import(scene)` function).
func iterate(node):
	if node == null: #exits out if scene is null
		return
	for child in node.get_children(): # runs this function over each node in the scene
		iterate(child)
	if node.name.contains("-rectcol") or node.name.contains("cylcol"): #only runs this function for nodes with this suffix
		var animbodycol = CollisionShape3D.new()
		var nodeshape = node.scale
		if node.name.contains("-rectcol"):
			var newbox = BoxShape3D.new()
			newbox.size = 2 * nodeshape
			animbodycol.shape = newbox
		if node.name.contains("-cylcol"):
			var newbox = CylinderShape3D.new()
			newbox.height = 2 * nodeshape.y
			newbox.radius = nodeshape.x
			animbodycol.shape = newbox
		node.owner.add_child(animbodycol)
		animbodycol.owner = node.owner
		animbodycol.position = node.position
		animbodycol.rotation = node.rotation
		animbodycol.name = node.name.rstrip("-animcol") + "colshape"
		print_rich("Post-import: [b]%s[/b] -> [b]%s[/b]" % [node.name, "modified_" + node.name])
		node.name = "modified_" + node.name.rstrip("-animcol")
		node.queue_free()
