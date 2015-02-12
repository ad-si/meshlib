fs = require 'fs'
path = require 'path'
chai = require 'chai'

Model = require '../source/Model'
meshlib = require '../source/index'

chai.use require './chaiHelper'
chai.use require 'chai-as-promised'
expect = chai.expect


mediumStl = fs.readFileSync(
	path.join(__dirname, './models/gearwheel.ascii.stl'), {encoding: 'utf-8'}
)

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


describe.only 'Meshlib', ->
	it 'should return a model object', () ->
		return expect(meshlib minimalStl, {format: 'stl'})
			.to.eventually.be.a.model

	it 'should be optimizable', ->
		modelPromise = meshlib(mediumStl, {format: 'stl'}).optimize()
		return expect(modelPromise).to.eventually.be.optimized

	it 'should be optimizable', ->
		modelPromise = meshlib(mediumStl, {format: 'stl'}).optimize()
		return expect(modelPromise).to.eventually.be.optimized


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
