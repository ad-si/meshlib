ModelPromise = require './ModelPromise'

meshlib = (modelData, options) ->
	return new ModelPromise(modelData, options)

module.exports = meshlib
