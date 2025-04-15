import chai from 'chai'
const { expect } = chai

import models from './models/models.js'
import meshlib from '../source/index.js'
import buildFacesFromFaceVertexMesh from '../source/helpers/buildFacesFromFaceVertexMesh.js'
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
