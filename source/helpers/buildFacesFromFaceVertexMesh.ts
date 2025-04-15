interface FaceVertexMesh {
  faceVertexIndices: number[];
  faceNormalCoordinates: number[];
  vertexCoordinates: number[];
}

interface Vertex {
  x: number;
  y: number;
  z: number;
}

interface Face {
  normal: Vertex;
  vertices: Vertex[];
}

export default function(mesh: FaceVertexMesh): Face[] {
  if (!mesh || !mesh.faceVertexIndices || !mesh.faceNormalCoordinates || !mesh.vertexCoordinates) {
    console.warn("Invalid face-vertex mesh provided to buildFacesFromFaceVertexMesh");
    return [];
  }
  
  const {faceVertexIndices, faceNormalCoordinates, vertexCoordinates} = mesh;
  
  const result: Face[] = [];
  for (let i = 0, end = faceVertexIndices.length; i < end; i += 3) {
    // Ensure all indices are valid
    if (i + 2 >= faceVertexIndices.length || i + 2 >= faceNormalCoordinates.length) {
      continue; // Skip this face if indices are out of bounds
    }
    
    // Create vertices array for this face
    const vertices: Vertex[] = [];
    for (let j = 0; j < 3; j++) {
      const vertexIndex = faceVertexIndices[i + j];
      const coordIndex = vertexIndex * 3;
      
      // Check if vertex coordinates are valid
      if (coordIndex + 2 >= vertexCoordinates.length) {
        continue; // Skip this vertex if indices are out of bounds
      }
      
      vertices.push({
        x: vertexCoordinates[coordIndex],
        y: vertexCoordinates[coordIndex + 1],
        z: vertexCoordinates[coordIndex + 2]
      });
    }
    
    // Only add face if it has all 3 vertices
    if (vertices.length === 3) {
      result.push({
        normal: {
          x: faceNormalCoordinates[i],
          y: faceNormalCoordinates[i + 1],
          z: faceNormalCoordinates[i + 2]
        },
        vertices: vertices
      });
    }
  }
  
  return result;
};
