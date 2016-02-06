yaml = require 'js-yaml'
path = require 'path'
fs = require 'fs'
yaml = require 'js-yaml'

loadYaml = (path) ->
	return yaml.safeLoad fs.readFileSync path

generateMap = (collection) ->
	return collection.reduce (previous, current, index) ->
		previous[current.name] = models[index]
		return previous
	, {}

modelPathObjects = loadYaml path.join(__dirname, './models.yaml')

models = modelPathObjects.map (modelPathObject) ->
	modelPathObject.filePath = path.join(
		__dirname,
		modelPathObject.path + '.' + modelPathObject.extension
	)
	modelPathObject.load = () -> loadYaml modelPathObject.filePath
	return modelPathObject

modelsMap = generateMap models

module.exports = modelsMap
