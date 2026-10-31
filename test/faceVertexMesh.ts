import chai from 'chai'
const { expect } = chai

import models from './models/models.js'
import meshlib from '../source/index.js'
import buildFacesFromFaceVertexMesh from '../source/helpers/buildFacesFromFaceVertexMesh.js'
import buildFaceVertexMesh, {
  buildFaceVertexMeshFromTriangles,
} from '../source/helpers/buildFaceVertexMesh.js'
import { MeshData } from 'meshlib/ExplicitModel.js'

// Define FaceVertexMesh interface for test purposes
interface FaceVertexMesh {
  vertexCoordinates: number[]
  faceVertexIndices: number[]
  vertexNormalCoordinates: number[]
  faceNormalCoordinates: number[]
  [key: string]: unknown
}


describe('Mesh Transformation', () => {
  it('creates a face-vertex mesh from the list of faces of a tetrahedron', () => {
    const tetrahedronFaces = models['tetrahedron'].load() as MeshData
    const tetrahedronFaceVertexMesh = models['face-vertex tetrahedron'].load() as FaceVertexMesh

    const modelPromise = meshlib(tetrahedronFaces)
      .buildFaceVertexMesh()
      .done(model => model, null)
      .then(model => buildFacesFromFaceVertexMesh(model.mesh.faceVertex as FaceVertexMesh), null)

    return expect(modelPromise)
      .to.eventually
      .deep.equal(buildFacesFromFaceVertexMesh(tetrahedronFaceVertexMesh))
    })


  it(`creates a face-vertex mesh from the list of faces \
of an irregular tetrahedron`, () => {
    const tetrahedronFaces = models['irregular tetrahedron'].load() as MeshData
    const tetrahedronFaceVertexMesh =
      models['face-vertex irregular tetrahedron'].load()  as FaceVertexMesh

    const modelPromise = meshlib(tetrahedronFaces)
      .buildFaceVertexMesh()
      .done(model => model, null)
      .then(model => buildFacesFromFaceVertexMesh(model.mesh.faceVertex as FaceVertexMesh), null)

    return expect(modelPromise)
      .to.eventually
      .deep.equal(buildFacesFromFaceVertexMesh(tetrahedronFaceVertexMesh))
    })


  return it('creates a face-vertex mesh from the list of faces of a cube', () => {
    const cubeFaces = models['cube'].load() as MeshData
    const cubeFaceVertexMesh = models['face-vertex cube'].load() as FaceVertexMesh

    const modelPromise = meshlib(cubeFaces)
      .buildFaceVertexMesh()
      .done(model => model, null)
      .then(model => buildFacesFromFaceVertexMesh(model.mesh.faceVertex as FaceVertexMesh), null)

    return expect(modelPromise)
      .to.eventually
      .deep.equal(buildFacesFromFaceVertexMesh(cubeFaceVertexMesh))
    })
})


