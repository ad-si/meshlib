import { FaceVertexData } from "../ExplicitModel.js"

function arrayBufferToBase64 (buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer)

  if (typeof Buffer !== 'undefined') {
    return Buffer.from(bytes).toString('base64')
  }

  if (typeof btoa !== 'undefined') {
    // Convert in chunks, as String.fromCharCode
    // can only handle a limited number of arguments
    const chunks: string[] = []
    const chunkSize = 0x8000
    for (let i = 0; i < bytes.length; i += chunkSize) {
      chunks.push(String.fromCharCode(...bytes.subarray(i, i + chunkSize)))
    }
    return btoa(chunks.join(''))
  }
  else {
    throw new Error('Can not convert binary to ascii in this environment!')
  }
}

export default function convertToBase64(mesh: FaceVertexData): string {
  const {
    vertexCoordinates,
    faceVertexIndices,
    vertexNormalCoordinates,
    faceNormalCoordinates
  } = mesh

  const posA = new Float32Array(vertexCoordinates.length)

  for (
    let i = 0,
      end = vertexCoordinates.length - 1,
      asc = 0 <= end;
    asc ? i <= end : i >= end;
    asc ? i++ : i--
  ) {
    posA[i] = vertexCoordinates[i]
  }
  const indA = new Int32Array(faceVertexIndices.length)

  for (
    let i = 0,
      end1 = faceVertexIndices.length - 1,
      asc1 = 0 <= end1;
    asc1 ? i <= end1 : i >= end1;
    asc1 ? i++ : i--
  ) {
    indA[i] = faceVertexIndices[i]
  }
  const vnA = new Float32Array(vertexNormalCoordinates?.length || 1)

  if (vertexNormalCoordinates?.length) {
    for (
      let i = 0,
        end = vertexNormalCoordinates.length - 1,
        asc = 0 <= end;
      asc ? i <= end : i >= end;
      asc ? i++ : i--
    ) {
      vnA[i] = vertexNormalCoordinates[i]
    }
  }
  else {
    // Add at least one value to prevent empty buffer issues
    vnA[0] = 0
  }

  const fnA = new Float32Array(faceNormalCoordinates?.length || 1)

  if (faceNormalCoordinates?.length) {
    for (
      let i = 0,
        end = faceNormalCoordinates.length - 1,
        asc = 0 <= end;
      asc ? i <= end : i >= end;
      asc ? i++ : i--
    ) {
      fnA[i] = faceNormalCoordinates[i]
    }
  }
  else {
    // Add at least one value to prevent empty buffer issues
    fnA[0] = 0
  }

  const posBase = arrayBufferToBase64(posA.buffer)
  let baseString = posBase
  baseString += '|'

  const indBase = arrayBufferToBase64(indA.buffer)
  baseString += indBase
  baseString += '|'

  const vnBase = arrayBufferToBase64(vnA.buffer)
  baseString += vnBase
  baseString += '|'

  const fnBase = arrayBufferToBase64(fnA.buffer)
  baseString += fnBase

  return baseString
}

// Base64 representation of a named model as returned by `Model.getBase64()`
export function convertModelToBase64 (
  mesh: FaceVertexData,
  name: string,
): string {
  return convertToBase64(mesh) + '|' + name
}
