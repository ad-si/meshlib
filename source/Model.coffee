ExplicitModel = require './ExplicitModel'


class Model
	constructor: (mesh, options) ->
		@ready = Promise.resolve().then =>
			if mesh
				@model = new ExplicitModel mesh, options
		return @

	@fromObject: (object, options) =>
		return new Model object.mesh, options
		.setName object.name
		.setFileName object.fileName
		.setFaceCount object.faceCount

	@fromFaces: (faces, options) =>
		return new Model {mesh: {faces: faces}}, options

	@fromBase64: (base64String) =>
		exportModel = new Model()
		exportModel.model = ExplicitModel.fromBase64 base64String
		return exportModel

	setName: (name) =>
		return @next => @model.name = name

	setFileName: (fileName) =>
		return @next => @model.fileName = fileName

	setFaces: (faces) =>
		return @next => @model.setFaces faces

	setFaceCount: (numberOfFaces) =>
		return @next => @model.faceCount = numberOfFaces

	getFaceVertexMesh: =>
		return @done => @model.mesh.faceVertex

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
		return @next => @model.forEachFace callback

	getBase64: () =>
		return @done => @model.getBase64()

	getJSON: () =>
		return @done => JSON.stringify @model

	getObject: () =>
		return @done => @model.toObject()

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

module.exports = Model
