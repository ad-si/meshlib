// Basic declaration file for @datatypes/matrix
declare module '@datatypes/matrix' {
  type Matrix4x4 = [
    [number, number, number, number],
    [number, number, number, number],
    [number, number, number, number],
    [number, number, number, number]
  ];
  type MatrixNx1 = number[][]; // Or define more specifically if needed

  class Matrix {
    static multiply(matrixA: Matrix4x4 | MatrixNx1, matrixB: Matrix4x4 | MatrixNx1): Matrix4x4 | MatrixNx1;
    // Add other static methods if known
  }
  export default Matrix;
}