describe('buildFaceVertexMesh', () => {
  const normal = {x: 0, y: 0, z: 1}
  const triangle = (...vertices: [number, number, number][]) => ({
    normal,
    vertices: vertices.map(([x, y, z]) => ({x, y, z})),
  })

  it('merges vertices closer than the merge distance', () => {
    const mesh = buildFaceVertexMesh([
      triangle([0, 0, 0], [1, 0, 0], [0, 1, 0]),
      triangle([0.00005, 0, 0], [1, 0.00009, 0], [0, 0, 1]),
    ])
    expect(mesh.vertexCoordinates).to.deep.equal(
      [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
    )
    expect(mesh.faceVertexIndices).to.deep.equal([0, 1, 2, 0, 1, 3])
  })

  it('merges vertices across grid cell boundaries', () => {
    // Merge distance 0.0001 → cell size 0.0002 → 0.0002 is a cell boundary
    const mesh = buildFaceVertexMesh([
      triangle([0.000199, -0.000001, 5], [1, 0, 0], [0, 1, 0]),
      triangle([0.000201, 0.000001, 5], [1, 0, 0], [0, 1, 0]),
    ])
    expect(mesh.vertexCoordinates).to.have.length(9)
    expect(mesh.faceVertexIndices).to.deep.equal([0, 1, 2, 0, 1, 2])
  })

  it('does not merge vertices at or beyond the merge distance', () => {
    const mesh = buildFaceVertexMesh([
      triangle([0, 0, 0], [1, 0, 0], [0, 1, 0]),
      triangle([0.0002, 0, 0], [1, 0, 0.0001], [0, 1, 0]),
    ])
    expect(mesh.faceVertexIndices).to.deep.equal([0, 1, 2, 3, 4, 2])
  })

  it('merges into the first seen vertex', () => {
    // 0.00008 is within the merge distance of both 0 and 0.00016,
    // which are not within the merge distance of each other
    const mesh = buildFaceVertexMesh([
      triangle([0, 0, 0], [0.00016, 0, 0], [0.00008, 0, 0]),
    ])
    expect(mesh.faceVertexIndices).to.deep.equal([0, 1, 0])
  })

  it('respects the maximumMergeDistance option', () => {
    const mesh = buildFaceVertexMesh(
      [triangle([0, 0, 0], [0.4, 0, 0], [3, 0, 0])],
      {maximumMergeDistance: 0.5},
    )
    expect(mesh.faceVertexIndices).to.deep.equal([0, 0, 1])
  })

  it('does not modify the provided faces', () => {
    const faces = [triangle([0, 0, 0], [1, 0, 0], [0, 1, 0])]
    const facesCopy = JSON.parse(JSON.stringify(faces))
    buildFaceVertexMesh(faces)
    expect(faces).to.deep.equal(facesCopy)
  })

  it('calculates normalized vertex normals from adjacent faces', () => {
    const mesh = buildFaceVertexMesh([
      {normal: {x: 1, y: 0, z: 0}, vertices: [
        {x: 0, y: 0, z: 0}, {x: 0, y: 1, z: 0}, {x: 0, y: 0, z: 1},
      ]},
      {normal: {x: 0, y: 1, z: 0}, vertices: [
        {x: 0, y: 0, z: 0}, {x: 0, y: 0, z: 1}, {x: 1, y: 0, z: 0},
      ]},
    ])
    expect(mesh.vertexNormalCoordinates.slice(0, 3)[0])
      .to.be.closeTo(Math.SQRT1_2, 1e-9)
    expect(mesh.vertexNormalCoordinates.slice(0, 3)[1])
      .to.be.closeTo(Math.SQRT1_2, 1e-9)
    expect(mesh.faceNormalCoordinates).to.deep.equal([1, 0, 0, 0, 1, 0])
  })

  it('builds the same mesh from a flat list of triangle coordinates', () => {
    const faces = (models['cube'].load() as MeshData).faces
    const triangleCoordinates = faces.flatMap(face =>
      face.vertices.flatMap(vertex => [vertex.x, vertex.y, vertex.z]),
    )
    const faceNormalCoordinates = faces.flatMap(face =>
      [face.normal.x, face.normal.y, face.normal.z],
    )
    expect(buildFaceVertexMeshFromTriangles(
      new Float32Array(triangleCoordinates),
      new Float32Array(faceNormalCoordinates),
    )).to.deep.equal(buildFaceVertexMesh(faces))
  })

  it('runs in linear time', function () {
    this.timeout(10000)
    const gridFaces = (size: number) => {
      const faces = []
      for (let x = 0; x < size; x++) {
        for (let y = 0; y < size; y++) {
          faces.push(triangle([x, y, 0], [x + 1, y, 0], [x, y + 1, 0]))
          faces.push(triangle([x + 1, y, 0], [x + 1, y + 1, 0], [x, y + 1, 0]))
        }
      }
      return faces
    }
    const time = (faces: ReturnType<typeof gridFaces>) => {
      const start = performance.now()
      buildFaceVertexMesh(faces)
      return performance.now() - start
    }
    const small = gridFaces(100)
    const large = gridFaces(400) // 16 × as many faces
    time(small) // Warm up
    // Quadratic runtime would make this ~256 × slower
    expect(time(large)).to.be.below(Math.max(time(small), 1) * 64)
  })
})
