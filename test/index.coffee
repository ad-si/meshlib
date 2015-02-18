fs = require 'fs'
path = require 'path'
chai = require 'chai'

Model = require '../source/Model'
meshlib = require '../source/index'

chai.use require './chaiHelper'
chai.use require 'chai-as-promised'
expect = chai.expect

models = [
	'polytopes/triangle'
	'polytopes/cube'
	'broken/fourVertices'
	'broken/twoVertices'
	'broken/wrongNormals'
	'gearwheel'
	'geoSplit2'
	'geoSplit4'
	'geoSplit5'
	'geoSplit7'
	'bunny'
].map (model) ->
	return {
		name: model
		asciiPath: path.join __dirname, 'models', model + '.ascii.stl'
		binaryPath: path.join __dirname, 'models', model + '.bin.stl'
	}

modelsMap = models.reduce (previous, current, index) ->
	previous[current.name] = models[index]
	return previous
, {}


checkEquality = (dataFromAscii, dataFromBinary, arrayName) ->
	fromAscii = dataFromAscii[arrayName].map (position) -> Math.round position
	fromBinary = dataFromBinary[arrayName].map (position) -> Math.round position

	expect(fromAscii).to.deep.equal(fromBinary)


describe 'Meshlib', ->
	it 'should return a model object', ->
		asciiStl = fs.readFileSync modelsMap['polytopes/triangle'].asciiPath

		modelPromise = meshlib asciiStl, {format: 'stl'}
			.done (model) -> model

		return expect(modelPromise).to.eventually.be.a.model


	it 'should create a face-vertex mesh', ->
		asciiStl = fs.readFileSync modelsMap.gearwheel.asciiPath

		modelPromise = meshlib asciiStl, {format: 'stl'}
			.optimize()
			.done (model) -> model

		return expect(modelPromise).to.eventually.be.optimized


	it 'should fix faces with 4 or more vertices', ->
		asciiStl = fs.readFileSync modelsMap['broken/fourVertices'].asciiPath

		modelPromise = meshlib asciiStl, {format: 'stl'}
			.fixFaces()
			.done (model) -> model

		return expect(modelPromise).to.eventually.be.a.triangleMesh


	it 'should fix faces with 2 or less vertices', ->
		asciiStl = fs.readFileSync modelsMap['broken/twoVertices'].asciiPath

		modelPromise = meshlib asciiStl, {format: 'stl'}
			.fixFaces()
			.done (model) -> model

		return expect(modelPromise).to.eventually.be.a.triangleMesh


	it 'should calculate face-normals', ->
		asciiStl = fs.readFileSync modelsMap['broken/wrongNormals'].asciiPath

		modelPromise = meshlib asciiStl, {format: 'stl'}
			.calculateNormals()
			.done (model) -> model

		return expect(modelPromise).to.eventually.have.correctNormals


	it 'ascii & binary version should have equal faces', () ->

		@timeout('10s')

		asciiStl = fs.readFileSync modelsMap.gearwheel.asciiPath
		binaryStl = fs.readFileSync modelsMap.gearwheel.binaryPath

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
