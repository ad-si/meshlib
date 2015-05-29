fastClone = (object) ->
	# Handle string, int, boolean, null or undefined
	if object == null or typeof object != 'object'
		return object

	if Array.isArray object
		arrayClone = []

		for index in [0...object.length]
			arrayClone[index] = fastClone object[index]

		return arrayClone


	if object instanceof Object
		objectClone = {}

		for key, value of object
			objectClone[key] = fastClone value

		return objectClone

	throw new Error 'Unable to copy object! Its type is not supported.'


module.exports = fastClone
