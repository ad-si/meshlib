fs = require 'fs'
path = require 'path'
chai = require 'chai'

stlImporter = require '../src/index'

chai.use require 'chai-as-promised'
expect = chai.expect

models = [
	'polytopes/triangle'
	'polytopes/tetrahedron'
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
		asciiStl = fs.readFileSync modelsMap['polytopes/tetrahedron'].asciiPath

		return expect(stlImporter asciiStl).to.eventually
			.have.property('polygons').that.is.an('array')


	it 'should fix faces with 4 or more vertices', ->
		asciiStl = fs.readFileSync modelsMap['broken/fourVertices'].asciiPath

		promise = stlImporter asciiStl
			.catch (error) -> console.error error

		return expect(promise).to.eventually.be.a.triangleMesh


	it.skip 'should fix faces with 2 or less vertices', ->
		asciiStl = fs.readFileSync modelsMap['broken/twoVertices'].asciiPath

		modelPromise = meshlib asciiStl, {format: 'stl'}
			.fixFaces()
			.done (model) -> model

		return expect(modelPromise).to.eventually.be.a.triangleMesh


	it.skip 'ascii & binary version should have equal faces', () ->
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
			expect(models[0].mesh.faces).to
			.equalFaces(models[1].mesh.faces)
