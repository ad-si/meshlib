// Calculate the area of the projection of a face in the xy-plane
// http://stackoverflow.com/questions/16285134

export default function(face) {
  const xCoordinates = [
    face.vertices[0].x,
    face.vertices[1].x,
    face.vertices[2].x
  ];
  const yCoordinates = [
    face.vertices[0].y,
    face.vertices[1].y,
    face.vertices[2].y
  ];

  let area = 0;
  let j = xCoordinates.length - 1;

  for (let i = 0, end = yCoordinates.length - 1; i <= end; i++) {
    area += (xCoordinates[j] + xCoordinates[i]) *
      (yCoordinates[j] - yCoordinates[i]);
    j = i;
  }

  return Math.abs(area / 2);
};
