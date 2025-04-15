// Basic declaration file for @datatypes/vector
declare module '@datatypes/vector' {
  // Add specific types if known, otherwise use 'any' as a placeholder
  class Vector {
    x: number;
    y: number;
    z: number;
    constructor(x: number, y: number, z: number);
    static fromObject(obj: { x: number; y: number; z: number }): Vector;
    subtract(other: Vector): Vector;
    crossProduct(other: Vector): Vector;
    normalize(): Vector;
    length(): number;
    // Add other methods/properties as needed
  }
  export default Vector;
}
