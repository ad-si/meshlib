function calculateLocalitySensitiveHash (point) {
  return point.x + point.y + point.z;
}

function isCloserThan (distance, numberA, numberB) {
  return (numberA - numberB) < distance;
}

export default function(faces, options) {
  if (options == null) { options = {}; }
  const maximumMergeDistance = options.maximumMergeDistance || 0.0001;

  const vertices = [];
  const currentBucket = [];
  let vertexCoordinates = [];
  let faceVertexIndices = [];
  const faceNormalCoordinates = [];
  const maximumIndex = 0;

  const sortedVertices = faces
    .map(function(face, faceIndex) {
      faceNormalCoordinates.push(
        face.normal.x,
        face.normal.y,
        face.normal.z
      );

      face.vertices.forEach(function(vertex, vertexIndex) {
        vertex.hash = calculateLocalitySensitiveHash(vertex);
        vertex.originalFaceIndex = faceIndex;
        return vertex.originalVertexIndex = vertexIndex;
      });
      return face;}).reduce((verticesArray, face) => verticesArray.concat(face.vertices)
      , [])

    // TODO: Insert into Binary tree to get sorted array
    .sort((vertexA, vertexB) => vertexB.hash - vertexA.hash);


  // Iterate over vertices and remove duplicates
  let vertexIndex = 0;
  while (vertexIndex < sortedVertices.length) {
    var currentVertex = sortedVertices[vertexIndex];

    if (currentVertex === null) {
      vertexIndex++;
      continue;
    }

    if ((currentVertex.usedIn == null)) {
      currentVertex.usedIn = [{
        face: currentVertex.originalFaceIndex,
        vertex: currentVertex.originalVertexIndex,
      }];
      delete currentVertex.originalFaceIndex;
      delete currentVertex.originalVertexIndex;
    }

    var lookAheadIndex = vertexIndex + 1;
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
        lookAheadIndex++;
        continue;
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
        });
        sortedVertices[lookAheadIndex] = null;
      }

      lookAheadIndex++;
    }

    vertexIndex++;
  }


  const cleanedVertices = sortedVertices.filter(vertex => vertex != null);

  vertexCoordinates = cleanedVertices.reduce(function(array, vertex) {
      if (vertex != null) {
        array.push(vertex.x, vertex.y, vertex.z);
      }
      return array;
    }
    , []);

  faceVertexIndices =
    cleanedVertices.reduce(function(faceVertexIndices, vertex, vertexIndex) {
      if (vertex != null) {
        vertex.usedIn.forEach(function(vertexReference) {
          const index = (vertexReference.face * 3) + vertexReference.vertex;
          return faceVertexIndices[index] = vertexIndex;
        });
      }
      return faceVertexIndices;
    }
    , []);

  return {
    vertexCoordinates, // vertexCoordinates
    faceVertexIndices, // faceVertexIndices
    faceNormalCoordinates, // faceNormals
    vertexNormalCoordinates: [] // TODO: vertexNormals
  };
};
