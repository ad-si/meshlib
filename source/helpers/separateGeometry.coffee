# Takes a face-vertex-mesh and looks for connected geometry
# returns a list of face-vertex meshes if the original mesh
# contains several geometries (-> connected faces) that
# have no connection between each other

module.exports = (faceVertexMesh) ->
	vertexLabels = labelVertices faceVertexMesh

	meshes = buildMeshes faceVertexMesh, vertexLabels

	return meshes


labelVertices = ({vertexCoordinates, faceVertexIndices}) ->
	# Each vertex (there are numberOfVertices / 3) needs a label
	vertexLabels = new Array vertexCoordinates.length / 3
	# Each label belongs to a equivalence class: labelTable[label] = eqClass
	labelTable = []

	# For all faces
	for faceStart in [0...faceVertexIndices.length] by 3

		# Read vertex indices for current face
		indices = [0, 1, 2].map (o) -> faceVertexIndices[faceStart + o]

		# Collect all defined labels of those vertices
		labels = [0, 1, 2]
			.map (o) -> vertexLabels[indices[o]]
			.filter (l) -> l?

		if labels.length is 0
			# Introduce a new label if all vertices are unlabeled so far
			label = labelTable.length
			# The label is currently the only member of a new equivalence class
			labelTable[label] = label
		else
			# Use the equivalence class of the first label as label for all vertices
			label = labelTable[labels.pop()]

		# Set the vertices of this face to the selected label
		# (might have been undefined before)
		[0, 1, 2].forEach (o) -> vertexLabels[indices[o]] = label

		# Mark labels as merged in equivalence table
		# All outdated labels...
		labels.forEach (mergeLabel) ->
			# ...in the whole equivalence table...
			labelTable.forEach (val, i) ->
				# ...are to be replaced by the label of the equivalence class.
				labelTable[i] = label if val is mergeLabel

	# Apply equivalence table and return the final per-vertex label table
	return vertexLabels.map (label) -> labelTable[label]


buildMeshes = (faceVertexMesh, vertexLabels) ->
	{
		vertexCoordinates
		faceVertexIndices
		vertexNormalCoordinates
		faceNormalCoordinates
	} = faceVertexMesh

	# For each equivalence class, a new face-vertex-mesh has to be created
	meshes = {}
	# The indices in the old mesh do not (necessarily) match the indices in the
	# new mesh -> we have do apply a mapping
	indexMapping = {}

	# Move the vertices and their normals to their respective new mesh
	for label, i in vertexLabels
		# Create mesh data structure for the label if not already present
		unless meshes[label]?
			meshes[label] = {
				vertexCoordinates: []
				faceVertexIndices: []
				vertexNormalCoordinates: []
				faceNormalCoordinates: []
			}
			indexMapping[label] = {}

		# Select this mesh for insertion
		mesh = meshes[label]
		mapping = indexMapping[label]

		# Store where the vertex will be in the new mesh, mapped to its old index
		mapping[i] = mesh.vertexCoordinates.length / 3

		# Copy the coordinates of the vertex to the new mesh
		if vertexCoordinates[i * 3]?
			mesh.vertexCoordinates.push vertexCoordinates[i * 3]
		if vertexCoordinates[i * 3 + 1]?
			mesh.vertexCoordinates.push vertexCoordinates[i * 3 + 1]
		if vertexCoordinates[i * 3 + 2]?
			mesh.vertexCoordinates.push vertexCoordinates[i * 3 + 2]

		# Copy the normal of the vertex to the new mesh
		if vertexNormalCoordinates[i * 3]?
			mesh.vertexNormalCoordinates.push(
				vertexNormalCoordinates[i * 3]
			)
		if vertexNormalCoordinates?[i * 3 + 1]?
			mesh.vertexNormalCoordinates.push(
				vertexNormalCoordinates?[i * 3 + 1]
			)
		if vertexNormalCoordinates?[i * 3 + 2]
			mesh.vertexNormalCoordinates.push(
				vertexNormalCoordinates?[i * 3 + 2]
			)

	# Move the faces and their normals to their respective new meshes
	for faceStart in [0...faceVertexIndices.length] by 3
		# Find out, which mesh the face belongs to
		label = vertexLabels[faceVertexIndices[faceStart]]

		# Select this mesh for insertion
		mesh = meshes[label]
		mapping = indexMapping[label]

		# Insert the vertex indices of this face
		mesh.faceVertexIndices.push mapping[faceVertexIndices[faceStart]]
		mesh.faceVertexIndices.push mapping[faceVertexIndices[faceStart + 1]]
		mesh.faceVertexIndices.push mapping[faceVertexIndices[faceStart + 2]]

		# Insert the face normal of this face
		mesh.faceNormalCoordinates.push faceNormalCoordinates[faceStart]
		mesh.faceNormalCoordinates.push faceNormalCoordinates[faceStart + 1]
		mesh.faceNormalCoordinates.push faceNormalCoordinates[faceStart + 2]

	# Convert the mesh map to a plain array (we don't need labels any more)
	# and return the final array of separated meshes
	return (mesh for label, mesh of meshes)
