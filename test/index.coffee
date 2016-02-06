path = require 'path'
child_process = require 'child_process'
chai = require 'chai'
chaiPromised = require 'chai-as-promised'
chaiJsonSchema = require 'chai-json-schema'

ExplicitModel = require '../source/ExplicitModel'
meshlib = require '../source/index'
Face = require '../source/primitives/Face'
Matrix = require '../source/primitives/Matrix'
calculateProjectedFaceArea = require(
	'../source/helpers/calculateProjectedFaceArea')
calculateProjectionCentroid = require(
	'../source/helpers/calculateProjectionCentroid')
buildFacesFromFaceVertexMesh = require(
	'../source/helpers/buildFacesFromFaceVertexMesh')
chaiHelper = require './chaiHelper'
models = require './models/models'

expect = chai.expect

# Order of use statments is important
chai.use chaiHelper
chai.use chaiPromised
chai.use chaiJsonSchema


checkEquality = (dataFromAscii, dataFromBinary, arrayName) ->
	fromAscii = dataFromAscii[arrayName].map (position) -> Math.round position
	fromBinary = dataFromBinary[arrayName].map (position) -> Math.round position

	expect(fromAscii).to.deep.equal(fromBinary)


describe 'Meshlib', ->
	it 'returns a model object', ->
		jsonModel = models['cube'].load()

		modelPromise = meshlib jsonModel
		.done (model) -> model

		return expect(modelPromise).to.eventually.be.an.explicitModel


	it 'builds faces from face vertex mesh', ->
		jsonModel = models['tetrahedron'].load()

		modelPromise = meshlib jsonModel
		.buildFaceVertexMesh()
		.setFaces(null)
		.buildFacesFromFaceVertexMesh()
		.getObject()
		.then (object) ->
			return object.mesh.faces

		return expect(modelPromise)
		.to.eventually.deep.equal(
			models['tetrahedron'].load().faces
		)


	it 'calculates face-normals', ->
		jsonModel = models['cube'].load()

		jsonModel.faces.forEach (face) ->
			delete face.normal

		modelPromise = meshlib jsonModel
		.calculateNormals()
		.done (model) -> model

		return expect(modelPromise).to.eventually.have.correctNormals


	it 'returns a clone', (done) ->
		jsonModel = models['cube'].load()

		model = meshlib jsonModel

		model
		.getObject()
		.then (object) ->
			model
			.getClone()
			.then (modelClone) ->
				return modelClone.getObject()
			.then (cloneObject) ->
				try
					expect(cloneObject).to.deep.equal(object)
					done()
				catch error
					done(error)


	it 'extracts individual geometries to submodels', ->
		jsonModel = models['tetrahedrons'].load()

		modelPromise = meshlib jsonModel
		.buildFaceVertexMesh()
		.getSubmodels()

		return expect(modelPromise).to.eventually.be.an('array')
		.and.to.have.length(2)


	it 'returns a JSON representation of the model', ->
		jsonModel = models['cube'].load()

		modelPromise = meshlib jsonModel
		.getJSON()

		return expect(modelPromise).to.eventually.be.a('string')


	it 'returns a javascript object representing the model', ->
		jsonModel = models['cube'].load()

		modelPromise = meshlib jsonModel
		.getObject()

		return expect(modelPromise).to.eventually.be.an('object')
		.and.to.have.any.keys('name', 'fileName', 'mesh')


	it 'translates a model', ->
		jsonModel = models['tetrahedron'].load()

		modelPromise = meshlib jsonModel
		.translate {x: 1, y: 1, z: 1}
		.getObject()
		.then (object) ->
			return object.mesh.faces[0].vertices

		return expect(modelPromise).to.eventually.deep.equal [
			{x: 2, y: 1, z: 1},
			{x: 1, y: 2, z: 1},
			{x: 1, y: 1, z: 2}
		]


	it 'calculates the centroid of a face-projection', ->
		expect calculateProjectionCentroid {
			vertices: [
				{x: 0, y: 0, z: 0}
				{x: 2, y: 0, z: 0}
				{x: 0, y: 2, z: 0}
			]
		}
		.to.deep.equal {
			x: 0.6666666666666666
			y: 0.6666666666666666
		}


	describe 'Two-Manifold Test', ->
		it 'recognizes that model is two-manifold', ->
			jsonModel = models['tetrahedron'].load()

			modelPromise = meshlib jsonModel
			.buildFaceVertexMesh()
			.isTwoManifold()

			return expect(modelPromise).to.eventually.be.true


		it 'recognizes that model is not two-manifold', ->
			jsonModel = models['missingFace'].load()

			modelPromise = meshlib jsonModel
			.buildFaceVertexMesh()
			.isTwoManifold()

			return expect(modelPromise).to.eventually.be.false


	describe 'calculateBoundingBox', ->
		it 'calculates the bounding box of a tetrahedron', ->
			jsonTetrahedron = models['tetrahedron'].load()

			modelPromise = meshlib jsonTetrahedron
			.buildFaceVertexMesh()
			.getBoundingBox()

			return expect(modelPromise).to.eventually.deep.equal({
				min: {x: 0, y: 0, z: 0},
				max: {x: 1, y: 1, z: 1}
			})


		it 'calculates the bounding box of a cube', ->
			jsonCube = models['cube'].load()

			modelPromise = meshlib jsonCube
			.buildFaceVertexMesh()
			.getBoundingBox()

			return expect(modelPromise).to.eventually.deep.equal({
				min: {x: -1, y: -1, z: -1},
				max: {x: 1, y: 1, z: 1}
			})


	describe 'Faces', ->
		it 'calculate the surface area of a face', ->
			surfaceArea = Face
			.fromObject {
				vertices: [
					{x: 1, y: 0, z: 0},
					{x: 1, y: 0, z: 1},
					{x: 0, y: 1, z: 0}
				]
			}
			.getSurfaceArea()

			expect(surfaceArea).to.equal Math.SQRT2 / 2

		it 'returns all faces', ->
			jsonTetrahedron = models['tetrahedron'].load()

			modelPromise = meshlib jsonTetrahedron
			.getFaces()

			expect(modelPromise).to.eventually
			.deep.equal(jsonTetrahedron.faces)


		it 'returns all faces which are orthogonal to the xy-plane', ->
			jsonTetrahedron = models['tetrahedron'].load()

			modelPromise = meshlib jsonTetrahedron
			.getFaces {
				filter: (face) ->
					return face.normal.z is 0
			}

			expect(modelPromise).to.eventually.deep.equal [
				{
					vertices: [
						{x: 0, y: 0, z: 0},
						{x: 1, y: 0, z: 0},
						{x: 0, y: 0, z: 1}
					],
					normal: {x: 0, y: -1, z: 0}
				},
				{
					vertices: [
						{x: 0, y: 0, z: 0},
						{x: 0, y: 0, z: 1},
						{x: 0, y: 1, z: 0}
					],
					normal: {x: -1, y: 0, z: 0}
				}
			]


		it 'calculates the in xy-plane projected surface-area of a face', ->
			expect calculateProjectedFaceArea {
				vertices: [
					{x: 0, y: 0, z: 2}
					{x: 1, y: 0, z: 0}
					{x: 0, y: 1, z: 0}
				]
			}
			.to.equal 0.5

			expect calculateProjectedFaceArea {
				vertices: [
					{x: 0, y: 0, z: -2}
					{x: 2, y: 0, z: 0}
					{x: 0, y: 4, z: 0}
				]
			}
			.to.equal 4


		it 'retrieves the face with the largest xy-projection', ->
			jsonTetrahedron = models['irregular tetrahedron'].load()

			modelPromise = meshlib jsonTetrahedron
			.getFaceWithLargestProjection()

			return expect(modelPromise).to.eventually.deep.equal {
				normal: {x: 0, y: 0, z: -1}
				vertices: [
					{x: 0, y: 0, z: 0}
					{x: 0, y: 2, z: 0}
					{x: 3, y: 0, z: 0}
				]
				attribute: 0
			}


		it 'iterates over all faces in the face-vertex-mesh', ->
			jsonTetrahedron = models['tetrahedron'].load()
			vertices = []

			return meshlib jsonTetrahedron
			.buildFaceVertexMesh()
			.forEachFace (face, index) ->
				vertices.push [face, index]
			.done () ->
				expect(vertices).to.have.length(4)


		it 'returns a rotation angle
			to align the model to the cartesian grid', ->
			jsonTetrahedron = models['tetrahedron'].load()
			tetrahedronPromise = meshlib(jsonTetrahedron).getGridAlignRotationAngle()

			expect(tetrahedronPromise).to.eventually.equal 0

			jsonCube = models['cube'].load()
			cubePromise = meshlib jsonCube
			.rotate {angle: 42, unit: 'degree'}
			.calculateNormals()
			.getGridAlignRotationAngle {unit: 'degree'}

			expect(cubePromise).to.eventually.equal 42


		it 'returns a histogram
			with the surface area for each rotation angle', ->
			jsonCube = models['cube'].load()
			cubePromise = meshlib jsonCube
				.rotate {angle: 42, unit: 'degree'}
				.calculateNormals()
				.getGridAlignRotationHistogram()
			expectedArray = new Array(90)
			expectedArray[42] = 16

			expectedArray =
				(index + '\t' + (value or 0) for value, index in expectedArray)

			expect(cubePromise)
			.to.eventually.deep.equal expectedArray.join '\n'


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
			model = models['tetrahedron']
			jsonTetrahedron = model.load()

			modelPromise = meshlib jsonTetrahedron
			.setName model.name
			.buildFaceVertexMesh()
			.getBase64()
			.then (base64String) -> base64String.split('|')

			expect(modelPromise)
			.to.eventually.be.deep.equal(tetrahedronBase64Array)


		it 'creates model from base64 representation', ->
			jsonTetrahedron = models['tetrahedron'].load()

			return meshlib jsonTetrahedron
			.buildFaceVertexMesh()
			.getFaceVertexMesh()
			.then (faceVertexMesh) ->
				actual = meshlib
				.Model
				.fromBase64 tetrahedronBase64Array.join('|')
				.getFaceVertexMesh()


				expect(actual).to.eventually.equalFaceVertexMesh(faceVertexMesh)

		it 'parses a complex base64 encoded model', ->
			base64Model = models['heart'].load()
			modelSchema = {
				title: 'Meshlib-model schema'
				type: 'object'
				required: ['mesh']
				properties:
					name: {type: 'string'}
					fileName: {type: 'string'}
					mesh:
						type: 'object'
						required: ['faceVertex']
						properties:
							faceVertex:
								type: 'object'
								required: [
									'faceVertexIndices'
									'vertexCoordinates'
									'vertexNormalCoordinates'
									'faceNormalCoordinates'
								]
			}
			modelPromise = meshlib.Model
				.fromBase64(base64Model)
				.getObject()
				.then (object) ->
					return expect(object).to.be.jsonSchema(modelSchema)

			return expect(modelPromise).to.eventually.be.ok


	describe 'Matrix', ->
		it 'builds a Matrix from colum-major arrays', ->
			matrix = Matrix.fromColums [
				[1, 2, 3]
				[4, 5, 6]
				[7, 8, 9]
			]

			expect matrix.toRows()
			.to.deep.equal [
				[1, 4, 7]
				[2, 5, 8]
				[3, 6, 9]
			]

		it 'multiplies a 3x2 Matrix by a 2x3 Matrix', ->
			matrix = Matrix.fromRows [
				[1, 2, 3]
				[4, 5, 6]
			]

			expect matrix.multiply [
				[7, 8]
				[9, 10]
				[11, 12]
			]
			.to.deep.equal [
				[58, 64]
				[139, 154]
			]


		it 'multiplies a 3x1 Matrix by a 4x3 Matrix', ->
			matrix = Matrix.fromRows [
				[3, 4, 2]
			]

			expect matrix.multiply [
				[13, 9, 7, 15]
				[8, 7, 4, 6]
				[6, 4, 0, 3]
			]
			.to.deep.equal [
				[83, 63, 37, 75]
			]


		it 'multiplies a 1x3 Matrix by a 4x4 Matrix', ->
			matrix = Matrix.fromRows [
				[1, 0, 0, 7]
				[0, 1, 0, 6]
				[0, 0, 1, 8]
				[0, 0, 0, 1]
			]

			expect matrix.multiply [
				[3]
				[4]
				[2]
				[1]
			]
			.to.deep.equal [
				[10]
				[10]
				[10]
				[1]
			]


		it 'creates a Matrix from a continuous Array', ->
			matrix = Matrix.fromValues [1, 0, 0, 0,
										0, 1, 0, 0,
										0, 0, 1, 0,
										0, 0, 0, 1]

			expect matrix.toRows()
			.to.deep.equal [
				[1, 0, 0, 0]
				[0, 1, 0, 0]
				[0, 0, 1, 0]
				[0, 0, 0, 1]
			]


	describe 'Transformations', ->
		it 'can be transformed by applying a matrix', ->
			jsonModel = models['tetrahedron'].load()

			modelPromise = meshlib jsonModel
			.applyMatrix [
				[1, 0, 0, 10],
				[0, 1, 0, 20],
				[0, 0, 1, 30],
				[0, 0, 0, 1]
			]
			.getFaces()
			.then (faces) ->
				return faces[0].vertices

			expect modelPromise
			.to.eventually.deep.equal [
				{x: 11, y: 20, z: 30},
				{x: 10, y: 21, z: 30},
				{x: 10, y: 20, z: 31}
			]

		it 'can be rotated', ->
			jsonModel = models['tetrahedron'].load()

			modelPromise = meshlib jsonModel
			.rotate {angle: 45, unit: 'degree'}
			.getFaces()
			.then (faces) ->
				return faces[0].vertices

			expect modelPromise
			.to.eventually.deep.equal [
				{x: 0.7071067811865476, y: 0.7071067811865475, z: 0}
				{x: -0.7071067811865475, y: 0.7071067811865476, z: 0}
				{x: 0, y: 0, z: 1}
			]


	describe 'Command Line Interface', ->
		it 'parses a YAML file', ->
			command = path.resolve(__dirname, '../cli/index-dev.js') + ' ' +
				models['tetrahedron'].filePath
			expectedOutput = JSON.stringify({
				mesh: models['tetrahedron'].load()
			}) + '\n'

			actualOutput = child_process
				.execSync(command, {stdio: [0]})
				.toString()

			expect(actualOutput).to.equal expectedOutput


		it 'parses a JSONL stream', ->
			command =
				path.resolve(__dirname, '../cli/index-dev.js') +
				' --json < ' + models['jsonl tetrahedron'].filePath
			expectedOutput = JSON.stringify({
				mesh: models['normal first tetrahedron'].load()
			}) + '\n'

			actualOutput = JSON.parse(
				child_process.execSync(command, {stdio: [0]})
			)

			actualOutput.mesh.faces = actualOutput.mesh.faces
				.map (face) ->
					delete face.number
					return face

			delete actualOutput.name
			delete actualOutput.transformations
			delete actualOutput.options

			actualOutput = JSON.stringify(actualOutput) + '\n'

			expect(actualOutput).to.equal expectedOutput


		it 'parses a base64 file and emits a JSONL stream', ->
			command = path.resolve(__dirname, '../cli/index-dev.js') +
				' --input base64 ' + models['heart'].filePath

			actualOutput = child_process
				.execSync(command, {stdio: [0]})
				.toString()

			expect(actualOutput).to.match(/^\{.*\}$/gm)
