if global
	scope = global

else if typeof global is 'undefined' && window
	scope = window

else
	scope = {}


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


scope.FileError = FileError
scope.FacetError = FacetError
scope.NormalError = NormalError
scope.VertexError = VertexError
