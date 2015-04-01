# An optimized model structure with indexed faces / vertices
# and cached vertex and face normals
# Created by the stlImportPlugin

THREE = require 'three'

base64ByteLength = (base64Length) ->
	return (base64Length / 4) * 3

stringToUint8Array = (str) ->
	ab = new ArrayBuffer(str.length)
	uintarray = new Uint8Array(ab)
	for i in [0..str.length - 1]
		uintarray[i] = str.charCodeAt i
	return uintarray

class OptimizedModel
	constructor: () ->
		@verticesCoordinates = []
		@facesVerticesIndices = []
		@verticesNormals = []
		@facesNormals = []
		@originalFileName = 'Unknown file'

	fromBase64: (base64String) ->
		strArray = base64String.split '|'

		@verticesCoordinates = @base64ToFloat32Array strArray[0]
		@facesVerticesIndices = new @base64ToInt32Array strArray[1]
		@verticesNormals = @base64ToFloat32Array strArray[2]
		@facesNormals = @base64ToFloat32Array strArray[3]
		@originalFileName = strArray[4]

	base64ToFloat32Array: (b64) ->
		numFloats = (base64ByteLength b64.length) / 4
		result = new Float32Array(numFloats)
		decoded = stringToUint8Array atob(b64)
		pview = new DataView(decoded.buffer)
		for i in [0..numFloats - 1]
			result[i] = pview.getFloat32 i * 4, true
		return result

	base64ToInt32Array: (b64) ->
		numInts = (base64ByteLength b64.length) / 4
		result = new Int32Array(numInts)
		decoded = stringToUint8Array atob(b64)
		pview = new DataView(decoded.buffer)
		for i in [0..numInts - 1]
			result[i] = pview.getInt32 i * 4, true
		return result

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
