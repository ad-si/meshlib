import { MeshData } from './ExplicitModel.js'
import Model from './Model.js'
import ModelBuilder from './ModelBuilder.js'
import { ModelOptions } from './types.js'

export default function meshlib (
  modelData: MeshData | null | undefined,
  options?: ModelOptions
): Model {
  return new Model(modelData, options)
}
meshlib.Model = Model
meshlib.ModelBuilder = ModelBuilder
