function atob (str) {
  if (Buffer) {
    return new Buffer.from(str, 'base64').toString('binary');
  } else if (window) {
    return window.atob(str);
  } else {
    throw Error('Can not convert ascii to binary in this environment!');
  }
};

function base64ByteLength (base64Length) {
  return (base64Length / 4) * 3
}


function base64ToArray (b64) {
  const numFloats = (base64ByteLength(b64.length)) / 4;
  const result = [];
  const decoded = stringToUint8Array(atob(b64));
  const pview = new DataView(decoded.buffer);
  for (let i = 0, end = numFloats - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
    result[i] = pview.getFloat32(i * 4, true);
  }
  return result;
};

// function base64ToFloat32Array (b64) {
//  const numFloats = (base64ByteLength(b64.length)) / 4;
//  const result = new Float32Array(numFloats);
//  const decoded = stringToUint8Array(atob(b64));
//  const pview = new DataView(decoded.buffer);
//  for (let i = 0, end = numFloats - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
//    result[i] = pview.getFloat32(i * 4, true);
//  }
//  return result;
// };

function base64ToInt32Array(b64) {
  const numInts = (base64ByteLength(b64.length)) / 4;
  const result = new Int32Array(numInts);
  const decoded = stringToUint8Array(atob(b64));
  const pview = new DataView(decoded.buffer);
  for (let i = 0, end = numInts - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
    result[i] = pview.getInt32(i * 4, true);
  }
  return result;
};

function stringToUint8Array(str) {
  const ab = new ArrayBuffer(str.length);
  const uintarray = new Uint8Array(ab);
  for (let i = 0, end = str.length - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
    uintarray[i] = str.charCodeAt(i);
  }
  return uintarray;
};

export default function (base64String) {
  const strArray = base64String.split('|');

  return {
  faceVertexMesh: {
    vertexCoordinates: base64ToArray(strArray[0]),
    faceVertexIndices: Array.prototype.slice.call(
      base64ToInt32Array(strArray[1])
    ),
    vertexNormalCoordinates: base64ToArray(strArray[2]),
    faceNormalCoordinates: base64ToArray(strArray[3])
  },
  name: strArray[4]
  };
};
