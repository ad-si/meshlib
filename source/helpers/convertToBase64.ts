import { FaceVertexData } from "../ExplicitModel.js"

function arrayBufferToBase64 (buffer: ArrayBuffer): string {
  let binary = ''
  const bytes = new Uint8Array(buffer)
  const len = bytes.byteLength

  for (
    let i = 0,
      end = len - 1,
      asc = 0 <= end;
    asc ? i <= end : i >= end;
    asc ? i++ : i--
  ) {
    binary += String.fromCharCode(bytes[i])
  }

  if (typeof Buffer !== 'undefined') {
    return Buffer.from(binary, 'binary').toString('base64')
  }
  else if (typeof window !== 'undefined') {
    return window.btoa(binary)
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
  const vnA = new Float32Array(vertexNormalCoordinates.length)

  for (
    let i = 0,
      end = vertexNormalCoordinates.length - 1,
      asc = 0 <= end;
    asc ? i <= end : i >= end;
    asc ? i++ : i--
  ) {
    vnA[i] = vertexNormalCoordinates[i]
  }
  const fnA = new Float32Array(faceNormalCoordinates.length)

  for (
    let i = 0,
      end = faceNormalCoordinates.length - 1,
      asc = 0 <= end;
    asc ? i <= end : i >= end;
    asc ? i++ : i--
  ) {
    fnA[i] = faceNormalCoordinates[i]
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
