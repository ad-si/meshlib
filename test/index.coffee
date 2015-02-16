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


describe.only 'Meshlib', ->
	it 'should return a model object', ->
		asciiStl = fs.readFileSync modelsMap['polytopes/triangle'].asciiPath
		binaryStl = fs.readFileSync modelsMap['polytopes/triangle'].binaryPath

		modelPromise = meshlib asciiStl, {format: 'stl'}
			.done (model) ->
				return model

		return expect(modelPromise).to.eventually.be.a.model


	it 'should be optimizable', ->
		asciiStl = fs.readFileSync modelsMap.gearwheel.asciiPath
		binaryStl = fs.readFileSync modelsMap.gearwheel.binaryPath

		modelPromise = meshlib asciiStl, {format: 'stl'}
			.optimize()
			.done (model) ->
				return model

		return expect(modelPromise).to.eventually.be.optimized


	it 'should fix polygons with 4 or more vertices', ->
		asciiStl = fs.readFileSync modelsMap['broken/fourVertices'].asciiPath

		modelPromise = meshlib asciiStl, {format: 'stl'}
			.removeInvalidPolygons()
			.done (model) ->
				return model

		return expect(modelPromise).to.eventually.be.a.triangleMesh


describe 'Model Parsing', () ->
	models.forEach (model) ->
		describe model.name, () ->

			fromAscii = null
			fromBinary = null

			it 'should load and parse ASCII STL file', (done) ->
				@timeout('8s')

				asciiStlBuffer = fs.readFileSync model.asciiPath

				meshlib.parse asciiStlBuffer, null, (error, dataFromAscii) ->
					if error
						throw error

					else if not dataFromAscii
						throw new Error 'Data is empty!'

					else
						fromAscii = dataFromAscii
						done()


			it 'should load and parse binary STL file', (done) ->
				@timeout('8s')

				binaryStlBuffer = fs.readFileSync model.binaryPath

				meshlib.parse binaryStlBuffer, null, (error, dataFromBinary) ->
					if error
						throw error
					else if not dataFromBinary
						throw new Error 'Data is empty!'
					else
						fromBinary = dataFromBinary
						done()


			it 'ascii & binary version should yield the same model', () ->
				for arrayName in ['positions', 'indices',
					'vertexNormals', 'faceNormals']
					it 'should yield the same model', () ->
						checkEquality fromAscii, fromBinary, arrayName


			it 'should split individual geometries in STL file', () ->
				@timeout('45s')
				meshlib.separateGeometry(fromBinary)
