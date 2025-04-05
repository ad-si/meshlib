export default function(face, projection) {
  if (projection == null) { projection = 'xy'; }
  if ((projection === 'xy') || (projection === 'yx')) {
    return {
    x: (face.vertices[0].x + face.vertices[1].x + face.vertices[2].x) / 3,
    y: (face.vertices[0].y + face.vertices[1].y + face.vertices[2].y) / 3
    };
  }
};
