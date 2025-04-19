function atob (str: string): string {
  if (typeof Buffer !== 'undefined') {
    return Buffer.from(str, 'base64').toString('binary')
  }
  else if (typeof window !== 'undefined') {
    return window.atob(str)
  }
  else {
    throw Error('Can not convert ascii to binary in this environment!')
  }
}


function base64ByteLength (base64Length: number): number {
  return (base64Length / 4) * 3
}


function base64ToArray (b64: string): number[] {
  if (!b64) return []

  const numFloats = (base64ByteLength(b64.length)) / 4
  const result = []
  const decoded = stringToUint8Array(atob(b64))
  const pview = new DataView(decoded.buffer)
  for (let i = 0, end = numFloats - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
    result[i] = pview.getFloat32(i * 4, true)
  }
  return result
}


function base64ToInt32Array(b64: string): Int32Array {
  if (!b64) return new Int32Array(0)

  const numInts = (base64ByteLength(b64.length)) / 4
  const result = new Int32Array(numInts)
  const decoded = stringToUint8Array(atob(b64))
  const pview = new DataView(decoded.buffer)
  for (let i = 0, end = numInts - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
    result[i] = pview.getInt32(i * 4, true)
  }
  return result
}


function stringToUint8Array(str: string): Uint8Array {
  const ab = new ArrayBuffer(str.length)
  const uintarray = new Uint8Array(ab)
  for (let i = 0, end = str.length - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
    uintarray[i] = str.charCodeAt(i)
  }
  return uintarray
}

export default function buildMeshFromBase64(base64String: string): { faceVertexMesh: any; name: string } {
  const strArray = base64String.split('|')

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
  }
}
