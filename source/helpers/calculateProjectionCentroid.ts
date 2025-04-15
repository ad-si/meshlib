export default function(
  face: { vertices: {
    x: number
    y: number
    z: number
  }[] },
  projection = 'xy',
): { x: number; y: number } {
  if ((projection === 'xy') || (projection === 'yx')) {
    return {
      x: (face.vertices[0].x + face.vertices[1].x + face.vertices[2].x) / 3,
      y: (face.vertices[0].y + face.vertices[1].y + face.vertices[2].y) / 3,
    }
  }
  // TODO: Add other projections
  return { x: 0, y: 0 }
}
