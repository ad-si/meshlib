errors = {
	FacetError: (message) ->
		tmp = Error.apply(this, arguments)
		tmp.name = @name = 'FacetError'

		@stack = tmp.stack
		@message = tmp.message or 'Previous facet was not completed!'

	FileError: (message, calcDataLength, dataLength) ->
		tmp = Error.apply(this, arguments)
		tmp.name = @name = 'FileError'

		@stack = tmp.stack
		@message = tmp.message or "Calculated length of #{calcDataLength}
					does not match specified file-size of #{dataLength}.
					Triangles might be missing!"

	NormalError: (message, calcDataLength, dataLength) ->
		tmp = Error.apply(this, arguments)
		tmp.name = @name = 'NormalError'

		@stack = tmp.stack
		@message = tmp.message or "Invalid normal definition:
									(#{nx}, #{ny}, #{nz})"

	VertexError: (message, calcDataLength, dataLength) ->
		tmp = Error.apply(this, arguments)
		tmp.name = @name = 'VertexError'

		@stack = tmp.stack
		@message = tmp.message or "Invalid vertex definition:
									(#{nx}, #{ny}, #{nz})"
}


if global
	scope = global

else if typeof global is 'undefined' and window
	scope = window


for errorName, errorBody of errors
	do () =>
		scope[errorName] = errorBody

		Inheritor = () -> {}
		Inheritor.prototype = Error.prototype
		scope[errorName].prototype = new Inheritor()
