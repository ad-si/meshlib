import { FaceObject, Vertex} from '@datatypes/face'

function calculateLocalitySensitiveHash (point: Vertex) {
  return point.x + point.y + point.z
}

function isCloserThan (
  distance: number,
  numA: number | undefined,
  numB: number | undefined,
): boolean {
  // Ensure both numbers are valid before comparison
  if (typeof numA !== 'number' || typeof numB !== 'number') {
    return false; // Cannot compare if one is not a number
  }
  // Use Math.abs for distance comparison
  return Math.abs(numA - numB) < distance;
}

export default function(
  faces: FaceObject[],
  options: {maximumMergeDistance?: number},
) {
  if (options == null) { options = {}; }
  const maximumMergeDistance = options.maximumMergeDistance || 0.0001
  let vertexCoordinates = []
  let faceVertexIndices = []
  const faceNormalCoordinates = []

  const sortedVertices = faces
    .map(function(face, faceIndex) {
      faceNormalCoordinates.push(
        face.normal.x,
        face.normal.y,
        face.normal.z
      )

      face.vertices
        .forEach((vertex, vertexIndex) => {
          vertex.hash = calculateLocalitySensitiveHash(vertex)
          vertex.originalFaceIndex = faceIndex
          return vertex.originalVertexIndex = vertexIndex
        })

      return face;})
        .reduce((verticesArray, face) => verticesArray.concat(face.vertices)
      , [])

    // TODO: Insert into Binary tree to get sorted array
    .sort((vertexA, vertexB) => vertexB.hash - vertexA.hash)


  // Iterate over vertices and remove duplicates
  let vertexIndex = 0
  while (vertexIndex < sortedVertices.length) {
    var currentVertex = sortedVertices[vertexIndex]

    if (currentVertex === null) {
      vertexIndex++
      continue
    }

    if ((currentVertex.usedIn == null)) {
      currentVertex.usedIn = [{
        face: currentVertex.originalFaceIndex,
        vertex: currentVertex.originalVertexIndex,
      }]
      delete currentVertex.originalFaceIndex
      delete currentVertex.originalVertexIndex
    }

    var lookAheadIndex = vertexIndex + 1
    while(
      (lookAheadIndex <= sortedVertices.length) &&
      ((sortedVertices[lookAheadIndex] === null) ||
      isCloserThan(
        2 * maximumMergeDistance,
        currentVertex.hash,
        sortedVertices[lookAheadIndex] != null ? sortedVertices[lookAheadIndex].hash : undefined
      ))
    ) {
      if (sortedVertices[lookAheadIndex] === null) {
        lookAheadIndex++
        continue
      }

      if (isCloserThan(
          maximumMergeDistance,
          currentVertex.x,
          sortedVertices[lookAheadIndex].x
        ) &&
        isCloserThan(
          maximumMergeDistance,
          currentVertex.y,
          sortedVertices[lookAheadIndex].y
        ) &&
        isCloserThan(
          maximumMergeDistance,
          currentVertex.z,
          sortedVertices[lookAheadIndex].z
        )
      ) {
        currentVertex.usedIn.push({
          face: sortedVertices[lookAheadIndex].originalFaceIndex,
          vertex: sortedVertices[lookAheadIndex].originalVertexIndex,
        })
        sortedVertices[lookAheadIndex] = null
      }

      lookAheadIndex++
    }

    vertexIndex++
  }


  const cleanedVertices = sortedVertices.filter(vertex => vertex != null)

  vertexCoordinates = cleanedVertices.reduce(function(array, vertex) {
      if (vertex != null) {
        array.push(vertex.x, vertex.y, vertex.z)
      }
      return array
    }
    , [])

  faceVertexIndices =
    cleanedVertices.reduce(function(faceVertexIndices, vertex, vertexIndex) {
      if (vertex != null) {
        vertex.usedIn.forEach(function(vertexReference) {
          const index = (vertexReference.face * 3) + vertexReference.vertex
          return faceVertexIndices[index] = vertexIndex
        })
      }
      return faceVertexIndices
    }
    , [])

  // Calculate vertex normals
  // Use the normalized sum of face normals for each vertex (classic vertex normal)
  const vertexNormalCoordinates = new Array(cleanedVertices.length * 3).fill(0)
  const vertexFaceCount = new Array(cleanedVertices.length).fill(0)

  cleanedVertices.forEach((vertex, vIndex) => {
    if (!vertex) return
    vertex.usedIn.forEach(({ face }) => {
      vertexNormalCoordinates[vIndex * 3]     += faceNormalCoordinates[face * 3]
      vertexNormalCoordinates[vIndex * 3 + 1] += faceNormalCoordinates[face * 3 + 1]
      vertexNormalCoordinates[vIndex * 3 + 2] += faceNormalCoordinates[face * 3 + 2]
      vertexFaceCount[vIndex]++
    })
  })

  // Normalize each vertex normal vector
  for (let v = 0; v < cleanedVertices.length; v++) {
    const x = vertexNormalCoordinates[v * 3]
    const y = vertexNormalCoordinates[v * 3 + 1]
    const z = vertexNormalCoordinates[v * 3 + 2]
    const len = Math.sqrt(x * x + y * y + z * z)
    if (len > 0) {
      vertexNormalCoordinates[v * 3]     = x / len
      vertexNormalCoordinates[v * 3 + 1] = y / len
      vertexNormalCoordinates[v * 3 + 2] = z / len
    }
  }

  return {
    vertexCoordinates,
    faceVertexIndices,
    faceNormalCoordinates,
    vertexNormalCoordinates
  }
}
