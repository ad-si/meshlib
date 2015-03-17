NoFacesError = (message) ->
	this.name = 'NoFacesError'
	this.message = message or
		'No faces available. Make sure to generate them first.'
NoFacesError.prototype = new Error

module.exports = NoFacesError
