import { FaceObject } from '@datatypes/face'

import type { FaceVertexData } from '../ExplicitModel.js'

export interface BuildFaceVertexMeshOptions {
  // Vertices closer than this distance (on every axis) are merged
  maximumMergeDistance?: number
}

// Spatial hash over integer grid cells
const hashCell = (ix: number, iy: number, iz: number): number =>
  Math.imul(ix, 73856093) ^ Math.imul(iy, 19349663) ^ Math.imul(iz, 83492791)


/**
 * Merges the vertices of a triangle soup into a face-vertex mesh.
 *
 * `triangleCoordinates` contains 9 values (3 vertices × x, y, z) per face and
 * `faceNormalCoordinates` 3 values per face.
 *
 * A vertex is merged into the first previously seen vertex
 * which is closer than `maximumMergeDistance` on every axis.
 * Vertices are therefore ordered by their first occurrence.
 *
 * Runs in linear time by bucketing vertices into grid cells
 * which are twice as large as the merge distance.
 * A matching vertex must then lie either in the vertex's own cell
 * or in the neighboring cell on the side the vertex is closer to,
 * so only 2 × 2 × 2 cells must be searched.
 */
export function buildFaceVertexMeshFromTriangles (
  triangleCoordinates: ArrayLike<number>,
  faceNormalCoordinates: ArrayLike<number>,
  options: BuildFaceVertexMeshOptions = {},
): FaceVertexData {
  const maximumMergeDistance = options.maximumMergeDistance || 0.0001
  const cellSize = 2 * maximumMergeDistance
  const faceCount = Math.floor(triangleCoordinates.length / 9)

  const vertexCoordinates: number[] = []
  const faceVertexIndices: number[] = new Array(faceCount * 3)
  const buckets = new Map<number, number[]>()

  const isCloseTo = (index: number, x: number, y: number, z: number) =>
    Math.abs(vertexCoordinates[index * 3] - x) < maximumMergeDistance &&
    Math.abs(vertexCoordinates[(index * 3) + 1] - y) < maximumMergeDistance &&
    Math.abs(vertexCoordinates[(index * 3) + 2] - z) < maximumMergeDistance

  const findOrAddVertex = (x: number, y: number, z: number): number => {
    const cellX = x / cellSize
    const cellY = y / cellSize
    const cellZ = z / cellSize
    const ix = Math.floor(cellX)
    const iy = Math.floor(cellY)
    const iz = Math.floor(cellZ)
    const ownKey = hashCell(ix, iy, iz)

    // Fast path for the common case of an exactly identical vertex.
    // If one exists, it is the only vertex within the merge distance,
    // as no other vertex closer than the merge distance could have been added.
    const ownBucket = buckets.get(ownKey)
    if (ownBucket) {
      for (const index of ownBucket) {
        if (
          vertexCoordinates[index * 3] === x &&
          vertexCoordinates[(index * 3) + 1] === y &&
          vertexCoordinates[(index * 3) + 2] === z
        ) {
          return index
        }
      }
    }

    const neighborX = cellX - ix < 0.5 ? ix - 1 : ix + 1
    const neighborY = cellY - iy < 0.5 ? iy - 1 : iy + 1
    const neighborZ = cellZ - iz < 0.5 ? iz - 1 : iz + 1

    let match = -1
    for (let dx = 0; dx < 2; dx++) {
      const cx = dx === 0 ? ix : neighborX
      for (let dy = 0; dy < 2; dy++) {
        const cy = dy === 0 ? iy : neighborY
        for (let dz = 0; dz < 2; dz++) {
          const cz = dz === 0 ? iz : neighborZ
          const bucket = buckets.get(hashCell(cx, cy, cz))
          if (!bucket) continue
          for (const index of bucket) {
            if ((match === -1 || index < match) && isCloseTo(index, x, y, z)) {
              match = index
            }
          }
        }
      }
    }
    if (match !== -1) return match

    const index = vertexCoordinates.length / 3
    vertexCoordinates.push(x, y, z)
    if (ownBucket) ownBucket.push(index)
    else buckets.set(ownKey, [index])
    return index
  }

  for (let i = 0; i < faceCount * 3; i++) {
    faceVertexIndices[i] = findOrAddVertex(
      triangleCoordinates[i * 3],
      triangleCoordinates[(i * 3) + 1],
      triangleCoordinates[(i * 3) + 2],
    )
  }

  const faceNormals: number[] = Array.from(
    { length: faceCount * 3 },
    (_, i) => faceNormalCoordinates[i] ?? 0,
  )

  // Vertex normal = normalized sum of the normals of all adjacent faces
  const vertexNormalCoordinates: number[] =
    new Array(vertexCoordinates.length).fill(0)

  for (let i = 0; i < faceCount * 3; i++) {
    const vertex = faceVertexIndices[i] * 3
    const face = Math.floor(i / 3) * 3
    vertexNormalCoordinates[vertex] += faceNormals[face]
    vertexNormalCoordinates[vertex + 1] += faceNormals[face + 1]
    vertexNormalCoordinates[vertex + 2] += faceNormals[face + 2]
  }

  for (let v = 0; v < vertexNormalCoordinates.length; v += 3) {
    const x = vertexNormalCoordinates[v]
    const y = vertexNormalCoordinates[v + 1]
    const z = vertexNormalCoordinates[v + 2]
    const length = Math.sqrt((x * x) + (y * y) + (z * z))
    if (length > 0) {
      vertexNormalCoordinates[v] = x / length
      vertexNormalCoordinates[v + 1] = y / length
      vertexNormalCoordinates[v + 2] = z / length
    }
  }

  return {
    vertexCoordinates,
    faceVertexIndices,
    faceNormalCoordinates: faceNormals,
    vertexNormalCoordinates,
  }
}


export default function buildFaceVertexMesh (
  faces: FaceObject[],
  options?: BuildFaceVertexMeshOptions | null,
): FaceVertexData {
  const triangleCoordinates = new Float64Array(faces.length * 9)
  const faceNormalCoordinates = new Float64Array(faces.length * 3)

  faces.forEach((face, faceIndex) => {
    face.vertices.forEach((vertex, vertexIndex) => {
      const offset = (faceIndex * 9) + (vertexIndex * 3)
      triangleCoordinates[offset] = vertex.x
      triangleCoordinates[offset + 1] = vertex.y
      triangleCoordinates[offset + 2] = vertex.z
    })
    if (face.normal) {
      faceNormalCoordinates[faceIndex * 3] = face.normal.x
      faceNormalCoordinates[(faceIndex * 3) + 1] = face.normal.y
      faceNormalCoordinates[(faceIndex * 3) + 2] = face.normal.z
    }
  })

  return buildFaceVertexMeshFromTriangles(
    triangleCoordinates,
    faceNormalCoordinates,
    options ?? {},
  )
}
