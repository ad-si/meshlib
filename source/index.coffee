Model = require './Model'

meshlib = (modelData, options) ->
	return new Model(modelData, options)

meshlib.Model = Model

module.exports = meshlib
