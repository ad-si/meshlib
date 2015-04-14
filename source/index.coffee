Model = require './Model'
ModelBuilder = require './ModelBuilder'

meshlib = (modelData, options) ->
	return new Model(modelData, options)

meshlib.Model = Model

meshlib.ModelBuilder = ModelBuilder

module.exports = meshlib
