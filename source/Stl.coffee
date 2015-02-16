require 'string.prototype.startswith'
require 'string.prototype.includes'

textEncoding = require 'text-encoding'

Vector = require './Vector'
optimizeModel = require './optimizeModel'
Polygon = require './Polygon'
converters = require './converters'


FileError = (message, calcDataLength, dataLength) ->
	this.name = 'FileError'
	this.message = message or "Calculated length of #{calcDataLength}
					does not match specified file-size of #{dataLength}.
					Triangles might be missing!"
FileError.prototype = new Error

FacetError = (message) ->
	this.name = 'FacetError'
	this.message = message or 'Previous facet was not completed!'
FacetError.prototype = new Error

NormalError = (message) ->
	this.name = 'NormalError'
	this.message = message or "Invalid normal definition: (#{nx}, #{ny}, #{nz})"
NormalError.prototype = new Error

VertexError = (message) ->
	this.name = 'VertexError'
	this.message = message or "Invalid vertex definition: (#{nx}, #{ny}, #{nz})"
VertexError.prototype = new Error




parseAscii = (fileContent) ->
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
					currentPoly.addVertex new Vector(vx, vy, vz)

	return stl

# Parses a binary stl file to the internal representation
parseBinary = (stlBuffer) ->

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


class Ascii

	whitespaces = [' ', '\r', '\n', '\t', '\v', '\f']

	skipWhitespaces = () ->
		skip = true
		while skip
			if (@currentCharIsWhitespace() && !@reachedEnd())
				@index++
			else
				skip = false

	constructor: (fileContent) ->
		@content = fileContent
		@index = 0

	nextText: () ->
		skipWhitespaces.call(@)
		return @readUntilWhitespace()

	currentChar: () ->
		return @content[@index]

	currentCharIsWhitespace: () ->
		for space in whitespaces
			if @currentChar() == space
				return true
		return false

	readUntilWhitespace: () ->
		readContent = ''
		while (!@currentCharIsWhitespace() && !@reachedEnd())
			readContent = readContent + @currentChar()
			@index++
		return readContent

	reachedEnd: () ->
		return (@index == @content.length)


# An unoptimized data structure that holds the same content as a stl file
class Binary
	constructor: () ->
		@polygons = []
		@importErrors = []

	addPolygon: (stlPolygon) ->
		@polygons.push(stlPolygon)

	addError: (string) ->
		@importErrors.push string


class Stl
	constructor: (stl, options) ->

		@modelObject = {}

		options ?= {}
		options.optimize ?= true

		containsKeywords = (stlString) ->
			return stlString.startsWith('solid') and
					stlString.includes('facet') and
					stlString.includes ('vertex')

		if typeof stl is 'string'
			if containsKeywords stl
				@modelObject = parseAscii stl
			else
				throw new Error 'STL string does not contain all stl-keywords!'
		else
			# TODO: Remove if branch when textEncoding is fixed under node 0.12
			# https://github.com/inexorabletash/text-encoding/issues/29
			if Buffer
				stlString = converters
					.toBuffer(stl)
					.toString()
			else
				stlString = textEncoding
					.TextDecoder 'utf-8'
					.decode new Uint8Array stl

			if containsKeywords stlString
				@modelObject = parseAscii stlString
				return

			@modelObject = parseBinary stl

		return @

	model: () ->
		return @modelObject


module.exports = Stl
