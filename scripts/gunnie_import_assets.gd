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
	if node.name.contains("-animcol"): #only runs this function for nodes with this suffix
		node.create_convex_collision(true, true) # creates collision shape for the mesh
		for child in node.get_children(): # looks for staticbody3d that was just created by convex_colllision
			if child is StaticBody3D:
				colshape = child.get_child(0).shape # steals the collision shape
				child.queue_free() # removes staticbody3d
		var animbody3d = AnimatableBody3D.new()
		node.add_child(animbody3d)
		animbody3d.owner = node.owner # needed or else this won't work sets owner
		animbody3d.name = node.name.rstrip("-animcol") + "animbody"
		var animbodycol = CollisionShape3D.new()
		animbodycol.shape = colshape
		animbody3d.add_child(animbodycol)
		animbodycol.owner = animbody3d.owner
		animbodycol.name = node.name.rstrip("-animcol") + "colshape"
		print_rich("Post-import: [b]%s[/b] -> [b]%s[/b]" % [node.name, "modified_" + node.name])
		node.name = "modified_" + node.name.rstrip("-animcol")
