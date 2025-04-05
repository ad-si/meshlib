export function forEachEdge (faceVertexMesh, callback) {
  const {
        faceVertexIndices
    } = faceVertexMesh;

  return (() => {
    const result = [];
    for (let index = 0, end = faceVertexIndices.length; index < end; index += 3) {
      var v1 = faceVertexIndices[index];
      var v2 = faceVertexIndices[index + 1];
      var v3 = faceVertexIndices[index + 2];

      callback(v1, v2);
      callback(v2, v3);
      result.push(callback(v3, v1));
    }
    return result;
  })();
}
