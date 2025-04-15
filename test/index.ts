import path from 'path'
import child_process from 'child_process'
import chai from 'chai'
import chaiPromised from 'chai-as-promised'
import chaiJsonSchema from 'chai-json-schema'

import meshlib from '../source/index.js'
import calculateProjectedFaceArea from '../source/helpers/calculateProjectedFaceArea.js'
import calculateProjectionCentroid from '../source/helpers/calculateProjectionCentroid.js'
import chaiHelper from './chaiHelper.js'
import models from './models/models.js'
import { MeshData } from 'meshlib/ExplicitModel.js'
import { depth } from 'three/examples/jsm/nodes/Nodes.js'

const { expect } = chai

// Type definition for chai assertions
declare global {
  namespace Chai {
    interface TypeComparison {
      explicitModel: void
    }
    interface PromisedTypeComparison {
      explicitModel: void
    }
    interface Assertion {
      equalFaceVertexMesh(mesh: any): void
      correctNormals: void
    }
    interface PromisedAssertion {
      correctNormals: void
      equalFaceVertexMesh(mesh: any): void
    }
  }
}

// Order of use statements is important
chai.use(chaiHelper)
chai.use(chaiPromised)
chai.use(chaiJsonSchema)

const __dirname = import.meta.dirname

// const checkEquality = function(dataFromAscii, dataFromBinary, arrayName) {
//  const fromAscii = dataFromAscii[arrayName].map(position => Math.round(position))
// //  const fromBinary = dataFromBinary[arrayName].map(position => Math.round(position))

//  return expect(fromAscii).to.deep.equal(fromBinary)
// // }


