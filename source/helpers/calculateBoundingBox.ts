export function forFaceVertexMesh (
  faceVertexMesh: { vertexCoordinates: number[] },
) {
  if (
    !faceVertexMesh ||
    !faceVertexMesh.vertexCoordinates ||
    faceVertexMesh.vertexCoordinates.length < 3
  ) {
    console.warn(
      "Cannot calculate bounding box for invalid/empty face-vertex mesh."
    )
    return undefined
  }

  let maxX: number, maxY: number, maxZ: number;
  let minX = (maxX = faceVertexMesh.vertexCoordinates[0]);
  let minY = (maxY = faceVertexMesh.vertexCoordinates[1]);
  let minZ = (maxZ = faceVertexMesh.vertexCoordinates[2]);

  for (let i = 0, end = faceVertexMesh.vertexCoordinates.length - 1; i <= end; i += 3) {
    if (faceVertexMesh.vertexCoordinates[i] < minX) {
      minX = faceVertexMesh.vertexCoordinates[i];
    } else if (faceVertexMesh.vertexCoordinates[i] > maxX) {
      maxX = faceVertexMesh.vertexCoordinates[i];
    }

    if (faceVertexMesh.vertexCoordinates[i + 1] < minY) {
      minY = faceVertexMesh.vertexCoordinates[i + 1];
    } else if (faceVertexMesh.vertexCoordinates[i + 1] > maxY) {
      maxY = faceVertexMesh.vertexCoordinates[i + 1];
    }

    if (faceVertexMesh.vertexCoordinates[i + 2] < minZ) {
      minZ = faceVertexMesh.vertexCoordinates[i + 2];
    } else if (faceVertexMesh.vertexCoordinates[i + 2] > maxZ) {
      maxZ = faceVertexMesh.vertexCoordinates[i + 2];
    }
  }

  return {
    min: {
      x: minX,
      y: minY,
      z: minZ
    },
    max: {
      x: maxX,
      y: maxY,
      z: maxZ
    }
  };
};

export function forFaces (
  faces: { vertices: { x: number; y: number; z: number }[] }[]
) {
  if (
    !faces ||
    faces.length === 0 ||
    !faces[0] ||
    !faces[0].vertices ||
    faces[0].vertices.length === 0
  ) {
    console.warn(
      "Cannot calculate bounding box for invalid/empty faces array."
    )
    return undefined
  }

  let maxX: number, maxY: number, maxZ: number
  let minX = (maxX = faces[0].vertices[0].x);
  let minY = (maxY = faces[0].vertices[0].y);
  let minZ = (maxZ = faces[0].vertices[0].z);

  faces.forEach(face => face.vertices.forEach(function(vertex) {
        if (vertex.x < minX) {
            minX = vertex.x;
        } else if (vertex.x > maxX) {
            maxX = vertex.x;
        }

        if (vertex.y < minY) {
            minY = vertex.y;
        } else if (vertex.y > maxY) {
            maxY = vertex.y;
        }

        if (vertex.z < minZ) {
            minZ = vertex.z
        } else if (vertex.z > maxZ) {
            maxZ = vertex.z
        }
    }));

  return {
    min: {
      x: minX,
      y: minY,
      z: minZ
    },
    max: {
      x: maxX,
      y: maxY,
      z: maxZ
    }
  };
};
