expect = require('chai').expect
stlLoader = require('../source/index').stlLoader
fs = require 'fs'
meshlib = require '../source/index'
OptimizedModel = require '../source/OptimizedModel'


describe 'OptimizedMesh', () ->
	before (done) ->
		done()

	describe 'Manifoldness', () ->
		it.skip 'should be two-manifold', (done) ->
			m = loadOptimizedModel('test/models/unitCube.bin.stl')
			expect(m.isTwoManifold()).to.equal(true)
			done()

		it.skip 'should not be two-manifold', (done) ->
			m = loadOptimizedModel('test/models/missingFace.stl')
			expect(m.isTwoManifold()).to.equal(false)
			done()

	describe 'THREE.js integration', () ->
		it 'should import a THREE.Geometry', (done) ->
			loadOptimizedModel 'test/models/unitCube.bin.stl', (model) ->				
				inBetweenGeometry = model.createStandardGeometry()
				model2 = new OptimizedModel()
				model2.fromThreeGeometry(inBetweenGeometry)	

				arrayEquality = (a, b) ->
					if a.length != b.length
						return false
					for i in [0..a.length - 1] by 1
						if a[i] != b[i]
							return false
					return true

				expect(arrayEquality(model.positions, model2.positions)).to.equal(true)
				expect(arrayEquality(model.indices, model2.indices)).to.equal(true)
				done()

	after () ->
		return

loadOptimizedModel = (fileName, callback) ->
	binaryStlBuffer = fs.readFileSync fileName
	meshlib.parse binaryStlBuffer, null, (error, model) ->
		callback(model)