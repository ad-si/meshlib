fs = require 'fs'
path = require 'path'
expect = require('chai').expect

meshlib = require '../source/index'


models = [
	'unitCube'
	'gearwheel'
	'bunny'
]

checkEquality = (dataFromAscii, dataFromBinary, arrayName) ->
	fromAscii = dataFromAscii[arrayName].map (position) -> Math.round position
	fromBinary = dataFromBinary[arrayName].map (position) -> Math.round position

	expect(fromAscii).to.deep.equal(fromBinary)


describe 'Model Parsing', () ->
	models.forEach (model) ->
		describe model, () ->
			fromAscii = undefined
			fromBinary = undefined

			it 'should load and parse ASCII STL file', (done) ->
				@timeout('6s')

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
				@timeout('6s')

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
