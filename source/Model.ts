import ExplicitModel, {
  MeshData, RotationOptions, TranslateVector,
  GetBoundingBoxOptions, GridAlignRotationOptions, GridAlignTranslationOptions,
  FaceVertexData, BoundingBox
  } from './ExplicitModel.js'
import ModelStream, { ModelStreamOptions } from './ModelStream.js'
import { FaceObject } from '@datatypes/face'
import { Matrix4x4 } from '@datatypes/matrix'
import { GetFacesOptions, ModelObjectData, ModelOptions } from './types.js'


export default class Model {
  // Declare properties
  private model!: ExplicitModel; // Definite assignment assertion
  private ready: Promise<ExplicitModel>

  constructor(mesh: MeshData | null | undefined, options?: ModelOptions) { // Add types
    this.applyMatrix = this.applyMatrix.bind(this)
    this.getClone = this.getClone.bind(this)
    this.translate = this.translate.bind(this)
    this.rotate = this.rotate.bind(this)
    this.setName = this.setName.bind(this)
    this.setFileName = this.setFileName.bind(this)
    this.setFaces = this.setFaces.bind(this)
    this.getFaces = this.getFaces.bind(this)
    this.setFaceCount = this.setFaceCount.bind(this)
    this.getFaceVertexMesh = this.getFaceVertexMesh.bind(this)
    this.buildFaceVertexMesh = this.buildFaceVertexMesh.bind(this)
    this.fixFaces = this.fixFaces.bind(this)
    this.buildFacesFromFaceVertexMesh = this.buildFacesFromFaceVertexMesh.bind(this)
    this.calculateNormals = this.calculateNormals.bind(this)
    this.getSubmodels = this.getSubmodels.bind(this)
    this.isTwoManifold = this.isTwoManifold.bind(this)
    this.getBoundingBox = this.getBoundingBox.bind(this)
    this.getFaceWithLargestProjection = this.getFaceWithLargestProjection.bind(this)
    this.getGridAlignRotationAngle = this.getGridAlignRotationAngle.bind(this)
    this.getGridAlignRotationMatrix = this.getGridAlignRotationMatrix.bind(this)
    this.getGridAlignRotationHistogram = this.getGridAlignRotationHistogram.bind(this)
    this.applyGridAlignRotation = this.applyGridAlignRotation.bind(this)
    this.getGridAlignTranslationMatrix = this.getGridAlignTranslationMatrix.bind(this)
    this.applyGridAlignTranslation = this.applyGridAlignTranslation.bind(this)
    this.getCenteringMatrix = this.getCenteringMatrix.bind(this)
    this.center = this.center.bind(this)
    this.getAutoAlignMatrix = this.getAutoAlignMatrix.bind(this)
    this.autoAlign = this.autoAlign.bind(this)
    this.forEachFace = this.forEachFace.bind(this)
    this.getBase64 = this.getBase64.bind(this)
    this.getJSON = this.getJSON.bind(this)
    this.getObject = this.getObject.bind(this)
    this.getStream = this.getStream.bind(this)
    this.next = this.next.bind(this)
    this.done = this.done.bind(this)
    this.catch = this.catch.bind(this)
    this.ready = Promise.resolve().then(() => {
      return this.model = new ExplicitModel(mesh, options)
    })
    return this
  }

  static fromObject(object: ModelObjectData, options?: ModelOptions): Model {
    const modelInstance = new Model(object.mesh, options)
    // Chain assignments after construction, potentially using .next if async init is complex
    if (object.name) modelInstance.setName(object.name)
      if (object.fileName) modelInstance.setFileName(object.fileName)
      if (object.faceCount !== undefined) modelInstance.setFaceCount(object.faceCount)
      return modelInstance
  }

  static fromFaces(faces: FaceObject[], options?: ModelOptions): Model {
    // Ensure mesh structure is correct
    return new Model({ faces: faces, faceVertex: undefined }, options)
  }

  static fromBase64(base64String: string): Model {
    try {
      // Create explicit model first
      const explicitModel = ExplicitModel.fromBase64(base64String)

      // Create a model with null mesh first (we'll set it manually)
      const model = new Model(null, {})

      // Set the model's internal ExplicitModel and resolve the ready promise
      model.model = explicitModel
      model.ready = Promise.resolve(explicitModel)

      return model
    } catch (error) {
      console.error("Error creating model from base64:", error)
      // Return empty model instead of throwing
      return new Model({ faces: [] }, {})
    }
  }

  applyMatrix(matrix: Matrix4x4): this {
    return this.next(() => this.model.applyMatrix(matrix))
  }

  getClone(): Promise<Model> {
    // Cloning involves creating a new Model instance asynchronously
    return this.done(currentModel => {
        const clonedExplicitModel = currentModel.clone()
        // Create a new Model wrapper for the cloned ExplicitModel
        const modelClone = new Model(null, {}); // Start with null mesh
        // Manually set the internal model and resolve the ready promise
        modelClone.model = clonedExplicitModel
        modelClone.ready = Promise.resolve(clonedExplicitModel)
        return modelClone
      })
  }

  translate(vector: TranslateVector | [number, number, number]): this {
    return this.next(() => this.model.translate(vector))
  }

  rotate(options: RotationOptions): this {
    return this.next(() => this.model.rotate(options))
  }

  setName(name: string): this {
    return this.next(() => { this.model.name = name; })
  }

  setFileName(fileName: string): this {
    return this.next(() => { this.model.fileName = fileName; })
  }

  setFaces(faces: FaceObject[] | null): this {
    return this.next(() => this.model.setFaces(faces))
  }

