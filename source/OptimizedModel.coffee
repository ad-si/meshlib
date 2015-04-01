# An optimized model structure with indexed faces / vertices
# and cached vertex and face normals
# Created by the stlImportPlugin

THREE = require 'three'



class OptimizedModel
	constructor: () ->
		@verticesCoordinates = []
		@facesVerticesIndices = []
		@verticesNormals = []
		@facesNormals = []
		@originalFileName = 'Unknown file'


	# Creates a ThreeGeometry out of an optimized model
	# if bufferGeoemtry is set to true, a BufferGeometry using
	# the vertex normals will be created
	# else, a normal Geometry with face normals will be created
	# (contains duplicate vertices, but provides better shading for sharp edges)
	convertToThreeGeometry: (bufferGeometry = false) ->
		if (bufferGeometry)
			return @createBufferGeometry()
		else
			return @createStandardGeometry()

	# Creates a THREE.BufferGeometry using vertex normals
	createBufferGeometry: ->
		geometry = new THREE.BufferGeometry()
		# Officially, threejs supports normal array, but in fact,
		# you have to use this lowlevel datatype to view something
		parray = new Float32Array(@verticesCoordinates.length)
		for i in [0..@verticesCoordinates.length - 1]
			parray[i] = @verticesCoordinates[i]
		narray = new Float32Array(@verticesNormals.length)
		for i in [0..@verticesNormals.length - 1]
			narray[i] = @verticesNormals[i]
		iarray = new Uint32Array(@facesVerticesIndices.length)
		for i in [0..@facesVerticesIndices.length - 1]
			iarray[i] = @facesVerticesIndices[i]

		geometry.addAttribute 'index', new THREE.BufferAttribute(iarray, 1)
		geometry.addAttribute 'position', new THREE.BufferAttribute(parray, 3)
		geometry.addAttribute 'normal', new THREE.BufferAttribute(narray, 3)
		geometry.computeBoundingSphere()
		return geometry

	# Uses a THREE.Geometry using face normals
	createStandardGeometry: ->
		geometry = new THREE.Geometry()

		for vi in [0..@verticesCoordinates.length - 1] by 3
			geometry.verticesCoordinates.push new THREE.Vector3(
				@verticesCoordinates[vi],
				@verticesCoordinates[vi + 1],
				@verticesCoordinates[vi + 2]
				)

		for fi in [0..@facesVerticesIndices.length - 1] by 3
			geometry.faces.push new THREE.Face3(
				@facesVerticesIndices[fi],
				@facesVerticesIndices[fi + 1],
				@facesVerticesIndices[fi + 2],
				new THREE.Vector3(
					@facesNormals[fi],
					@facesNormals[fi + 1],
					@facesNormals[fi + 2]
					)
				)

		return geometry

	# Imports from a THREE.Geometry
	# Imports faces, vertices and face normals
	fromThreeGeometry: (threeGeometry, originalFileName = 'Three.Geometry') =>
		# Clear data, if exists
		@verticesCoordinates = []
		@facesVerticesIndices = []
		@facesNormals = []
		@verticesNormals = []
		@originalFileName = originalFileName

		for vertex in threeGeometry.verticesCoordinates
			@verticesCoordinates.push vertex.x
			@verticesCoordinates.push vertex.y
			@verticesCoordinates.push vertex.z

		# Convert faces and their normals
		for face in threeGeometry.faces
			@facesVerticesIndices.push face.a
			@facesVerticesIndices.push face.b
			@facesVerticesIndices.push face.c

			@facesNormals.push face.normal.x
			@facesNormals.push face.normal.y
			@facesNormals.push face.normal.z

module.exports = OptimizedModel
