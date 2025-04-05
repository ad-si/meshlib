function arrayBufferToBase64 (buffer) {
  let binary = '';
  const bytes = new Uint8Array(buffer);
  const len = bytes.byteLength;
  for (let i = 0, end = len - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
    binary += String.fromCharCode(bytes[i]);
  }

  if (Buffer) {
    return new Buffer.from(binary, 'binary').toString('base64');

  } else if (window) {
    return window.btoa(binary);

  } else {
    throw new Error('Can not convert binary to ascii in this environment!');
  }
};

export default function(mesh) {
  let i;
  let asc, end;
  let asc1, end1;
  let asc2, end2;
  let asc3, end3;
  const {
  vertexCoordinates,
  faceVertexIndices,
  vertexNormalCoordinates,
  faceNormalCoordinates
  } = mesh;

  const posA = new Float32Array(vertexCoordinates.length);

  for (i = 0, end = vertexCoordinates.length - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
    posA[i] = vertexCoordinates[i];
  }
  const indA = new Int32Array(faceVertexIndices.length);

  for (i = 0, end1 = faceVertexIndices.length - 1, asc1 = 0 <= end1; asc1 ? i <= end1 : i >= end1; asc1 ? i++ : i--) {
    indA[i] = faceVertexIndices[i];
  }
  const vnA = new Float32Array(vertexNormalCoordinates.length);

  for (i = 0, end2 = vertexNormalCoordinates.length - 1, asc2 = 0 <= end2; asc2 ? i <= end2 : i >= end2; asc2 ? i++ : i--) {
    vnA[i] = vertexNormalCoordinates[i];
  }
  const fnA = new Float32Array(faceNormalCoordinates.length);

  for (i = 0, end3 = faceNormalCoordinates.length - 1, asc3 = 0 <= end3; asc3 ? i <= end3 : i >= end3; asc3 ? i++ : i--) {
    fnA[i] = faceNormalCoordinates[i];
  }

  const posBase = arrayBufferToBase64(posA.buffer);
  let baseString = posBase;
  baseString += '|';

  const indBase = arrayBufferToBase64(indA.buffer);
  baseString += indBase;
  baseString += '|';

  const vnBase = arrayBufferToBase64(vnA.buffer);
  baseString += vnBase;
  baseString += '|';

  const fnBase = arrayBufferToBase64(fnA.buffer);
  baseString += fnBase;

  return baseString;
};
