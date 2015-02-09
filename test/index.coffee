fs = require 'fs'
path = require 'path'
expect = require('chai').expect

Model = require '../source/Model'
meshlib = require '../source/index'


models = [
	'unitCube'
	'gearwheel'
	'geoSplit2'
	'geoSplit4'
	'geoSplit5'
	'geoSplit7'
	'bunny'
]

checkEquality = (dataFromAscii, dataFromBinary, arrayName) ->
	fromAscii = dataFromAscii[arrayName].map (position) -> Math.round position
	fromBinary = dataFromBinary[arrayName].map (position) -> Math.round position

	expect(fromAscii).to.deep.equal(fromBinary)


describe 'Meshlib', () ->
	it 'should return a model object', (done) ->

		meshlib minimalStl, {format: 'stl'}
			.then (model) ->
				expect(model).to.be.an.instanceof Model
			.then ->
				done()
			.catch (error) ->
				done error


describe 'Model Parsing', () ->
	models.forEach (model) ->
		describe model, () ->
			fromAscii = undefined
			fromBinary = undefined

			it 'should load and parse ASCII STL file', (done) ->
				@timeout('8s')

				asciiStlBuffer = fs.readFileSync path.join __dirname,
					'models', model + '.ascii.stl'

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

				binaryStlBuffer = fs.readFileSync path.join __dirname,
					'models', model + '.bin.stl'

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
