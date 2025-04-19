import ExplicitModel, { FaceVertexData } from '../source/ExplicitModel.js'
import Vector from '@datatypes/vector'
import { FaceObject } from '@datatypes/face'

const maxCoordinateDelta = 0.00001

export default function(chai: Chai.ChaiStatic, utils: Chai.ChaiUtils) {
  chai.Assertion.addProperty('explicitModel', function () {
    return this.assert(
      this._obj instanceof ExplicitModel,
      'expected #{this} to be an explicit Model',
      'expected #{this} to not be an explicit Model',
      undefined,
    )
  })

  chai.Assertion.addProperty('faceVertexMesh', function() {
    this.assert(
      this._obj.mesh.faceVertex.hasOwnProperty('faceVertexIndices'),
      'expected #{this} to have faceVertexIndices',
      'expected #{this} to not have faceVertexIndices',
      undefined,
    )
    this.assert(
      this._obj.mesh.faceVertex.hasOwnProperty('vertexCoordinates'),
      'expected #{this} to have vertexCoordinates',
      'expected #{this} to not have vertexCoordinates',
      undefined,
    )
    this.assert(
      this._obj.mesh.faceVertex.hasOwnProperty('vertexNormalCoordinates'),
      'expected #{this} to have vertexNormals',
      'expected #{this} to not have vertexNormals',
      undefined,
    )
    return this.assert(
      this._obj.mesh.faceVertex.hasOwnProperty('faceNormalCoordinates'),
      'expected #{this} to have faceNormals',
      'expected #{this} to not have faceNormals',
      undefined,
    )
  })


  chai.Assertion.addProperty('triangleMesh', function() {
    const allTriangles = this._obj.mesh.polygons
      .every(polygon => polygon.vertices.length === 3)

    return this.assert(
      allTriangles,
      'expected mesh #{this} to consist only of triangles',
      'expected mesh #{this} to not consist only of triangles',
      undefined,
    )
  })


  chai.Assertion.addMethod('equalVector', function (vertex) {
      return ['x', 'y', 'z'].every(coordinate => {
        const actualCoordinate = this._obj[coordinate]
        const expectedCoordinate = vertex[coordinate]

        return chai.expect(actualCoordinate).to.be
          .closeTo(expectedCoordinate, maxCoordinateDelta)
        })
    })


  chai.Assertion.addMethod('equalFace', function (face) {
    this._obj.vertexCoordinates.every(
      (vertex, vertexIndex) => chai.expect(vertex)
        .to["equalVector"](face.vertexCoordinates[vertexIndex])
    )

    return chai.expect(this._obj.normal).to["equalVector"](face.normal)
  })


  chai.Assertion.addMethod('equalFaces', function (faces) {
    return this._obj.forEach(
      (face, faceIndex) => chai.expect(face).to["equalFace"](faces[faceIndex])
    )
  })


  chai.Assertion.addMethod('equalFaceVertexMesh', function (mesh) {
    this._obj.vertexCoordinates.forEach(
      (coordinate, coordinateIndex) => chai.expect(coordinate)
        .to.be.closeTo(
            mesh.vertexCoordinates[coordinateIndex],
            maxCoordinateDelta
        )
    )

    this._obj.faceVertexIndices.forEach(
      (faceVertexIndex, arrayIndex) => chai.expect(faceVertexIndex)
        .to.equal(mesh.faceVertexIndices[arrayIndex])
    )

    if (
      this._obj.faceNormalCoordinates?.length > 0 &&
      mesh.faceNormalCoordinates.length > 0
    ) {
      const length = Math.min(
        this._obj.faceNormalCoordinates.length,
        mesh.faceNormalCoordinates.length
      )
      for (let i = 0; i < length; i++) {
        chai.expect(this._obj.faceNormalCoordinates[i])
          .to.be.closeTo(
              mesh.faceNormalCoordinates[i],
              maxCoordinateDelta
          )
      }
    }

    // Skip vertex normal coordinate checks
    // if they're not in the expected mesh data
    if (
      this._obj.vertexNormalCoordinates?.length > 0 &&
      mesh.vertexNormalCoordinates?.length > 0
    ) {
      const length = Math.min(
        this._obj.vertexNormalCoordinates.length,
        mesh.vertexNormalCoordinates.length,
      )
      for (let i = 0; i < length; i++) {
        chai.expect(this._obj.vertexNormalCoordinates[i])
          .to.be.closeTo(
              mesh.vertexNormalCoordinates[i],
              maxCoordinateDelta
          )
      }
    }
  })


  return chai.Assertion.addProperty('correctNormals', function () {
    /* TODO
    correctDirection = @_obj.mesh.faces.every (face) ->
      TODO

    @assert(
      correctDirection
      'expected every face-normal to point in the right direction',
      'expected every face-normal to point in the wrong direction',
    )
    */

    const normalizedLength = this._obj.mesh.faces.every(
      (face: FaceObject) => Vector.fromObject(face.normal).length() === 1
    )

    return this.assert(
      normalizedLength,
      'expected every face-normal to have length of 1',
      'expected every face-normal to have a length different from 1',
      undefined,
    )
  })
}
