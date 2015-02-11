Stl = require './Stl'
optimizeModel = require './optimizeModel'
Model = require './Model'


class ModelPromise
	constructor: (@mesh, @options) ->
		@ready = new Promise (fulfill, reject) ->
			try
				@model = new Model @mesh, @options
			catch error
				reject error

			fulfill @model
		return @

	optimize: () =>
		@ready = @ready.then ->
			return new Promise (fulfill, reject) ->
				try
					@model = @model.optimize()
				catch error
					return reject error

				fulfill @model
		return @

	thenDo: (callback) =>
		@ready = @ready
			.then () ->
				return callback @model
		return @

	then: (callback) =>
		@ready = @ready.then ->
			return callback @model
		return @ready

module.exports = ModelPromise
