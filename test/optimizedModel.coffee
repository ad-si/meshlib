expect = require('chai').expect
stlLoader = require('../source/index').stlLoader
fs = require 'fs'

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
	after () ->
		return

loadOptimizedModel = (fileName) ->
	fileContent = fs.readFileSync fileName, {encoding: 'utf8'}
	optimized = stlLoader.parse fileContent
	return optimized
