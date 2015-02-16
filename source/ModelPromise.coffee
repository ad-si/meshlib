Stl = require './Stl'
optimizeModel = require './optimizeModel'
Model = require './Model'


class ModelPromise
	constructor: (mesh, options) ->
		@ready = new Promise (fulfill, reject) =>
			try
				@model = new Model mesh, options
			catch error
				reject error

			fulfill @model
		return @

	setPolygons: (polygons) =>
		@ready = @ready.then =>
			new Promise (fulfill, reject) =>
				try
					@model.setPolygons(polygons)
				catch error
					reject error

				fulfill @model
		return @

	optimize: =>
		@ready = @ready.then =>
			return new Promise (fulfill, reject) =>
				try
					@model = @model.optimize()
				catch error
					return reject error

				fulfill @model
		return @

	fixFaces: =>
		@ready = @ready.then =>
			return new Promise (fulfill, reject) =>
				try
					@model = @model.fixFaces()
				catch error
					return reject error

				fulfill @model
		return @

	next: (onFulfilled, onRejected) =>
		@done onFulfilled, onRejected
		return @

	done: (onFulfilled, onRejected) =>
		onFulfilledTemp = => onFulfilled? @model
		@ready = @ready.then onFulfilledTemp, onRejected
		return @ready

	catch: (onRejected) =>
		@ready = @ready.catch onRejected
		return @ready

module.exports = ModelPromise
