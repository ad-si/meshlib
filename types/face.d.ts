declare module '@datatypes/face' {
  import Vector from '@datatypes/vector'

  interface Vertex {
    x: number
    y: number
    z: number
  }

  interface FaceObject {
    vertices: Vertex[]
    normal: {
      x: number
      y: number
      z: number
    }
    surfaceArea?: number
    nearestAngleInDegrees?: number
    attribute?: unknown
  }

  class Face {
    vertices: Vertex[]
    normal: {
      x: number
      y: number
      z: number
    }
    surfaceArea?: number
    nearestAngleInDegrees?: number
    attribute?: unknown

    constructor(vertices: Vertex[], normal: {
      x: number
      y: number
      z: number
    })
    static fromObject(obj: FaceObject): Face
    static fromVertexArray(vertices: Vertex[]): Face
    calculateSurfaceArea(): Face
    toObject(): FaceObject
    addVertex(vertex: Vector): void

  }
  export default Face
}