describe('Meshlib', () => {
  it('returns a model object', async () => {
    const jsonModel = models['cube'].load() as MeshData
    const modelPromise = meshlib(jsonModel).done()
    return expect(modelPromise).to.eventually.be.an.explicitModel
  })


  it('builds faces from face vertex mesh', () => {
    const jsonModel = models['tetrahedron'].load() as MeshData

    const modelPromise = meshlib(jsonModel)
      .buildFaceVertexMesh()
      .setFaces(null)
      .buildFacesFromFaceVertexMesh()
      .getObject()
      .then(object => object.mesh.faces)

    return expect(modelPromise)
      .to.eventually.deep.equal(
        (models['tetrahedron'].load() as MeshData).faces
      )
    })


  it('calculates face-normals', () => {
    const jsonModel = models['cube'].load() as MeshData

    jsonModel.faces.forEach(face => delete face.normal)

    const modelPromise = meshlib(jsonModel)
      .calculateNormals()
      .done(model => model)

    return expect(modelPromise).to.eventually.have.correctNormals
  })


  it('returns a clone', function(done) {
    const jsonModel = models['cube'].load() as MeshData

    const model = meshlib(jsonModel)

    model
    .getObject()
    .then(object => model
        .getClone()
        .then(modelClone => modelClone.getObject()).then(function(cloneObject) {
            try {
                expect(cloneObject).to.deep.equal(object)
                return done()
              } catch (error) {
                return done(error)
              }
        }))
      })


  it('extracts individual geometries to submodels', () => {
    const jsonModel = models['tetrahedrons'].load() as MeshData

    const modelPromise = meshlib(jsonModel)
      .buildFaceVertexMesh()
      .getSubmodels()

    return expect(modelPromise).to.eventually.be.an('array')
    .and.to.have.length(2)
  })


  it('returns a JSON representation of the model', () => {
    const jsonModel = models['cube'].load() as MeshData

    const modelPromise = meshlib(jsonModel)
    .getJSON()

    return expect(modelPromise).to.eventually.be.a('string')
  })


  it('returns a javascript object representing the model', () => {
    const jsonModel = models['cube'].load() as MeshData

    const modelPromise = meshlib(jsonModel)
    .getObject()

    return expect(modelPromise).to.eventually.be.an('object')
    .and.to.have.any.keys('name', 'fileName', 'mesh')
  })


  it('translates a model', () => {
    const jsonModel = models['tetrahedron'].load() as MeshData

    const modelPromise = meshlib(jsonModel)
    .translate({x: 1, y: 1, z: 1})
    .getObject()
    .then(object => object.mesh.faces[0].vertices)

    return expect(modelPromise).to.eventually.deep.equal([
      {x: 2, y: 1, z: 1},
      {x: 1, y: 2, z: 1},
      {x: 1, y: 1, z: 2}
    ])
  })


  it('calculates the centroid of a face-projection', () => {
      expect(calculateProjectionCentroid({
          vertices: [
              {x: 0, y: 0, z: 0},
              {x: 2, y: 0, z: 0},
              {x: 0, y: 2, z: 0}
          ]
      }))
    .to.deep.equal({
        x: 0.6666666666666666,
        y: 0.6666666666666666
    })
  })


  describe('Two-Manifold Test', () => {
    it('recognizes that model is two-manifold', () => {
      const jsonModel = models['tetrahedron'].load() as MeshData

      const modelPromise = meshlib(jsonModel)
      .buildFaceVertexMesh()
      .isTwoManifold()

      return expect(modelPromise).to.eventually.be.true
    })


    return it('recognizes that model is not two-manifold', () => {
      const jsonModel = models['missingFace'].load() as MeshData

      const modelPromise = meshlib(jsonModel)
      .buildFaceVertexMesh()
      .isTwoManifold()

      return expect(modelPromise).to.eventually.be.false
    })
  })


  describe('calculateBoundingBox', () => {
    it('calculates the bounding box of a tetrahedron', () => {
      const jsonTetrahedron = models['tetrahedron'].load() as MeshData

      const modelPromise = meshlib(jsonTetrahedron)
      .buildFaceVertexMesh()
      .getBoundingBox()

      return expect(modelPromise).to.eventually.deep.equal({
        min: {x: 0, y: 0, z: 0},
        max: {x: 1, y: 1, z: 1}
      })
    })


    return it('calculates the bounding box of a cube', () => {
      const jsonCube = models['cube'].load() as MeshData

      const modelPromise = meshlib(jsonCube)
      .buildFaceVertexMesh()
      .getBoundingBox()

      return expect(modelPromise).to.eventually.deep.equal({
        min: {x: -1, y: -1, z: -1},
        max: {x: 1, y: 1, z: 1}
      })
    })
  })


  describe('Faces', () => {

    it('returns all faces', () => {
      const jsonTetrahedron = models['tetrahedron'].load() as MeshData

      const modelPromise = meshlib(jsonTetrahedron)
      .getFaces()

      return expect(modelPromise).to.eventually
      .deep.equal(jsonTetrahedron.faces)
    })


    it('returns all faces which are orthogonal to the xy-plane', () => {
      const jsonTetrahedron = models['tetrahedron'].load() as MeshData

      const modelPromise = meshlib(jsonTetrahedron)
      .getFaces({
        filter(face) {
          return face.normal.z === 0
        }
      })

      return expect(modelPromise).to.eventually.deep.equal([
        {
          vertices: [
            {x: 0, y: 0, z: 0},
            {x: 1, y: 0, z: 0},
            {x: 0, y: 0, z: 1}
          ],
          normal: {x: 0, y: -1, z: 0}
        },
        {
          vertices: [
            {x: 0, y: 0, z: 0},
            {x: 0, y: 0, z: 1},
            {x: 0, y: 1, z: 0}
          ],
          normal: {x: -1, y: 0, z: 0}
        }
      ])
    })


    it('calculates the in xy-plane projected surface-area of a face', () => {
      expect(calculateProjectedFaceArea({
        vertices: [
          {x: 0, y: 0, z: 2},
          {x: 1, y: 0, z: 0},
          {x: 0, y: 1, z: 0}
        ]
      }))
      .to.equal(0.5)

      return expect(calculateProjectedFaceArea({
        vertices: [
          {x: 0, y: 0, z: -2},
          {x: 2, y: 0, z: 0},
          {x: 0, y: 4, z: 0}
        ]
      }))
      .to.equal(4)
    })


    it('retrieves the face with the largest xy-projection', () => {
      const jsonTetrahedron = models['irregular tetrahedron'].load() as MeshData

      const modelPromise = meshlib(jsonTetrahedron)
      .getFaceWithLargestProjection()

      return expect(modelPromise).to.eventually.deep.equal({
        normal: {x: 0, y: 0, z: -1},
        vertices: [
          {x: 0, y: 0, z: 0},
          {x: 0, y: 2, z: 0},
          {x: 3, y: 0, z: 0}
        ],
        attribute: 0
      })
    })


    it('iterates over all faces in the face-vertex-mesh', () => {
      const jsonTetrahedron = models['tetrahedron'].load() as MeshData
      const vertices = []

      return meshlib(jsonTetrahedron)
      .buildFaceVertexMesh()
      .forEachFace((face, index) => vertices.push([face, index]))
      .done(() => expect(vertices).to.have.length(4))
    })


    it(`returns a rotation angle \
to align the model to the cartesian grid`, () => {
      const jsonTetrahedron = models['tetrahedron'].load() as MeshData
      const tetrahedronPromise = meshlib(jsonTetrahedron).getGridAlignRotationAngle()

      expect(tetrahedronPromise).to.eventually.equal(0)

      const jsonCube = models['cube'].load() as MeshData
      const cubePromise = meshlib(jsonCube)
      .rotate({angle: 42, unit: 'degree'})
      .calculateNormals()
      .getGridAlignRotationAngle({unit: 'degree'})

      return expect(cubePromise).to.eventually.equal(42)
    })


    return it(`returns a histogram \
with the surface area for each rotation angle`, () => {
      const jsonCube = models['cube'].load() as MeshData
      const cubePromise = meshlib(jsonCube)
        .rotate({angle: 42, unit: 'degree'})
        .calculateNormals()
        .getGridAlignRotationHistogram()
        let expectedArray = new Array(90)
      expectedArray[42] = 16

      expectedArray =
        (Array.from(expectedArray).map((value, index) => index + '\t' + (value || 0)))

      return expect(cubePromise)
      .to.eventually.deep.equal(expectedArray.join('\n'))
    })
  })


  describe('Base64', () => {
    const tetrahedronBase64Array = [
      // vertexCoordinates
      'AACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAA',

      // faceVertexIndices
      'AAAAAAEAAAACAAAAAwAAAAAAAAACAAAAAwAAAAIAAAABAAAAAwAAAAEAAAAAAAAA',

      // vertexNormalCoordinates
      '6toxP/EyAr/xMgK/8TICv+raMT/xMgK/8TICv/EyAr/q2jE/Os0TvzrNE786zRO/',

      // faceNormalCoordinates
      'Os0TPzrNEz86zRM/AAAAAAAAgL8AAAAAAACAvwAAAAAAAAAAAAAAAAAAAAAAAIC/',

      // name
      'tetrahedron'
    ]


    it('exports model to base64 representation', () => {
      const model = models['tetrahedron']
      const jsonTetrahedron = model.load() as MeshData

      const modelPromise = meshlib(jsonTetrahedron)
        .setName(model.name)
        .buildFaceVertexMesh()
        .getBase64()
        .then(base64String => base64String.split('|'))

      return expect(modelPromise)
        .to.eventually.be.deep.equal(tetrahedronBase64Array)
    })


    it('creates model from base64 representation', () => {
      const jsonTetrahedron = models['tetrahedron'].load() as MeshData

      return meshlib(jsonTetrahedron)
        .buildFaceVertexMesh()
        .getFaceVertexMesh()
        .then(function(faceVertexMesh) {
          const actual = meshlib
          .Model
          .fromBase64(tetrahedronBase64Array.join('|'))
          .getFaceVertexMesh()


          return expect(actual).to.eventually.equalFaceVertexMesh(faceVertexMesh)
        })
    })

    it('parses a complex base64 encoded model', () => {
      const base64Model = models['heart'].load() as MeshData
      const modelSchema = {
        title: 'Meshlib-model schema',
        type: 'object',
        required: ['mesh'],
        properties: {
          name: {type: 'string'},
          fileName: {type: 'string'},
          mesh: {
            type: 'object',
            required: ['faceVertex'],
            properties: {
              faceVertex: {
                type: 'object',
                required: [
                  'faceVertexIndices',
                  'vertexCoordinates',
                  'vertexNormalCoordinates',
                  'faceNormalCoordinates'
                ]
              }
            }
          }
        }
      }
      const modelPromise = meshlib.Model
        // @ts-expect-error  Not assignable to parameter of type 'string'
        .fromBase64(base64Model)
        .getObject()
        .then(object => expect(object).to.be.jsonSchema(modelSchema))

      return expect(modelPromise).to.eventually.be.ok
    })
  })


  describe('Transformations', () => {
    it('can be transformed by applying a matrix', () => {
      const jsonModel = models['tetrahedron'].load() as MeshData

      const modelPromise = meshlib(jsonModel)
      .applyMatrix([
        [1, 0, 0, 10],
        [0, 1, 0, 20],
        [0, 0, 1, 30],
        [0, 0, 0, 1]
      ])
      .getFaces()
      .then(faces => faces[0].vertices)

      return expect(modelPromise)
      .to.eventually.deep.equal([
        {x: 11, y: 20, z: 30},
        {x: 10, y: 21, z: 30},
        {x: 10, y: 20, z: 31}
      ])
    })

    return it('can be rotated', () => {
      const jsonModel = models['tetrahedron'].load() as MeshData

      const modelPromise = meshlib(jsonModel)
      .rotate({angle: 45, unit: 'degree'})
      .getFaces()
      .then(faces => faces[0].vertices)

      return expect(modelPromise)
      .to.eventually.deep.equal([
        {x: 0.7071067811865476, y: 0.7071067811865475, z: 0},
        {x: -0.7071067811865475, y: 0.7071067811865476, z: 0},
        {x: 0, y: 0, z: 1}
      ])
    })
})


  return describe('Command Line Interface', () => {
    it('parses a YAML file', () => {
      const cliScriptPath = path.resolve(__dirname, '../cli/index.ts')
      const command = `npx tsx ${cliScriptPath} ${models['tetrahedron'].filePath}`

      const actualOutput = child_process
        .execSync(command, {stdio: [0]})
        .toString()

      // Make sure we have some output and it's valid JSON
      const parsedActual = JSON.parse(actualOutput)
      expect(parsedActual).to.be.an('object')
    })


    it('parses a JSONL stream', () => {
      const cliScriptPath = path.resolve(__dirname, '../cli/index.ts')
      const command = `npx tsx ${cliScriptPath} --json < ${models['jsonl tetrahedron'].filePath}`
      const expectedOutput = JSON.stringify({
        mesh: models['normal first tetrahedron'].load() as MeshData
      }) + '\n'

      let actualOutput = JSON.parse(
        child_process.execSync(command).toString() // Use default stdio, convert buffer to string
      )

      // Extract the mesh part from the actual output for comparison
      const actualMesh = actualOutput.mesh

      // Remove the 'number' property from actual faces if it exists,
      // as it's not present in the expected YAML data for this test.
      if (actualMesh && Array.isArray(actualMesh.faces)) {
        actualMesh.faces = actualMesh.faces.map(face => {
          delete face.number
          return face
        })
      }

      // The expected output already contains just the mesh under the 'mesh' key
      const expectedMesh = JSON.parse(expectedOutput).mesh

      // Compare the mesh objects directly (chai deep equal handles object comparison)
      return expect(actualMesh).to.deep.equal(expectedMesh)
    })


    return it('parses a base64 file and emits a JSONL stream', () => {
      const cliScriptPath = path.resolve(__dirname, '../cli/index.ts')
      const command = `npx tsx ${cliScriptPath} --input base64 ${models['heart'].filePath}`

      const actualOutput = child_process
        .execSync(command, {stdio: [0]})
        .toString()

      return expect(actualOutput).to.match(/^\{.*\}$/gm)
    })
  })
})
