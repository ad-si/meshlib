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

	buildFaceVertexMesh: =>
		@ready = @ready.then =>
			return new Promise (fulfill, reject) =>
				try
					@model = @model.buildFaceVertexMesh()
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

	getSubmodels: () =>
		@ready = @ready.then =>
			return new Promise (fulfill, reject) =>
				try
					models = @model.getSubmodels()
				catch error
					return reject error

				fulfill models
		return @ready

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
