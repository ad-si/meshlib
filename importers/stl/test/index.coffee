fs = require 'fs'
path = require 'path'
chai = require 'chai'

stlImporter = require '../src/index'

chai.use require 'chai-as-promised'
expect = chai.expect

models = [
	'polytopes/triangle'
	'polytopes/cube'
	'broken/fourVertices'
	'broken/twoVertices'
	'broken/wrongNormals'
	'objects/gearwheel'
	'objects/bunny'
].map (model) ->
	return {
		name: model
		asciiPath: path.resolve(
			__dirname, '../node_modules/stl-models/', model + '.ascii.stl'
		)
		binaryPath: path.resolve(
			__dirname, '../node_modules/stl-models/', model + '.bin.stl'
		)
	}

modelsMap = models.reduce (previous, current, index) ->
	previous[current.name] = models[index]
	return previous
, {}


describe 'STL Importer', ->
	it 'should return an array of faces', ->
		asciiStl = fs.readFileSync modelsMap['polytopes/triangle'].asciiPath

		return expect(stlImporter asciiStl).to.eventually
			.have.property('polygons').that.is.an('array')
