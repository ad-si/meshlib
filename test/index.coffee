fs = require 'fs'
path = require 'path'
chai = require 'chai'

Model = require '../source/Model'
meshlib = require '../source/index'

chai.use require './chaiHelper'
chai.use require 'chai-as-promised'
expect = chai.expect


generateMap = (collection) ->
	return collection.reduce (previous, current, index) ->
		previous[current.name] = models[index]
		return previous
	, {}


models = [
	'cube'
].map (model) ->
	return {
		name: model
		filePath: path.join(
			__dirname, 'models/', model + '.json'
		)
	}

modelsMap = generateMap models


checkEquality = (dataFromAscii, dataFromBinary, arrayName) ->
	fromAscii = dataFromAscii[arrayName].map (position) -> Math.round position
	fromBinary = dataFromBinary[arrayName].map (position) -> Math.round position

	expect(fromAscii).to.deep.equal(fromBinary)


describe 'Meshlib', ->
	it 'should return a model object', ->
		jsonModel = fs.readFileSync modelsMap['cube'].filePath

		modelPromise = meshlib jsonModel
			.done (model) -> model

		return expect(modelPromise).to.eventually.be.a.model


	it 'should create a face-vertex mesh', ->
		jsonModel = require modelsMap['cube'].filePath

		modelPromise = meshlib jsonModel
			.optimize()
			.done (model) -> model

		return expect(modelPromise).to.eventually.be.optimized


	it 'should calculate face-normals', ->
		asciiStl = fs.readFileSync modelsMap['broken/wrongNormals'].asciiPath

		modelPromise = meshlib asciiStl, {format: 'stl'}
			.calculateNormals()
			.done (model) -> model

		return expect(modelPromise).to.eventually.have.correctNormals


	it 'ascii & binary version should have equal faces', () ->

		@timeout('10s')

		asciiStl = fs.readFileSync modelsMap['objects/gearwheel'].asciiPath
		binaryStl = fs.readFileSync modelsMap['objects/gearwheel'].binaryPath

		return Promise
			.all([
				meshlib(asciiStl, {format: 'stl'})
					.done((model) -> model)
				,
				meshlib(binaryStl, {format: 'stl'})
					.done((model) -> model)
			])
			.then (models) =>
				expect(models[0].mesh.polygons).to
					.equalFaces(models[1].mesh.polygons)


	it.skip 'should split individual geometries in STL file', () ->
		@timeout('45s')
		meshlib.separateGeometry(fromBinary)
