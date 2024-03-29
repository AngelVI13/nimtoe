const
  Rows* = 3
  BoardSize* = Rows*Rows


type Mark* = enum
  markO = -1, markNoPlayer = 0, markX = 1

const
  NoWinner* = -1.0
  Loss* = 0.0
  Draw* = 0.5
  Win* = 1.0

type ResultLines* = array[0..Rows-1, array[Rows, int]]


proc getColumnArray(): ResultLines =
  for i in 0..Rows-1:
    var idx = 0
    for j in countup(i, BoardSize-1, Rows):
      result[i][idx] = j
      inc(idx)

proc getRowArray(columnArr: ResultLines): ResultLines =
  for i in 0..Rows-1:
    for j in 0..Rows-1:
      result[i][j] = columnArr[j][i]

proc getDiagonalArray(rowArr: ResultLines): ResultLines =
  for i in 0..Rows-1:
    for j in 0..Rows-1:
      case j:
        of 0: result[j][i] = rowArr[i][i]  # left diagonal -> 0,0| 1,1| 2,2
        of 1: result[j][i] = rowArr[i][Rows-i-1]  # right diagonal 0,2 | 1,1| 2,0
        else: result[j][i] = -1
    # Additional -1 is needed to convert from size to index

proc getResultLines*(): array[Rows, ResultLines] =
  var columns = getColumnArray()
  var rows = getRowArray(columns)
  var diags = getDiagonalArray(rows)

  result[0] = columns
  result[1] = rows
  result[2] = diags


when isMainModule:
  echo getResultLines()

