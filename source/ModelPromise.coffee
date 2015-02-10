Stl = require './Stl'
optimizeModel = require './optimizeModel'
Model = require './Model'


class ModelPromise
	constructor: (@mesh, @options) ->
		@ready = Promise.resolve null

		@model = new Model @mesh, @options

		return @model

	#	toStl: (options) ->
	#		options ?= {}
	#		options.encoding ?= 'binary' # ascii
	#		options.type ?= 'buffer' # string

	optimize: () =>
		@ready = @ready.then (model) ->
			return new Promise (fulfill, reject) ->
				try
					optimizeModel @model
				catch error
					return reject error

				fulfill model

		return @ready

	then: (callback) =>
		@ready = @ready
			.then callback
			.then ->
				return @model
		return @ready

	#	then: (onFullfilled, onRejected) =>
	#		return new Promise (resolve, reject) ->
	#			try
	#				value = onFullfilled()
	#				value = onRejected()
	#			catch error
	#				reject error

module.exports = Model
