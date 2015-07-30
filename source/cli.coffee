fs = require('fs')
path = require('path')
program = require('commander')
ndjson = require('ndjson')
meshlib = require('../build/index')
packageData = require('../package.json')
yaml = require('js-yaml')
indent = '\n\t\t\t      '


isNumber = (obj) ->
	!isNaN(parseFloat(obj))

processModel = (model) ->

	modelChain = model
	indent = null

	if program.transform
		program.transform.forEach (transformation) ->
			modelChain = modelChain[transformation.type]( sp
				transformation.values
			)

	if program.rotate
		modelChain = modelChain.rotate {
			angle: program.rotate
			unit: 'degree'
		}

	if program.translate
		modelChain = modelChain.translate program.translate

	if program.applyMatrix
		listMatrix = program
			.applyMatrix
			.split /\s/
			.map Number
			.filter Boolean

		matrix = [
			listMatrix.slice 0, 4
			listMatrix.slice 4, 8
			listMatrix.slice 8, 12
			listMatrix.slice 12, 16
		]
		modelChain = modelChain.applyMatrix(matrix)

	if program.buildFaceVertexMesh
		modelChain = modelChain.buildFaceVertexMesh()

	if program.applyGridAlignRotation
		modelChain = modelChain
			.calculateNormals()
			.applyGridAlignRotation()
			.calculateNormals()

	if program.center
		modelChain = modelChain.center()

	if program.applyGridAlignTranslation
		modelChain = modelChain
			.calculateNormals()
			.applyGridAlignTranslation()

	if program.autoAlign
		modelChain = modelChain
			.calculateNormals()
			.autoAlign()

	if program.gridAlignRotationAngle
		modelChain = modelChain
			.calculateNormals()
			.getGridAlignRotationAngle unit: 'degree'
			.then console.log

	else if program.gridAlignRotationMatrix
		modelChain = modelChain
			.calculateNormals()
			.getGridAlignRotationMatrix()
			.then console.log

	else if program.gridAlignTranslation
		modelChain = modelChain
			.calculateNormals()
			.getGridAlignTranslationMatrix()
			.then console.log

	else if program.centeringMatrix
		modelChain = modelChain
			.getCenteringMatrix()
			.then console.log

	else if program.autoAlignMatrix
		modelChain = modelChain
			.calculateNormals()
			.getAutoAlignMatrix()
			.then console.log

	else if program.jsonl
		modelChain = modelChain
			.getStream()
			.then (modelStream) ->
				modelStream.pipe process.stdout

	else if process.stdout.isTTY and !program.json
		modelChain = modelChain
			.getObject()
			.then (modelObject) ->
				console.dir modelObject, {
					depth: Number(program.depth) or null
					colors: program.colors
				}

	else
		if program.indent is true
			indent = 2

		else if isNumber(program.indent)
			indent = Number(program.indent)

		else if program.indent
			indent = program.indent

		modelChain = modelChain
			.getJSON null, indent
			.then console.log

	modelChain = modelChain
		.catch (error) ->
			console.error error.stack


module.exports = (commandLineArguments) ->

	program
		.version(packageData.version)
		.description(packageData.description)
		.option( '--indent [n]', 'Indent JSON output with n (default: 2) spaces
			or a specified string')
		.option('--no-colors', 'Do not color terminal output')
		.option('--depth <levels>', 'Set depth for printing Javascript objects')
		.option('--json', 'Print model as JSON (default for non TTY environments)')
		.option('--jsonl', 'Print model as a newline seperated JSON stream (jsonl)')
		.option(
			'--translate <"x y z">',
			'Translate model in x, y, z direction',
			(string) ->
				string
					.split(' ')
					.map (numberString) ->
						Number numberString
		)
		.option(
			'--rotate <angleInDegrees>',
			'Rotate model <angleInDegrees>˚ around 0,0'
		)
		.option(
			'--transform <transformations>'
			'Transform model with translate(x y z),
			rotate(angleInDegrees) & scale(x y)',
			(string) ->
				string
					.split(')')
					.slice(0, -1)
					.map (transformationString) ->
						subStrings = transformationString.split('(')
						transformation = subStrings[0].trim()
						values = subStrings[1].split(' ')

						if transformation is 'rotate'
							values =
								angle: values
								unit: 'degree'

						return {
							type: transformation
							values: values
						}
		)
		.option(
			'--apply-matrix <matrix>'
			'Applies 4x4 matrix (provided as list of 16 row-major values)'
		)
		.option(
			'--build-face-vertex-mesh'
			'Build a face vertex mesh from faces'
		)
		.option(
			'--centering-matrix'
			'Print matrix to center object in x and y direction'
		)
		.option(
			'--center'
			'Center model in x and y direction'
		)
		.option(
			'--grid-align-rotation-angle'
			'Print dominant rotation angle relative to cartesian grid'
		)
		.option(
			'--grid-align-rotation-matrix'
			'Print rotation matrix which would align model to cartesian grid'
		)
		.option(
			'--apply-grid-align-rotation'
			'Rotate model with its dominant rotation angle
			relative to the cartesian grid
			in order to align it to the cartesian grid'
		)
		.option(
			'--grid-align-translation'
			'Print translation matrix to align model to the cartesian grid'
		)
		.option(
			'--apply-grid-align-translation'
			'Align model to the cartesian grid by translating it
			in x and y direction'
		)
		.option(
			'--auto-align-matrix'
			'Print transformation matrix to rotate, center and align a model
			to the cartesian grid'
		)
		.option(
			'--auto-align'
			'Automatically rotate, center and align model to the cartesian grid'
		)
		.usage '<input-file> [options] [output-file]'
		.parse commandLineArguments


	if process.stdin.isTTY
		if program.args.length < 2
			program.help()

		else
			fs.readFile program.args[0], (error, fileBuffer) ->
				if error
					throw error

				fileContent =
					if /.*(yaml|yml)$/gi.test(program.args[0])
					then yaml.safeLoad(fileBuffer)
					else JSON.parse(fileBuffer)

				meshlib.Model
					.fromObject(fileContent)
					.getObject()
					.then (model) ->
						outputFilePath = path.join(
							process.cwd()
							program.args.pop()
						)

						fs.writeFileSync outputFilePath, JSON.stringify(model)
						process.exit 0

					.catch (error) ->
						console.error error.stack

	else
		modelBuilder = new meshlib.ModelBuilder()

		modelBuilder
			.on 'model', processModel
			.on 'error', (error) ->
				console.error error.stack
				process.exit 1

		process.stdin.setEncoding 'utf-8'
		process.stdin
			.pipe ndjson.parse()
			.pipe modelBuilder
