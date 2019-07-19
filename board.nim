from defines import BoardSize, Rows, Mark, getResultLines, ResultLines


type Board = object
  pos: array[BoardSize, Mark]
  playerJustMoved: Mark
  history: seq[int]
  resultLines: array[Rows, ResultLines]

method getMoves(this: Board): seq[int] {.base.} =
  for i in low(this.pos)..high(this.pos):
    if this.pos[i] == markNoPlayer:
      result.add(i)

method makeMove(this: var Board, move: int) {.base.} =
  this.playerJustMoved = case this.playerJustMoved:
  of markO: markX
  of markX: markO
  else: markNoPlayer

  this.pos[move] = this.playerJustMoved
  this.history.add(move)

method takeMove(this: var Board) {.base.} =
  var historyLength = len(this.history)

  if historyLength > 0:
    var lastIdx = historyLength - 1
    this.pos[this.history[lastIdx]] = markNoPlayer
    this.history.delete(lastIdx)
  else:
    echo "History is empty"


proc createBoard*(): Board =
  result = Board(playerJustMoved: markO, resultLines: getResultLines())


when isMainModule:
  var
      b = createBoard()

  echo b.getMoves()
