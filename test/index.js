import path from 'path'
import child_process from 'child_process'
import chai from 'chai'
import chaiPromised from 'chai-as-promised'
import chaiJsonSchema from 'chai-json-schema'

// import ExplicitModel from '../source/ExplicitModel.js'
import meshlib from '../source/index.js'
import calculateProjectedFaceArea from '../source/helpers/calculateProjectedFaceArea.js'
import calculateProjectionCentroid from '../source/helpers/calculateProjectionCentroid.js'
// import buildFacesFromFaceVertexMesh from '../source/helpers/buildFacesFromFaceVertexMesh.js'
import chaiHelper from './chaiHelper.js'
import models from './models/models.js'

const { expect } = chai;

// Order of use statments is important
chai.use(chaiHelper);
chai.use(chaiPromised);
chai.use(chaiJsonSchema);

const __dirname = import.meta.dirname;

// const checkEquality = function(dataFromAscii, dataFromBinary, arrayName) {
//  const fromAscii = dataFromAscii[arrayName].map(position => Math.round(position));
//  const fromBinary = dataFromBinary[arrayName].map(position => Math.round(position));

//  return expect(fromAscii).to.deep.equal(fromBinary);
// };


describe('Meshlib', function() {
  it('returns a model object', function() {
    const jsonModel = models['cube'].load();

    const modelPromise = meshlib(jsonModel)
    .done(model => model);

    return expect(modelPromise).to.eventually.be.an.explicitModel;
  });


  it('builds faces from face vertex mesh', function() {
    const jsonModel = models['tetrahedron'].load();

    const modelPromise = meshlib(jsonModel)
      .buildFaceVertexMesh()
      .setFaces(null)
      .buildFacesFromFaceVertexMesh()
      .getObject()
      .then(object => object.mesh.faces);

    return expect(modelPromise)
      .to.eventually.deep.equal(
        models['tetrahedron'].load().faces
      );
  });


  it('calculates face-normals', function() {
    const jsonModel = models['cube'].load();

    jsonModel.faces.forEach(face => delete face.normal);

    const modelPromise = meshlib(jsonModel)
    .calculateNormals()
    .done(model => model);

    return expect(modelPromise).to.eventually.have.correctNormals;
  });


  it('returns a clone', function(done) {
    const jsonModel = models['cube'].load();

    const model = meshlib(jsonModel);

    model
    .getObject()
    .then(object => model
        .getClone()
        .then(modelClone => modelClone.getObject()).then(function(cloneObject) {
            try {
                expect(cloneObject).to.deep.equal(object);
                return done();
            } catch (error) {
                return done(error);
            }
        }));
  });


  it('extracts individual geometries to submodels', function() {
    const jsonModel = models['tetrahedrons'].load();

    const modelPromise = meshlib(jsonModel)
      .buildFaceVertexMesh()
      .getSubmodels();

    return expect(modelPromise).to.eventually.be.an('array')
    .and.to.have.length(2);
  });


  it('returns a JSON representation of the model', function() {
    const jsonModel = models['cube'].load();

    const modelPromise = meshlib(jsonModel)
    .getJSON();

    return expect(modelPromise).to.eventually.be.a('string');
  });


  it('returns a javascript object representing the model', function() {
    const jsonModel = models['cube'].load();

    const modelPromise = meshlib(jsonModel)
    .getObject();

    return expect(modelPromise).to.eventually.be.an('object')
    .and.to.have.any.keys('name', 'fileName', 'mesh');
  });


  it('translates a model', function() {
    const jsonModel = models['tetrahedron'].load();

    const modelPromise = meshlib(jsonModel)
    .translate({x: 1, y: 1, z: 1})
    .getObject()
    .then(object => object.mesh.faces[0].vertices);

    return expect(modelPromise).to.eventually.deep.equal([
      {x: 2, y: 1, z: 1},
      {x: 1, y: 2, z: 1},
      {x: 1, y: 1, z: 2}
    ]);
});


  it('calculates the centroid of a face-projection', () => expect(calculateProjectionCentroid({
        vertices: [
            {x: 0, y: 0, z: 0},
            {x: 2, y: 0, z: 0},
            {x: 0, y: 2, z: 0}
        ]
    }))
    .to.deep.equal({
        x: 0.6666666666666666,
        y: 0.6666666666666666
    }));


  describe('Two-Manifold Test', function() {
    it('recognizes that model is two-manifold', function() {
      const jsonModel = models['tetrahedron'].load();

      const modelPromise = meshlib(jsonModel)
      .buildFaceVertexMesh()
      .isTwoManifold();

      return expect(modelPromise).to.eventually.be.true;
    });


    return it('recognizes that model is not two-manifold', function() {
      const jsonModel = models['missingFace'].load();

      const modelPromise = meshlib(jsonModel)
      .buildFaceVertexMesh()
      .isTwoManifold();

      return expect(modelPromise).to.eventually.be.false;
    });
  });


  describe('calculateBoundingBox', function() {
    it('calculates the bounding box of a tetrahedron', function() {
      const jsonTetrahedron = models['tetrahedron'].load();

      const modelPromise = meshlib(jsonTetrahedron)
      .buildFaceVertexMesh()
      .getBoundingBox();

      return expect(modelPromise).to.eventually.deep.equal({
        min: {x: 0, y: 0, z: 0},
        max: {x: 1, y: 1, z: 1}
      });
    });


    return it('calculates the bounding box of a cube', function() {
      const jsonCube = models['cube'].load();

      const modelPromise = meshlib(jsonCube)
      .buildFaceVertexMesh()
      .getBoundingBox();

      return expect(modelPromise).to.eventually.deep.equal({
        min: {x: -1, y: -1, z: -1},
        max: {x: 1, y: 1, z: 1}
      });
    });
  });


  describe('Faces', function() {

    it('returns all faces', function() {
      const jsonTetrahedron = models['tetrahedron'].load();

      const modelPromise = meshlib(jsonTetrahedron)
      .getFaces();

      return expect(modelPromise).to.eventually
      .deep.equal(jsonTetrahedron.faces);
    });


    it('returns all faces which are orthogonal to the xy-plane', function() {
      const jsonTetrahedron = models['tetrahedron'].load();

      const modelPromise = meshlib(jsonTetrahedron)
      .getFaces({
        filter(face) {
          return face.normal.z === 0;
        }
      });

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
      ]);
  });


    it('calculates the in xy-plane projected surface-area of a face', function() {
      expect(calculateProjectedFaceArea({
        vertices: [
          {x: 0, y: 0, z: 2},
          {x: 1, y: 0, z: 0},
          {x: 0, y: 1, z: 0}
        ]
      }))
      .to.equal(0.5);

      return expect(calculateProjectedFaceArea({
        vertices: [
          {x: 0, y: 0, z: -2},
          {x: 2, y: 0, z: 0},
          {x: 0, y: 4, z: 0}
        ]
      }))
      .to.equal(4);
    });


    it('retrieves the face with the largest xy-projection', function() {
      const jsonTetrahedron = models['irregular tetrahedron'].load();

      const modelPromise = meshlib(jsonTetrahedron)
      .getFaceWithLargestProjection();

      return expect(modelPromise).to.eventually.deep.equal({
        normal: {x: 0, y: 0, z: -1},
        vertices: [
          {x: 0, y: 0, z: 0},
          {x: 0, y: 2, z: 0},
          {x: 3, y: 0, z: 0}
        ],
        attribute: 0
      });
  });


    it('iterates over all faces in the face-vertex-mesh', function() {
      const jsonTetrahedron = models['tetrahedron'].load();
      const vertices = [];

      return meshlib(jsonTetrahedron)
      .buildFaceVertexMesh()
      .forEachFace((face, index) => vertices.push([face, index]))
      .done(() => expect(vertices).to.have.length(4));
    });


    it(`returns a rotation angle \
to align the model to the cartesian grid`, function() {
      const jsonTetrahedron = models['tetrahedron'].load();
      const tetrahedronPromise = meshlib(jsonTetrahedron).getGridAlignRotationAngle();

      expect(tetrahedronPromise).to.eventually.equal(0);

      const jsonCube = models['cube'].load();
      const cubePromise = meshlib(jsonCube)
      .rotate({angle: 42, unit: 'degree'})
      .calculateNormals()
      .getGridAlignRotationAngle({unit: 'degree'});

      return expect(cubePromise).to.eventually.equal(42);
    });


    return it(`returns a histogram \
with the surface area for each rotation angle`, function() {
      const jsonCube = models['cube'].load();
      const cubePromise = meshlib(jsonCube)
        .rotate({angle: 42, unit: 'degree'})
        .calculateNormals()
        .getGridAlignRotationHistogram();
      let expectedArray = new Array(90);
      expectedArray[42] = 16;

      expectedArray =
        (Array.from(expectedArray).map((value, index) => index + '\t' + (value || 0)));

      return expect(cubePromise)
      .to.eventually.deep.equal(expectedArray.join('\n'));
    });
  });


  describe('Base64', function() {
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
    ];


    it.skip('exports model to base64 representation', function() {
      const model = models['tetrahedron'];
      const jsonTetrahedron = model.load();

      const modelPromise = meshlib(jsonTetrahedron)
      .setName(model.name)
      .buildFaceVertexMesh()
      .getBase64()
      .then(base64String => base64String.split('|'));

      return expect(modelPromise)
      .to.eventually.be.deep.equal(tetrahedronBase64Array);
    });


    it.skip('creates model from base64 representation', function() {
      const jsonTetrahedron = models['tetrahedron'].load();

      return meshlib(jsonTetrahedron)
      .buildFaceVertexMesh()
      .getFaceVertexMesh()
      .then(function(faceVertexMesh) {
        const actual = meshlib
        .Model
        .fromBase64(tetrahedronBase64Array.join('|'))
        .getFaceVertexMesh();


        return expect(actual).to.eventually.equalFaceVertexMesh(faceVertexMesh);
      });
    });

    return it('parses a complex base64 encoded model', function() {
      const base64Model = models['heart'].load();
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
      };
      const modelPromise = meshlib.Model
        .fromBase64(base64Model)
        .getObject()
        .then(object => expect(object).to.be.jsonSchema(modelSchema));

      return expect(modelPromise).to.eventually.be.ok;
    });
  });


  describe('Transformations', function() {
    it('can be transformed by applying a matrix', function() {
      const jsonModel = models['tetrahedron'].load();

      const modelPromise = meshlib(jsonModel)
      .applyMatrix([
        [1, 0, 0, 10],
        [0, 1, 0, 20],
        [0, 0, 1, 30],
        [0, 0, 0, 1]
      ])
      .getFaces()
      .then(faces => faces[0].vertices);

      return expect(modelPromise)
      .to.eventually.deep.equal([
        {x: 11, y: 20, z: 30},
        {x: 10, y: 21, z: 30},
        {x: 10, y: 20, z: 31}
      ]);
  });

    return it('can be rotated', function() {
      const jsonModel = models['tetrahedron'].load();

      const modelPromise = meshlib(jsonModel)
      .rotate({angle: 45, unit: 'degree'})
      .getFaces()
      .then(faces => faces[0].vertices);

      return expect(modelPromise)
      .to.eventually.deep.equal([
        {x: 0.7071067811865476, y: 0.7071067811865475, z: 0},
        {x: -0.7071067811865475, y: 0.7071067811865476, z: 0},
        {x: 0, y: 0, z: 1}
      ]);
  });
});


  return describe('Command Line Interface', function() {
    it('parses a YAML file', function() {
      const command = path.resolve(__dirname, '../cli/index-dev.js') + ' ' +
        models['tetrahedron'].filePath;
      const expectedOutput = JSON.stringify({
        mesh: models['tetrahedron'].load()
      }) + '\n';

      const actualOutput = child_process
        .execSync(command, {stdio: [0]})
        .toString();

      return expect(actualOutput).to.equal(expectedOutput);
    });


    it('parses a JSONL stream', function() {
      const command = path.resolve(__dirname, '../cli/index-dev.js') +
        ' --json < ' + models['jsonl tetrahedron'].filePath;
      const expectedOutput = JSON.stringify({
        mesh: models['normal first tetrahedron'].load()
      }) + '\n';

      let actualOutput = JSON.parse(
        child_process.execSync(command, {stdio: [0]})
      );

      actualOutput.mesh.faces = actualOutput.mesh.faces
        .map(function(face) {
          delete face.number;
          return face;
      });

      delete actualOutput.name;
      delete actualOutput.transformations;
      delete actualOutput.options;

      actualOutput = JSON.stringify(actualOutput) + '\n';

      return expect(actualOutput).to.equal(expectedOutput);
    });


    return it('parses a base64 file and emits a JSONL stream', function() {
      const command = path.resolve(__dirname, '../cli/index-dev.js') +
        ' --input base64 ' + models['heart'].filePath;

      const actualOutput = child_process
        .execSync(command, {stdio: [0]})
        .toString();

      return expect(actualOutput).to.match(/^\{.*\}$/gm);
    });
  });
});
