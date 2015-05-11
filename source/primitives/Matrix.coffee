getArray = ({dimensions, initialValue} = {}) ->
	unless dimensions.length
		return initialValue

	array = []
	subDimensions = dimensions.slice(1)
	index = 0

	while index < dimensions[0]
		array.push getArray {
			dimensions: subDimensions
			initialValue: initialValue
		}
		index++

	return array

multiply = (rows, multiplyRows) ->
	numberOfColums = multiplyRows[0].length

	resultRows = getArray {
		dimensions: [rows.length, numberOfColums]
		initialValue: 0
	}

	rows.forEach (row, rowIndex) ->
		row.forEach (value, valueIndex) ->
			for multiplyValueIndex in [0...numberOfColums]
				resultRows[rowIndex][multiplyValueIndex] +=
					value * multiplyRows[valueIndex][multiplyValueIndex]

	return resultRows


class Matrix
	@fromValues: (values) ->
		numberOfRows = numberOfColums = Math.sqrt values.length
		rows = getArray {dimensions: [numberOfRows, numberOfColums]}

		for rowIndex in [0...numberOfRows]
			for columIndex in [0...numberOfColums]
				rows[rowIndex][columIndex] =
					values[(rowIndex * numberOfColums) + columIndex]

		return new Matrix().setRows rows

	@fromRows: (rows) ->
		return new Matrix().setRows rows

	@fromColums: (colums) ->
		@rows = new Array colums[0].length

		colums.forEach (colum) =>
			colum.forEach (value, valueIndex) =>
				@rows[valueIndex] ?= []
				@rows[valueIndex].push value

		return new Matrix().setRows @rows


	@multiply: (matrixA, matrixB) ->
		return multiply matrixA, matrixB


	setRows: (rows) =>
		@rows = rows
		return @

	toRows: () =>
		return @rows

	multiply: (rows) =>
		return multiply @rows, rows

	multiplyVector: (vector = {}) =>
		array = [vector.x, vector.y, vector.z]

		return @multiply



module.exports = Matrix
