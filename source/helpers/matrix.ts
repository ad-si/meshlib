export type Matrix4x4 = [
  [number, number, number, number],
  [number, number, number, number],
  [number, number, number, number],
  [number, number, number, number],
]

export function multiplyMatrices (a: Matrix4x4, b: Matrix4x4): Matrix4x4 {
  const cell = (row: number, column: number) =>
    (a[row][0] * b[0][column]) +
    (a[row][1] * b[1][column]) +
    (a[row][2] * b[2][column]) +
    (a[row][3] * b[3][column])
  const row = (index: number): Matrix4x4[number] =>
    [cell(index, 0), cell(index, 1), cell(index, 2), cell(index, 3)]

  return [row(0), row(1), row(2), row(3)]
}
