Model = require '../source/Model'

module.exports = (chai, utils) ->
	chai.Assertion.addProperty 'model', () ->
		@assert(
			@_obj instanceof Model,
			'expected #{this} to be a Model',
			'expected #{this} to not be a Model'
		)

	chai.Assertion.addProperty 'optimized', () ->

		@assert(
			@_obj.mesh.hasOwnProperty 'indices'
			'expected #{this} to have indices',
			'expected #{this} to not have indices'
		)
		@assert(
			@_obj.mesh.hasOwnProperty 'positions'
			'expected #{this} to have positions',
			'expected #{this} to not have positions'
		)
		@assert(
			@_obj.mesh.hasOwnProperty 'vertexNormals'
			'expected #{this} to have vertexNormals',
			'expected #{this} to not have vertexNormals'
		)
		@assert(
			@_obj.mesh.hasOwnProperty 'faceNormals'
			'expected #{this} to have faceNormals',
			'expected #{this} to not have faceNormals'
		)
