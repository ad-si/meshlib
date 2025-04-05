import ExplicitModel from './ExplicitModel.js'

export default class Model {
  constructor(mesh, options) {
    this.applyMatrix = this.applyMatrix.bind(this);
    this.getClone = this.getClone.bind(this);
    this.translate = this.translate.bind(this);
    this.rotate = this.rotate.bind(this);
    this.setName = this.setName.bind(this);
    this.setFileName = this.setFileName.bind(this);
    this.setFaces = this.setFaces.bind(this);
    this.getFaces = this.getFaces.bind(this);
    this.setFaceCount = this.setFaceCount.bind(this);
    this.getFaceVertexMesh = this.getFaceVertexMesh.bind(this);
    this.buildFaceVertexMesh = this.buildFaceVertexMesh.bind(this);
    this.fixFaces = this.fixFaces.bind(this);
    this.buildFacesFromFaceVertexMesh = this.buildFacesFromFaceVertexMesh.bind(this);
    this.calculateNormals = this.calculateNormals.bind(this);
    this.getSubmodels = this.getSubmodels.bind(this);
    this.isTwoManifold = this.isTwoManifold.bind(this);
    this.getBoundingBox = this.getBoundingBox.bind(this);
    this.getFaceWithLargestProjection = this.getFaceWithLargestProjection.bind(this);
    this.getGridAlignRotationAngle = this.getGridAlignRotationAngle.bind(this);
    this.getGridAlignRotationMatrix = this.getGridAlignRotationMatrix.bind(this);
    this.getGridAlignRotationHistogram = this.getGridAlignRotationHistogram.bind(this);
    this.applyGridAlignRotation = this.applyGridAlignRotation.bind(this);
    this.getGridAlignTranslationMatrix = this.getGridAlignTranslationMatrix.bind(this);
    this.applyGridAlignTranslation = this.applyGridAlignTranslation.bind(this);
    this.getCenteringMatrix = this.getCenteringMatrix.bind(this);
    this.center = this.center.bind(this);
    this.getAutoAlignMatrix = this.getAutoAlignMatrix.bind(this);
    this.autoAlign = this.autoAlign.bind(this);
    this.forEachFace = this.forEachFace.bind(this);
    this.getBase64 = this.getBase64.bind(this);
    this.getJSON = this.getJSON.bind(this);
    this.getObject = this.getObject.bind(this);
    this.getStream = this.getStream.bind(this);
    this.next = this.next.bind(this);
    this.done = this.done.bind(this);
    this.catch = this.catch.bind(this);
    this.ready = Promise.resolve().then(() => {
      return this.model = new ExplicitModel(mesh, options);
    });
    return this;
  }

  static fromObject(object, options) {
    return new Model(object.mesh, options)
    .setName(object.name)
    .setFileName(object.fileName)
    .setFaceCount(object.faceCount);
  }

  static fromFaces(faces, options) {
    return new Model({mesh: {faces}}, options);
  }

  static fromBase64(base64String) {
    return Model.fromObject(ExplicitModel.fromBase64(base64String));
  }

  applyMatrix(matrix) {
    return this.next(() => this.model.applyMatrix(matrix));
  }

  getClone() {
    return this.done(() => {
      const modelClone = new Model();

      return modelClone
      .done()
      .then(() => {
        modelClone.model = this.model.clone();
        return modelClone;
      });
    });
  }

  translate(vector) {
    return this.next(() => this.model.translate(vector));
  }

  rotate(options) {
    return this.next(() => this.model.rotate(options));
  }

  setName(name) {
    return this.next(() => { return this.model.name = name; });
  }

  setFileName(fileName) {
    return this.next(() => { return this.model.fileName = fileName; });
  }

  setFaces(faces) {
    return this.next(() => this.model.setFaces(faces));
  }

  getFaces(options) {
    return this.done(() => { return this.model.getFaces(options); });
  }

  setFaceCount(numberOfFaces) {
    return this.next(() => { return this.model.faceCount = numberOfFaces; });
  }

  getFaceVertexMesh() {
    return this.done(() => this.model.mesh.faceVertex);
  }

  buildFaceVertexMesh() {
    return this.next(() => this.model.buildFaceVertexMesh());
  }

  fixFaces() {
    return this.next(() => this.model.fixFaces());
  }

  buildFacesFromFaceVertexMesh() {
    return this.next(() => this.model.buildFacesFromFaceVertexMesh());
  }

  calculateNormals() {
    return this.next(() => this.model.calculateNormals());
  }

  getSubmodels() {
    return this.done(() => this.model.getSubmodels());
  }

  isTwoManifold() {
    return this.done(() => this.model.isTwoManifold());
  }

  getBoundingBox() {
    return this.done(() => this.model.getBoundingBox());
  }

  getFaceWithLargestProjection() {
    return this.done(() => this.model.getFaceWithLargestProjection());
  }


  getGridAlignRotationAngle(options) {
    return this.done(() => this.model.getGridAlignRotationAngle(options));
  }

  getGridAlignRotationMatrix(options) {
    return this.done(() => this.model.getGridAlignRotationMatrix(options));
  }

  getGridAlignRotationHistogram(options) {
    return this.done(() => this.model.getGridAlignRotationHistogram(options));
  }

  applyGridAlignRotation(options) {
    return this.next(() => this.model.applyGridAlignRotation(options));
  }


  getGridAlignTranslationMatrix(options) {
    return this.done(() => this.model.getGridAlignTranslationMatrix(options));
  }

  applyGridAlignTranslation(options) {
    return this.next(() => this.model.applyGridAlignTranslation(options));
  }


  getCenteringMatrix(options) {
    return this.done(() => this.model.getCenteringMatrix(options));
  }

  center(options) {
    return this.next(() => this.model.center(options));
  }


  getAutoAlignMatrix(options) {
    return this.done(() => this.model.getAutoAlignMatrix(options));
  }

  autoAlign(param) {
    if (param == null) { param = {}; }
    const {gridSize} = param;
    return this.next(() => this.model)
      .applyGridAlignRotation()
      .center()
      .applyGridAlignTranslation({
        gridSize
      });
  }


  forEachFace(callback) {
    return this.next(() => this.model.forEachFace(callback));
  }

  getBase64() {
    return this.done(() => this.model.getBase64());
  }

  getJSON(replacer, space) {
    return this.done(() => JSON.stringify(this.model, replacer, space));
  }

  getObject() {
    return this.done(() => this.model.toObject());
  }

  getStream(options) {
    return this.done(() => this.model.getStream(options));
  }


  next(onFulfilled, onRejected) {
    this.done(onFulfilled, onRejected);
    return this;
  }

  done(onFulfilled, onRejected) {
    const onFulfilledTemp = () => (typeof onFulfilled === 'function' ? onFulfilled(this.model) : undefined);
    this.ready = this.ready.then(onFulfilledTemp, onRejected);
    return this.ready;
  }

  catch(onRejected) {
    this.ready = this.ready.catch(onRejected);
    return this.ready;
  }
}
