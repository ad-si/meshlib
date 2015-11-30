yaml = require 'js-yaml'
path = require 'path'
fs = require 'fs'

loadYaml = (path) ->
	return yaml.safeLoad fs.readFileSync path

generateMap = (collection) ->
	return collection.reduce (previous, current, index) ->
		previous[current.name] = models[index]
		return previous
	, {}


models = [
	'cube'
	'tetrahedron'
	'tetrahedronIrregular'
	'tetrahedron-normal-first'
	'tetrahedrons'
	'missingFace'
].map (model) ->
	return {
	name: model
	filePath: path.join(
		__dirname, '/', model + '.yaml'
	)
	load: -> loadYaml @filePath
	}

modelsMap = generateMap models

module.exports = modelsMap