  getFaces(options?: GetFacesOptions): Promise<FaceObject[]> {
    return this.done(model => model.getFaces(options))
  }

  setFaceCount(numberOfFaces: number | string): this {
    return this.next(() => { this.model.faceCount = numberOfFaces; })
  }

  getFaceVertexMesh(): Promise<FaceVertexData | undefined> { // Use FaceVertexData type
    return this.done(model => model.mesh.faceVertex)
  }

  buildFaceVertexMesh(): this {
    return this.next(() => this.model.buildFaceVertexMesh())
  }

  fixFaces(): this {
    return this.next(() => this.model.fixFaces())
  }

  buildFacesFromFaceVertexMesh(): this {
    return this.next(() => this.model.buildFacesFromFaceVertexMesh())
  }

  calculateNormals(): this {
    return this.next(() => this.model.calculateNormals())
  }

  getSubmodels(): Promise<any[]> { // Need to keep as any[] for compatibility with tests
    return this.done(model => model.getSubmodels())
  }

  isTwoManifold(): Promise<boolean> {
    return this.done(model => model.isTwoManifold())
  }

  getBoundingBox(): Promise<BoundingBox | undefined> { // Use BoundingBox type
    return this.done(model => model.getBoundingBox())
  }

  getFaceWithLargestProjection(): Promise<FaceObject | undefined> {
    return this.done(model => model.getFaceWithLargestProjection())
  }


  getGridAlignRotationAngle(options?: Partial<GridAlignRotationOptions>): Promise<number | number[]> {
    return this.done(model => model.getGridAlignRotationAngle(options))
  }

  getGridAlignRotationMatrix(options?: Partial<GridAlignRotationOptions>): Promise<Matrix4x4> {
    return this.done(model => model.getGridAlignRotationMatrix(options))
  }

  getGridAlignRotationHistogram(options?: Partial<GridAlignRotationOptions>): Promise<string> {
    return this.done(model => model.getGridAlignRotationHistogram(options))
  }

  applyGridAlignRotation(options?: Partial<GridAlignRotationOptions>): this {
    return this.next(() => this.model.applyGridAlignRotation(options))
  }


  getGridAlignTranslationMatrix(options?: Partial<GridAlignTranslationOptions>): Promise<Matrix4x4> {
    return this.done(model => model.getGridAlignTranslationMatrix(options))
  }

  applyGridAlignTranslation(options?: Partial<GridAlignTranslationOptions>): this {
    return this.next(() => this.model.applyGridAlignTranslation(options))
  }


  getCenteringMatrix(options?: GetBoundingBoxOptions): Promise<Matrix4x4> {
    // Note: ExplicitModel.getCenteringMatrix doesn't take options in current code
    return this.done(model => model.getCenteringMatrix())
  }

  center(options?: GetBoundingBoxOptions): this {
     // Note: ExplicitModel.center doesn't take options in current code
    return this.next(() => this.model.center())
  }


  getAutoAlignMatrix(options?: Partial<GridAlignTranslationOptions>): Promise<Matrix4x4> {
    return this.done(model => model.getAutoAlignMatrix(options))
  }

  autoAlign(param: GridAlignTranslationOptions = { faces: [] }): this {
    // Chain the individual steps asynchronously using .next
    return this
      .next(() => this.model.calculateNormals()) // Ensure normals are calculated first
      .applyGridAlignRotation(param) // Pass options if needed
      .center() // Pass options if needed
      .applyGridAlignTranslation(param); // Pass options
  }


  forEachFace(callback: (face: FaceObject, index: number) => void): this {
    return this.next(() => this.model.forEachFace(callback))
  }

  getBase64(): Promise<string> {
    return this.done(model => model.getBase64())
  }

  getJSON(replacer?: ((key: string, value: unknown) => unknown) | null, space?: string | number): Promise<string> {
    // JSON.stringify happens synchronously after the model is ready
    return this.done(model => JSON.stringify(model.toObject(), replacer, space))
  }

  getObject(): Promise<ModelObjectData> { // Use ModelObjectData type
    return this.done(model => model.toObject())
  }

  getStream(options?: ModelStreamOptions): Promise<ModelStream> {
    return this.done(model => model.getStream(options))
  }


  // Helper methods for promise chaining
  private next(
    onFulfilled: (model: ExplicitModel) => unknown,
    onRejected?: (reason: unknown) => unknown
  ): this {
    // @ts-expect-error  Type 'Promise<unknown>' is not assignable
    this.ready = this.ready.then(onFulfilled, onRejected)
    return this
  }

  public done<TResult1 = ExplicitModel, TResult2 = never>(
    onFulfilled?: ((model: ExplicitModel) => TResult1 | PromiseLike<TResult1>) | undefined | null,
    onRejected?: ((reason: unknown) => TResult2 | PromiseLike<TResult2>) | undefined | null
  ): Promise<TResult1 | TResult2> {
    // Create a separate promise that resolves with the result of onFulfilled
    const resultPromise = this.ready.then<TResult1, TResult2>(onFulfilled as any, onRejected as any)

    // Keep the original ready promise chain intact for subsequent 'next' calls
    this.ready = this.ready.then(model => model, onRejected as any)

    // Return the separate promise with the actual results
    return resultPromise
  }

  catch<TResult = never>(
     onRejected?: ((reason: unknown) => TResult | PromiseLike<TResult>) | undefined | null
  ): Promise<ExplicitModel | TResult> {
    this.ready = this.ready.catch(onRejected as any)
    return this.ready as Promise<ExplicitModel | TResult>
  }
}
