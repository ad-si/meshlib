Model = require './Model'


class ModelPromise
	constructor: (mesh, options) ->
		@ready = Promise.resolve().then =>
			@model = new Model mesh, options
		return @

	setFaces: (faces) =>
		return @next => @model.setFaces faces

	buildFaceVertexMesh: =>
		return @next => @model.buildFaceVertexMesh()

	fixFaces: =>
		return @next => @model.fixFaces()

	calculateNormals: =>
		return @next => @model.calculateNormals()

	getSubmodels: =>
		return @done => @model.getSubmodels()

	isTwoManifold: =>
		return @done => @model.isTwoManifold()

	getBoundingBox: =>
		return @done => @model.getBoundingBox()

	forEachFace: (callback) =>
		return @next => @model.forEachFace(callback)

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
