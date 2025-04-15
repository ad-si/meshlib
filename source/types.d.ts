export interface ModelOptions extends ExplicitModelOptions {
  [key: string]: unknown
}

export interface GetFacesOptions {
  filter?: (face: FaceObject) => boolean
}

export interface ModelObjectData {
  name?: string
  fileName?: string
  faceCount?: number | string
  mesh: MeshData
}
