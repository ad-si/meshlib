Ascii = require './Ascii'
Binary = require './Binary'
Polygon = require './Polygon'
Vector = require './Vector'

module.exports.ascii = (fileContent) ->
	astl = new Ascii(fileContent)
	stl = new Binary()

	currentPoly = null

	while !astl.reachedEnd()
		cmd = astl.nextText()
		cmd = cmd.toLowerCase()

		switch cmd
			when 'solid'
				astl.nextText() #skip description of model

			when 'facet'
				if (currentPoly?)
					throw new FacetError
					stl.addPolygon currentPoly
					currentPoly = null
				currentPoly = new Polygon()

			when 'endfacet'
				if !(currentPoly?)
					throw new FacetError 'Facet was ended without beginning it!'
				else
					stl.addPolygon currentPoly
					currentPoly = null

			when 'normal'
				nx = parseFloat astl.nextText()
				ny = parseFloat astl.nextText()
				nz = parseFloat astl.nextText()

				if (!(nx?) or !(ny?) or !(nz?))
					throw new NormalError
				else
					if not (currentPoly?)
						throw new NormalError 'Normal definition
										without an existing polygon!'
						currentPoly = new Polygon()
					currentPoly.setNormal new Vector(nx, ny, nz)

			when 'vertex'
				vx = parseFloat astl.nextText()
				vy = parseFloat astl.nextText()
				vz = parseFloat astl.nextText()

				if (!(vx?) or !(vy?) or !(vz?))
					throw new VertexError

				else
					if not (currentPoly?)
						throw new VertexError 'Point definition without
												an existing polygon!'
						currentPoly = new Polygon()

					if currentPoly.vertices.length >= 3
						throw new FacetError 'More than 3 vertices per facet!'
					else
						currentPoly.addVertex new Vector(vx, vy, vz)

	return stl


module.exports.binary = (stlBuffer) ->

	stl = new Binary()
	reader = new DataView stlBuffer, 80
	numTriangles = reader.getUint32 0, true

	#check if file size matches with numTriangles
	dataLength = stlBuffer.byteLength - 80 - 4
	polyLength = 50
	calcDataLength = polyLength * numTriangles

	if calcDataLength > dataLength
		throw new FileError null, calcDataLength, dataLength

	binaryIndex = 4
	while (binaryIndex - 4) + polyLength <= dataLength
		poly = new Polygon()
		nx = reader.getFloat32 binaryIndex, true
		binaryIndex += 4
		ny = reader.getFloat32 binaryIndex, true
		binaryIndex += 4
		nz = reader.getFloat32 binaryIndex, true
		binaryIndex += 4
		poly.setNormal new Vector(nx, ny, nz)
		for i in [0..2]
			vx = reader.getFloat32 binaryIndex, true
			binaryIndex += 4
			vy = reader.getFloat32 binaryIndex, true
			binaryIndex += 4
			vz = reader.getFloat32 binaryIndex, true
			binaryIndex += 4
			poly.addVertex new Vector(vx, vy, vz)
		#skip uint 16
		binaryIndex += 2
		stl.addPolygon poly

	return stl
