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

	setFaces: (faces) =>
		@ready = @ready.then =>
			new Promise (fulfill, reject) =>
				try
					@model.setFaces(faces)
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

	calculateNormals: =>
		@ready = @ready.then =>
			return new Promise (fulfill, reject) =>
				try
					@model = @model.calculateNormals()
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
