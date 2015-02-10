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
			@_obj instanceof Model,
			'expected #{this} to be a Model',
			'expected #{this} to not be a Model'
		)
