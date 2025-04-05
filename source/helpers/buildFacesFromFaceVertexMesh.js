export default function(mesh) {
  const {faceVertexIndices, faceNormalCoordinates, vertexCoordinates} = mesh;

  return (() => {
    const result = [];
    for (var i = 0, end = faceVertexIndices.length; i < end; i += 3) {
      result.push({
        normal: {
          x: faceNormalCoordinates[i],
          y: faceNormalCoordinates[i + 1],
          z: faceNormalCoordinates[i + 2]
        },

        vertices: [0, 1, 2].map((j) => ({
          x: vertexCoordinates[faceVertexIndices[i + j] * 3],
          y: vertexCoordinates[(faceVertexIndices[i + j] * 3) + 1],
          z: vertexCoordinates[(faceVertexIndices[i + j] * 3) + 2]
        }))
      });
    }
    return result;
  })();
};
