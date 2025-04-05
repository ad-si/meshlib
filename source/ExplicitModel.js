import deg2rad from 'deg2rad'
import rad2deg from 'rad2deg'

import Vector from '@datatypes/vector'
import Face from '@datatypes/face'
import Matrix from '@datatypes/matrix'
import fastClone from './helpers/fastClone.js'
import geometrySplitter from './helpers/separateGeometry.js'
import buildFaceVertexMesh from './helpers/buildFaceVertexMesh.js'
import buildFacesFromFaceVertexMesh from './helpers/buildFacesFromFaceVertexMesh.js'
import testTwoManifoldness from './helpers/testTwoManifoldness.js'
import * as calculateBoundingBox from './helpers/calculateBoundingBox.js'
import calculateProjectedFaceArea from './helpers/calculateProjectedFaceArea.js'
import convertToBase64 from './helpers/convertToBase64.js'
import buildMeshFromBase64 from './helpers/buildMeshFromBase64.js'
import NoFacesError from './errors/NoFacesError.js'
import ModelStream from './ModelStream.js'


const modulo = (value1, value2) => // Work around javascript modulo bug
// javascript.about.com/od/problemsolving/a/modulobug.htm
(value1 % value2 + value2) % value2;


const getRotationMatrix = function(param) {
  if (param == null) { param = {}; }
  let {axis, angle} = param;
  if (axis == null) { axis = 'z'; }

  const cos = Math.cos(angle);
  const sin = Math.sin(angle);

  switch (axis) {
    case 'x':
      return [
        [1, 0, 0, 0],
        [0, cos, -sin, 0],
        [0, sin, cos, 0],
        [0, 0, 0, 1]
      ];
    case 'y':
      return [
        [cos, 0, sin, 0],
        [0, 1, 0, 0],
        [-sin, 0, cos, 0],
        [0, 0, 0, 1]
      ];
    case 'z':
      return [
        [cos, -sin, 0, 0],
        [sin, cos, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
      ];
  }
};


const getExtremes = array => array.reduce(
    function(previous, current, index) {
        if (!previous.maximum.value || (current == null)) {
            previous.maximum = (previous.minimum = {
                value: current,
                index
            });

        } else if (current > previous.maximum.value) {
            previous.maximum = {
                value: current,
                index
            };

        } else if (current < previous.minimum.value) {
            previous.minimum = {
                value: current,
                index
            };
        }

        return previous;
    }
    , {
    minimum: {
        value: null,
        index: null
    },
    maximum: {
        value: null,
        index: null
    }
}
);


const applyMatrixToPoint = function(matrix, point) {
  const newMatrix = Matrix.multiply(matrix, [
    [point.x],
    [point.y],
    [point.z],
    [1]
  ]);
  const newPoint = {
    x: newMatrix[0][0],
    y: newMatrix[1][0],
    z: newMatrix[2][0]
  };

  return newPoint;
};


const calculateGridAlignRotationAngle = function(
    param
  ) {
  if (param == null) { param = {}; }
  let {
    faces,
    rotationAxis,
    unit,
    histogram
  } = param;
  if (unit == null) { unit = 'radian'; }
  if (rotationAxis == null) { rotationAxis = 'z'; }

  const reduceToHistorgram = function(histogram, face) {
    if (histogram[face.nearestAngleInDegrees] == null) { histogram[face.nearestAngleInDegrees] = 0; }
    histogram[face.nearestAngleInDegrees] += face.surfaceArea;
    return histogram;
  };

  const angleSurfaceAreaHistogram = faces
  .filter(face => // Get all faces aligned along the rotationAxis
    Math.abs(face.normal[rotationAxis]) < 0.01).map(function(face) {
    face = Face
      .fromObject(face)
      .calculateSurfaceArea();

    // Get rotation angle
    const rotationAngle = (() => { switch (false) {
      case rotationAxis !== 'x':
        return Math.atan2(face.normal.z, face.normal.y);
      case rotationAxis !== 'y':
        return Math.atan2(face.normal.x, face.normal.z);
      case rotationAxis !== 'z':
        return Math.atan2(face.normal.y, face.normal.x);
    } })();

    // Calculate rotation angle modulo 90 deg
    const angleModulusHalfPi = (rotationAngle + Math.PI) % (Math.PI / 2);

    // Convert to deg and round to nearest integer
    face.nearestAngleInDegrees = Math.round(rad2deg(angleModulusHalfPi));

    return face;}).reduce(reduceToHistorgram, new Array(90));

  if (histogram) {
    return angleSurfaceAreaHistogram;
  }

  // Return angle with the largest surface area
  const angleInDegrees = getExtremes(angleSurfaceAreaHistogram).maximum.index;

  if ((unit === 'degree') || (unit === 'deg')) {
    return angleInDegrees;
  }

  return deg2rad(angleInDegrees);
};


const calculateGridAlignTranslation = function({faces, translationAxes, gridSize}) {
  const axes = ['x', 'y', 'z'];

  if (gridSize == null) { gridSize = {x: 1, y: 1, z: 1}; }
  if (translationAxes == null) { translationAxes = ['x', 'y']; }
  const returnObject = {};

  translationAxes.forEach(function(translationAxis) {
    const invariantAxes = axes.filter(axis => translationAxis.indexOf(axis) < 0);

    const offsetHistogram = faces
    .filter(face => (Math.abs(face.normal[invariantAxes[0]]) < 0.01) &&
                (Math.abs(face.normal[invariantAxes[1]]) < 0.01)).map(function(face) {
      face.normal[invariantAxes[0]] =
        modulo(face.normal[translationAxis], gridSize[translationAxis]);
      return face;}).map(function(face) {
      face.surfaceArea = Face.calculateSurfaceArea(face);
      return face;}).reduce(function(histogram, currentFace) {

      // Get offset in percentage of grid-size rounded to 1%

      const offsetPercentage = Math.round(
        (modulo(
          currentFace.vertices[0][translationAxis],
          gridSize[translationAxis]
        ) / gridSize[translationAxis]) * 100
      );

      if (histogram[offsetPercentage] == null) { histogram[offsetPercentage] = 0; }
      histogram[offsetPercentage] += currentFace.surfaceArea;

      return histogram;
    }

    , new Array(100));

    return returnObject[translationAxis] =
      -(gridSize[translationAxis] *
      getExtremes(offsetHistogram).maximum.index) / 100;
  });

  return returnObject;
};


const calculateAutoAlignMatrix = function(model, options) {
  if (options == null) { options = {}; }
  const rotationAxis = 'z';

  const transformations = [];

  const rotationAngle = calculateGridAlignRotationAngle({
    faces: model.mesh.faces,
    rotationAxis
  });
  transformations.unshift(getRotationMatrix({
    angle: -rotationAngle
  }));
  model.rotate({angle: -rotationAngle});

  const centeringMatrix = model.getCenteringMatrix();
  transformations.unshift(centeringMatrix);
  model.applyMatrix(centeringMatrix);

  const gridAlignTranslationMatrix = model.getGridAlignTranslationMatrix(options);
  transformations.unshift(gridAlignTranslationMatrix);

  return transformations.reduce((previous, current) => Matrix.multiply(previous, current));
};


// Abstracts the actual model from the external fluid api
export default class ExplicitModel {
  constructor(mesh, options) {
    this.clone = this.clone.bind(this);
    this.applyMatrix = this.applyMatrix.bind(this);
    this.translate = this.translate.bind(this);
    this.rotate = this.rotate.bind(this);
    this.buildFaceVertexMesh = this.buildFaceVertexMesh.bind(this);
    this.buildFacesFromFaceVertexMesh = this.buildFacesFromFaceVertexMesh.bind(this);
    this.setFaces = this.setFaces.bind(this);
    this.getFaces = this.getFaces.bind(this);
    this.fixFaces = this.fixFaces.bind(this);
    this.calculateNormals = this.calculateNormals.bind(this);
    this.calculateFaceSurfaceAreas = this.calculateFaceSurfaceAreas.bind(this);
    this.getSubmodels = this.getSubmodels.bind(this);
    this.getFaceWithLargestProjection = this.getFaceWithLargestProjection.bind(this);
    this.getGridAlignRotationAngle = this.getGridAlignRotationAngle.bind(this);
    this.getGridAlignRotationMatrix = this.getGridAlignRotationMatrix.bind(this);
    this.getGridAlignRotationHistogram = this.getGridAlignRotationHistogram.bind(this);
    this.applyGridAlignRotation = this.applyGridAlignRotation.bind(this);
    this.getCenteringMatrix = this.getCenteringMatrix.bind(this);
    this.center = this.center.bind(this);
    this.getGridAlignTranslationMatrix = this.getGridAlignTranslationMatrix.bind(this);
    this.applyGridAlignTranslation = this.applyGridAlignTranslation.bind(this);
    this.getStream = this.getStream.bind(this);
    this.mesh = mesh;
    this.options = options;
    if (this.mesh == null) { this.mesh = {
      faces: [],
      faceVertex: {}
    }; }
    this.transformations = [];
    if (this.options == null) { this.options = {}; }
    this.name = '';
    this.fileName = '';
    this.faceCount = '';
    this.normalsAreInvalid = false;
  }


  static fromBase64(base64String) {
    const data = buildMeshFromBase64(base64String);

    const model = new ExplicitModel({faceVertex: data.faceVertexMesh});
    model.name = data.name;

    return model;
  }


  clone() {
    const modelClone = new ExplicitModel();

    modelClone.mesh = fastClone(this.mesh);
    modelClone.transformations = fastClone(this.transformations);
    modelClone.options = fastClone(this.options);
    modelClone.name = this.name;
    modelClone.fileName = this.fileName;
    modelClone.faceCount = this.faceCount;

    return modelClone;
  }


  applyMatrix(matrix) {
    this.mesh.faces = this.mesh.faces.map(function(face) {
      face.vertices = face.vertices.map(vertex => applyMatrixToPoint(matrix, vertex));
      return face;
    });
    return this;
  }


  translate(vector) {
    if(Array.isArray(vector)) {
      vector = {
        x: Number(vector[0]),
        y: Number(vector[1]),
        z: Number(vector[2])
      };
    }

    this.mesh.faces.forEach(face => face.vertices.forEach(function(vertex) {
            vertex.x += vector.x || 0;
            vertex.y += vector.y || 0;
            return vertex.z += vector.z || 0;
        }));

    return this;
  }


  rotate(param) {
    if (param == null) { param = {}; }
    let {angle, axis, unit} = param;
    if (!angle) {
      return this;
    }

    if (unit == null) { unit = 'radian'; }
    if (axis == null) { axis = 'z'; }

    if (unit === 'degree') {
      angle = deg2rad(angle);
    }

    return this.applyMatrix(getRotationMatrix({axis, angle}));
  }


  buildFaceVertexMesh() {
    this.mesh.faceVertex = buildFaceVertexMesh(this.mesh.faces);
    return this;
  }


  buildFacesFromFaceVertexMesh() {
    this.mesh.faces = buildFacesFromFaceVertexMesh(this.mesh.faceVertex);
    return this;
  }


  setFaces(faces) {
    this.mesh.faces = faces;
    return this;
  }


  getFaces(options) {
    if (options == null) { options = {}; }
    if (this.normalsAreInvalid) {
      this.calculateNormals();
    }

    if (options.filter && (typeof options.filter === 'function')) {
      return this.mesh.faces.filter(options.filter);
    }

    return this.mesh.faces;
  }


  fixFaces() {
    const deletedFaces = [];

    if (this.mesh.faces) {
      this.mesh.faces = this.mesh.faces.map(function(face) {
        if (face.vertices.length === 3) {
          return face;

        } else if (face.vertices.length > 3) {
          deletedFaces.push(face);
          face.vertices = face.vertices.slice(0, 3);
          return face;

        } else if (face.vertices.length === 2) {
          face.addVertex(new Vector(0, 0, 0));
          return face;

        } else if (face.vertices.length === 1) {
          face.addVertex(new Vector(0, 0, 0));
          face.addVertex(new Vector(1, 1, 1));
          return face;

        } else {
          return null;
        }
      });
    } else {
      throw new NoFacesError;
    }
    return this;
  }


  calculateNormals() {
    if (this.mesh.faces) {
      this.mesh.faces = this.mesh.faces.map(function(face) {
        face = Face.fromVertexArray(face.vertices);

        const delta1 = Vector
          .fromObject(face.vertices[1])
          .subtract(Vector.fromObject(face.vertices[0]));

        const delta2 = Vector
          .fromObject(face.vertices[2])
          .subtract(Vector.fromObject(face.vertices[0]));

        face.normal = delta1
          .crossProduct(delta2)
          .normalize();

        return face.toObject();
      });
    } else {
      throw new NoFacesError;
    }

    return this;
  }


  calculateFaceSurfaceAreas() {
    return __range__(0, this.mesh.faces.length, false).map((index) =>
      (this.mesh.faces[index].surfaceArea = Face.calculateSurfaceArea(face)));
  }


  getSubmodels() {
    return geometrySplitter(this.mesh.faceVertex);
  }


  isTwoManifold() {
    if (this._isTwoManifold == null) { this._isTwoManifold = testTwoManifoldness(this.mesh.faceVertex); }
    return this._isTwoManifold;
  }


  getBoundingBox(param) {

    if (param == null) { param = {}; }
    let {recalculate, source} = param;
    if (recalculate == null) { recalculate = false; }
    if (source == null) { source = 'faces'; }

    if (!this._boundingBox || (recalculate === true)) {
      if (source === 'faceVertexMesh') {
        this._boundingBox = calculateBoundingBox.forFaceVertexMesh(
          this.mesh.faceVertex
        );
      } else if (source === 'faces') {
        this._boundingBox = calculateBoundingBox.forFaces(
          this.mesh.faces
        );
      }
    }

    return this._boundingBox;
  }


  getFaceWithLargestProjection() {
    let faceIndex = 0;

    this.mesh.faces
    .map(face => calculateProjectedFaceArea(face)).reduce(function(previous, current, currentIndex) {
      if (current > previous) {
        faceIndex = currentIndex;
      }
      return current;
    });

    return this.mesh.faces[faceIndex];
  }


  getGridAlignRotationAngle(options) {
    if (options == null) { options = {}; }
    options.faces = this.mesh.faces;
    return calculateGridAlignRotationAngle(options);
  }


  getGridAlignRotationMatrix(options) {
    if (options == null) { options = {}; }
    options.faces = this.mesh.faces;
    const rotationAngle = this.getGridAlignRotationAngle(options);
    return getRotationMatrix({angle: rotationAngle});
  }


  getGridAlignRotationHistogram(options) {
    if (options == null) { options = {}; }
    options.faces = this.mesh.faces;
    options.histogram = true;
    const histogram = calculateGridAlignRotationAngle(options);

    return (Array.from(histogram).map((value, index) => index + '\t' + (value || 0)))
      .join('\n');
  }


  applyGridAlignRotation(options) {
    if (options == null) { options = {}; }
    options.faces = this.mesh.faces;
    this.rotate({
      angle: -calculateGridAlignRotationAngle(options)
    });
    return this;
  }


  getCenteringMatrix() {
    const boundingBox = this.getBoundingBox({recalculate: true, source: 'faces'});

    return [
      [1, 0, 0, -(boundingBox.min.x +
      ((boundingBox.max.x - boundingBox.min.x) / 2)) ],
      [0, 1, 0, -(boundingBox.min.y +
      ((boundingBox.max.y - boundingBox.min.y) / 2)) ],
      [0, 0, 1, -boundingBox.min.z],
      [0, 0, 0, 1]
    ];
  }


  center() {
    this.applyMatrix(this.getCenteringMatrix());
    return this;
  }


  getGridAlignTranslationMatrix(options) {
    if (options == null) { options = {}; }
    options.faces = this.mesh.faces;
    const translation = calculateGridAlignTranslation(options);

    return [
      [1, 0, 0, translation.x],
      [0, 1, 0, translation.y],
      [0, 0, 1, 0],
      [0, 0, 0, 1]
    ];
  }


  applyGridAlignTranslation(options) {
    if (options == null) { options = {}; }
    options.faces = this.mesh.faces;
    this.translate(calculateGridAlignTranslation(options));
    return this;
  }


  getAutoAlignMatrix(options) {
    if (options == null) { options = {}; }
    return calculateAutoAlignMatrix(this.clone(), options);
  }


  forEachFace(callback) {
    const coordinates = this.mesh.faceVertex.vertexCoordinates;
    const indices = this.mesh.faceVertex.faceVertexIndices;
    const normalCoordinates = this.mesh.faceVertex.faceNormalCoordinates;

    for (let index = 0, end = indices.length - 1; index <= end; index += 3) {
      callback({
          vertices: [
            {
              x: coordinates[indices[index] * 3],
              y: coordinates[(indices[index] * 3) + 1],
              z: coordinates[(indices[index] * 3) + 2]
            },
            {
              x: coordinates[indices[index + 1] * 3],
              y: coordinates[(indices[index + 1] * 3) + 1],
              z: coordinates[(indices[index + 1] * 3) + 2]
            },
            {
              x: coordinates[indices[index + 2] * 3],
              y: coordinates[(indices[index + 2] * 3) + 1],
              z: coordinates[(indices[index + 2] * 3) + 2]
            }
          ],
          normal: {
            x: normalCoordinates[index],
            y: normalCoordinates[index + 1],
            z: normalCoordinates[index + 2]
          }
        },
        index / 3);
    }

    return this;
  }


  getBase64() {
    return convertToBase64(this.mesh.faceVertex) + '|' + this.name;
  }


  toObject() {
    return {
      name: this.name,
      fileName: this.fileName,
      faceCount: this.faceCount,
      mesh: this.mesh
    };
  }

  toJSON() { return this.toObject(); }

  getStream(options) {
    if (options == null) { options = {}; }
    return new ModelStream({
      name: this.name,
      fileName: this.fileName,
      faceCount: this.faceCount,
      mesh: this.mesh
    }, options);
  }
}

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}
