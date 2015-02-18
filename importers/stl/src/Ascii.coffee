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

module.exports = Ascii
