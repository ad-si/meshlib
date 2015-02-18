
describe 'STL Exporter', =>
	it.skip 'should export an STL file', () =>

		stlExporter = require('../exporters/stl')

		asciiStl = fs.readFileSync modelsMap['objects/gearwheel'].asciiPath

		return meshlib asciiStl, {format: 'stl'}
		.optimize()
		.done (model) ->
			fs.writeFileSync 'test.stl', stlExporter.toAsciiStl model.mesh
