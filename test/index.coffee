fs = require 'fs'
path = require 'path'
chai = require 'chai'
yaml = require 'js-yaml'

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
	'tetrahedronIrregular'
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
	it 'returns a model object', ->
		jsonModel = loadYaml modelsMap['cube'].filePath

		modelPromise = meshlib jsonModel
		.done (model) -> model

		return expect(modelPromise).to.eventually.be.an.explicitModel


	it 'creates a face-vertex mesh', ->
		jsonModel = loadYaml modelsMap['cube'].filePath

		modelPromise = meshlib jsonModel
		.buildFaceVertexMesh()
		.done (model) -> model

		return expect(modelPromise).to.eventually.have.faceVertexMesh


	it 'builds faces from face vertex mesh', ->
		jsonModel = loadYaml modelsMap['tetrahedron'].filePath

		modelPromise = meshlib jsonModel
		.buildFaceVertexMesh()
		.setFaces(null)
		.buildFacesFromFaceVertexMesh()
		.getObject()
		.then (object) ->
			return object.mesh.faces

		return expect(modelPromise)
		.to.eventually.deep.equal(
			loadYaml(modelsMap['tetrahedron'].filePath).faces
		)


	it 'calculates face-normals', ->
		jsonModel = loadYaml modelsMap['cube'].filePath

		jsonModel.faces.forEach (face) ->
			delete face.normal

		modelPromise = meshlib jsonModel
		.calculateNormals()
		.done (model) -> model

		return expect(modelPromise).to.eventually.have.correctNormals


	it 'returns a clone', (done) ->
		jsonModel = loadYaml modelsMap['cube'].filePath

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
		jsonModel = loadYaml modelsMap['tetrahedrons'].filePath

		modelPromise = meshlib jsonModel
		.buildFaceVertexMesh()
		.getSubmodels()

		return expect(modelPromise).to.eventually.be.an('array')
		.and.to.have.length(2)


	it 'returns a JSON representation of the model', ->
		jsonModel = loadYaml modelsMap['cube'].filePath

		modelPromise = meshlib jsonModel
		.getJSON()

		return expect(modelPromise).to.eventually.be.a('string')


	it 'returns a javascript object representing the model', ->
		jsonModel = loadYaml modelsMap['cube'].filePath

		modelPromise = meshlib jsonModel
		.getObject()

		return expect(modelPromise).to.eventually.be.an('object')
		.and.to.have.any.keys('name', 'fileName', 'mesh')


	it 'translates a model', ->
		jsonModel = loadYaml modelsMap['tetrahedron'].filePath

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


	describe 'Modification Invariant Translation', ->
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

		it 'returns a modification invariant translation matrix', ->
			jsonModel = loadYaml modelsMap['tetrahedron'].filePath

			modelPromise = meshlib jsonModel
			.translate {z: 1}
			.buildFaceVertexMesh()
			.getModificationInvariantTranslation()

			return expect(modelPromise).to.eventually.deep.equal {
				x: -0.3333333333333333
				y: -0.3333333333333333
				z: -1
			}


	describe 'Two-Manifold Test', ->
		it 'recognizes that model is two-manifold', ->
			jsonModel = loadYaml modelsMap['tetrahedron'].filePath

			modelPromise = meshlib jsonModel
			.buildFaceVertexMesh()
			.isTwoManifold()

			return expect(modelPromise).to.eventually.be.true


		it 'recognizes that model is not two-manifold', ->
			jsonModel = loadYaml modelsMap['missingFace'].filePath

			modelPromise = meshlib jsonModel
			.buildFaceVertexMesh()
			.isTwoManifold()

			return expect(modelPromise).to.eventually.be.false


	describe 'calculateBoundingBox', ->
		it 'calculates the bounding box of a tetrahedron', ->
			jsonTetrahedron = loadYaml modelsMap['tetrahedron'].filePath

			modelPromise = meshlib jsonTetrahedron
			.buildFaceVertexMesh()
			.getBoundingBox()

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
			jsonTetrahedron = loadYaml modelsMap['tetrahedron'].filePath

			modelPromise = meshlib jsonTetrahedron
			.getFaces()

			expect(modelPromise).to.eventually
			.deep.equal(jsonTetrahedron.faces)


		it 'returns all faces which are orthogonal to the xy-plane', ->
			jsonTetrahedron = loadYaml modelsMap['tetrahedron'].filePath

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
			jsonTetrahedron = loadYaml(
				modelsMap['tetrahedronIrregular'].filePath
			)

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
			jsonTetrahedron = loadYaml modelsMap['tetrahedron'].filePath
			vertices = []

			return meshlib jsonTetrahedron
			.buildFaceVertexMesh()
			.forEachFace (face, index) ->
				vertices.push [face, index]
			.done () ->
				expect(vertices).to.have.length(4)


		it 'returns a rotation matrix to align the model
		  to the cartesian grid', ->
			jsonCube = loadYaml modelsMap['tetrahedron'].filePath
			cubePromise =  meshlib(jsonCube).getGridAlignRotation()
			expect(cubePromise).to.eventually.equal 0

			jsonCube = loadYaml modelsMap['cube'].filePath
			cubePromise =  meshlib jsonCube
			.rotate {angle: 42, unit: 'degree'}
			.calculateNormals()
			.getGridAlignRotation {unit: 'degree'}

			expect(cubePromise).to.eventually.equal 42



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
				actual = meshlib
				.Model
				.fromBase64 tetrahedronBase64Array.join('|')
				.getFaceVertexMesh()

				expect(actual).to.eventually.equalFaceVertexMesh(faceVertexMesh)


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

			matrix = Matrix.fromValues [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]

			expect matrix.toRows()
			.to.deep.equal [
				[1,0,0,0]
				[0,1,0,0]
				[0,0,1,0]
				[0,0,0,1]
			]


	describe 'Transformations', ->
		it 'can be transformed by applying a matrix', ->
			jsonModel = loadYaml modelsMap['tetrahedron'].filePath

			modelPromise = meshlib jsonModel
			.applyMatrix [
				[1, 0, 0, 10],
				[0, 1, 0, 20],
				[0, 0, 1, 30],
				[0, 0, 0,  1]
			]
			.getFaces()
			.then (faces) ->
				return faces[0].vertices

			expect modelPromise
			.to.eventually.deep.equal [
				{ x: 11, y: 20, z: 30 },
				{ x: 10, y: 21, z: 30 },
				{ x: 10, y: 20, z: 31 }
			]

		it 'can be rotated', ->
			jsonModel = loadYaml modelsMap['tetrahedron'].filePath

			modelPromise = meshlib jsonModel
			.rotate {angle: 45, unit: 'degree'}
			.getFaces()
			.then (faces) ->
				return faces[0].vertices

			expect modelPromise
			.to.eventually.deep.equal [
				{ x: 0.7071067811865476, y: 0.7071067811865475, z: 0 }
				{ x: -0.7071067811865475, y: 0.7071067811865476, z: 0 }
				{ x: 0, y: 0, z: 1 }
			]


