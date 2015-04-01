fs = require 'fs'
path = require 'path'
chai = require 'chai'
yaml = require 'js-yaml'

Model = require '../source/Model'
meshlib = require '../source/index'

chai.use require './chaiHelper'
chai.use require 'chai-as-promised'
expect = chai.expect

loadYaml = (path) ->
	return yaml.safeLoad fs.readFileSync path

generateMap = (collection) ->
	return collection.reduce (previous, current, index) ->
		previous[current.name] = models[index]
		return previous
	, {}


models = [
	'cube'
	'tetrahedron'
	'tetrahedrons'
	'missingFace'
].map (model) ->
	return {
	name: model
	filePath: path.join(
		__dirname, 'models/', model + '.yaml'
	)
	}

modelsMap = generateMap models


checkEquality = (dataFromAscii, dataFromBinary, arrayName) ->
	fromAscii = dataFromAscii[arrayName].map (position) -> Math.round position
	fromBinary = dataFromBinary[arrayName].map (position) -> Math.round position

	expect(fromAscii).to.deep.equal(fromBinary)


describe 'Meshlib', ->
	it 'should return a model object', ->
		jsonModel = loadYaml modelsMap['cube'].filePath

		modelPromise = meshlib jsonModel
		.done (model) -> model

		return expect(modelPromise).to.eventually.be.a.model


	it 'should create a face-vertex mesh', ->
		jsonModel = loadYaml modelsMap['cube'].filePath

		modelPromise = meshlib jsonModel
		.buildFaceVertexMesh()
		.done (model) -> model

		return expect(modelPromise).to.eventually.have.faceVertexMesh


	it 'should calculate face-normals', ->
		jsonModel = loadYaml modelsMap['cube'].filePath

		jsonModel.faces.forEach (face) ->
			delete face.normal

		modelPromise = meshlib jsonModel
		.calculateNormals()
		.done (model) -> model

		return expect(modelPromise).to.eventually.have.correctNormals


	it.skip 'should extract individual geometries to submodels', ->
		jsonModel = loadYaml modelsMap['tetrahedrons'].filePath

		modelPromise = meshlib jsonModel
		.buildFaceVertexMesh()
		.getSubmodels()
		.then (models) -> models

		return expect(modelPromise).to.eventually.be.an('array')
		.and.to.have.length(2)


	it 'should be two-manifold', ->
		jsonModel = loadYaml modelsMap['tetrahedron'].filePath

		modelPromise = meshlib jsonModel
		.buildFaceVertexMesh()
		.isTwoManifold()
		.then (isTwoManifold) -> isTwoManifold

		return expect(modelPromise).to.eventually.be.true


	it 'should not be two-manifold', ->
		jsonModel = loadYaml modelsMap['missingFace'].filePath

		modelPromise = meshlib jsonModel
		.buildFaceVertexMesh()
		.isTwoManifold()
		.then (isTwoManifold) -> isTwoManifold

		return expect(modelPromise).to.eventually.be.false


	describe 'calculateBoundingBox', ->
		it 'calculates the bounding box of a tetrahedron', ->
			jsonTetrahedron = loadYaml modelsMap['tetrahedron'].filePath

			modelPromise = meshlib jsonTetrahedron
			.buildFaceVertexMesh()
			.getBoundingBox()
			.then (boundingBox) -> boundingBox

			return expect(modelPromise).to.eventually.deep.equal({
				min: {x: 0, y: 0, z: 0},
				max: {x: 1, y: 1, z: 1}
			})


		it 'calculates the bounding box of a cube', ->
			jsonCube = loadYaml modelsMap['cube'].filePath

			modelPromise = meshlib jsonCube
			.buildFaceVertexMesh()
			.getBoundingBox()

			return expect(modelPromise).to.eventually.deep.equal({
				min: {x: -1, y: -1, z: -1},
				max: {x: 1, y: 1, z: 1}
			})


	it 'iterates over all faces in the face-vertex-mesh', ->
		jsonTetrahedron = loadYaml modelsMap['tetrahedron'].filePath,
			vertices = []

		return meshlib jsonTetrahedron
		.buildFaceVertexMesh()
		.forEachFace (face, index) ->
			vertices.push [face, index]
		.done () ->
			expect(vertices).to.have.length(4)


	describe 'Base64', ->
		tetrahedronBase64Array = [
			# vertexCoordinates
			'AACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAA',

			# faceVertexIndices
			'AAAAAAEAAAACAAAAAwAAAAAAAAACAAAAAwAAAAIAAAABAAAAAwAAAAEAAAAAAAAA',

			# vertexNormalCoordinates
			'6toxP/EyAr/xMgK/8TICv+raMT/xMgK/8TICv/EyAr/q2jE/Os0TvzrNE786zRO/',

			# faceNormalCoordinates
			'Os0TPzrNEz86zRM/AAAAAAAAgL8AAAAAAACAvwAAAAAAAAAAAAAAAAAAAAAAAIC/',

			# name
			'tetrahedron'
		]


		it 'exports model to base64 representation', ->
			model = modelsMap['tetrahedron']
			jsonTetrahedron = loadYaml model.filePath

			modelPromise = meshlib jsonTetrahedron
			.setName model.name
			.buildFaceVertexMesh()
			.getBase64()
			.then (base64String) -> base64String.split('|')

			expect(modelPromise)
			.to.eventually.be.deep.equal(tetrahedronBase64Array)


		it 'creates model from base64 representation', ->
			jsonTetrahedron = loadYaml modelsMap['tetrahedron'].filePath

			return meshlib jsonTetrahedron
			.buildFaceVertexMesh()
			.getFaceVertexMesh()
			.then (faceVertexMesh) ->
				actual = meshlib()
				.fromBase64 tetrahedronBase64Array.join('|')
				.getFaceVertexMesh()

				expect(actual).to.eventually.equalFaceVertexMesh(faceVertexMesh)