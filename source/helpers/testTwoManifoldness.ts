import { forEachEdge } from './FaceVertexMeshTraversion.js'

export default function(faceVertexMesh) {
  const edgeCountMap = {};

  forEachEdge(faceVertexMesh, function(v1, v2) {
    const a = Math.min(v1, v2);
    const b = Math.max(v1, v2);
    const key = a + '-' + b;
    if (edgeCountMap[key] == null) { edgeCountMap[key] = 0; }
    return edgeCountMap[key]++;
  });

  for (var edge in edgeCountMap) {
    var count = edgeCountMap[edge];
    if (count !== 2) { return false; }
  }

  return true;
};
