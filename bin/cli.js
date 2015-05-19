#! /usr/bin/env node

var fs = require('fs'),
	path = require('path'),
	program = require('commander'),
	ndjson = require('ndjson'),


	meshlib = require('../build/index'),
	packageData = require('../package.json'),
	yaml = require('js-yaml'),
	indent = '\n\t\t\t      '


function isNumber (obj) {
	return !isNaN(parseFloat(obj))
}

program
	.version(packageData.version)
	.description(packageData.description)
	.option(
	'--indent [n]',
	'Indent JSON output with n (default: 2) spaces or a specified string')
	.option('--no-colors', 'Do not color terminal output')
	.option('--depth <levels>', 'Set depth for printing Javascript objects')
	.option('--jsonl', 'Print model as a newline seperated JSON stream (jsonl)')

	.option('--build-face-vertex-mesh', 'Build a face vertex mesh from faces')
	.option('--translate <"x y z">', 'Translate model in x, y, z direction',
	function (value) {
		return value
			.split(' ')
			.map(function (numberString) {
				return Number(numberString)
			})
	})

	.usage('<input-file> [options] <output-file>')
	.parse(process.argv)


if (process.stdin.isTTY) {

	if (program.args.length < 2)
		program.help()

	else {
		fs.readFile(program.args[0], function (error, fileBuffer) {

			var fileContent

			if (error)
				throw error

			if (/.*(yaml|yml)$/gi.test(program.args[0]))
				fileContent = yaml.safeLoad(fileBuffer)
			else
				fileContent = JSON.parse(fileBuffer)


			meshlib.Model
				.fromObject(fileContent)
				.getObject()
				.then(function (model) {

					var outputFilePath = path.join(
						process.cwd(),
						program.args.pop()
					)

					fs.writeFileSync(outputFilePath, JSON.stringify(model))
					process.exit(0)
				})
				.catch(function (error) {
					console.error(error.stack)
				})
		})
	}
}
else {
	var modelBuilder = new meshlib.ModelBuilder()

	modelBuilder.on('model', function (model) {

		var modelChain = model

		if (program.translate)
			modelChain = modelChain.translate(program.translate)

		if (program.buildFaceVertexMesh)
			modelChain = modelChain.buildFaceVertexMesh()


		if (program.jsonl) {
			modelChain = modelChain
				.getStream()
				.then(function (modelStream) {
					modelStream.pipe(process.stdout)
				})
		}

		else if (process.stdout.isTTY) {
			modelChain = modelChain
				.getObject()
				.then(function (modelObject) {
					console.dir(modelObject, {
						depth: Number(program.depth) || null,
						colors: program.colors
					})
				})
		}

		else {
			modelChain = modelChain
				.getObject()
				.then(function (modelObject) {

					var indent

					if (program.indent === true)
						indent = 2

					else if (isNumber(program.indent))
						indent = Number(program.indent)

					else if (program.indent)
						indent = program.indent

					else
						indent = null

					console.log(
						JSON.stringify(
							modelObject,
							null,
							indent
						)
					)
				})
		}

		modelChain = modelChain
			.catch(function (error) {
				console.error(error.stack)
			})
	})

	modelBuilder.on('error', function (error) {
		console.error(error.stack)
		process.exit(1)
	})

	process.stdin.setEncoding('utf-8')
	process.stdin
		.pipe(ndjson.parse())
		.pipe(modelBuilder)
}
