expect = require('chai').expect
stlLoader = require('../source/index').stlLoader
fs = require 'fs'
meshlib = require '../source/index'
OptimizedModel = require '../source/OptimizedModel'


describe 'OptimizedMesh', () ->

	describe 'THREE.js integration', () ->
		it.skip 'should import a THREE.Geometry', (done) ->
			loadOptimizedModel 'test/models/unitCube.bin.stl', (model) ->
				inBetweenGeometry = model.createStandardGeometry()
				model2 = new OptimizedModel()
				model2.fromThreeGeometry(inBetweenGeometry)

				expect(model.indices).to.deep.equal(model2.indices)
				expect(model.positions).to.deep.equal(model2.positions)

				done()

	after () ->
		return

loadOptimizedModel = (fileName, callback) ->
	binaryStlBuffer = fs.readFileSync fileName
	meshlib.parse binaryStlBuffer, null, (error, model) ->
		callback(model)
