require 'string.prototype.startswith'
require 'string.prototype.includes'

textEncoding = require 'text-encoding'

Vector = require '../../../source/Vector'
Polygon = require '../../../source/Polygon'
converters = require '../../../source/converters'
errors = require './errors'
parser = require './parser'


containsKeywords = (stlString) ->
	return stlString.startsWith('solid') and
			stlString.includes('facet') and
			stlString.includes ('vertex')


module.exports = (fileContent, options = {}) ->

	return new Promise (fulfill, reject) =>
		if not fileContent
			return reject new Error 'No file-content was passed!'

		if options.type is 'ascii' or typeof fileContent is 'string'
			if containsKeywords fileContent
				return fulfill parser.ascii fileContent
			else
				return reject new Error 'STL string does not contain all stl-keywords!'
		else
			if options.type is 'binary'
				return fulfill parser.binary fileContent

			# TODO: Remove if branch when textEncoding is fixed under node 0.12
			# https://github.com/inexorabletash/text-encoding/issues/29
			if Buffer
				if Buffer.isBuffer fileContent
					stlString = converters
					.toBuffer(fileContent)
					.toString()
				else
					throw new Error "#{typeof fileContent} is no
						supported data-format!"
			else
				stlString = textEncoding
				.TextDecoder 'utf-8'
				.decode new Uint8Array fileContent

			if containsKeywords stlString
				return fulfill parser.ascii stlString

			fulfill parser.binary fileContent
