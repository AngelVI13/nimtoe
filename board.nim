import defines
import system


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

method evaluateLines(this: Board, lines: ResultLines, playerJm: Mark): float {.base.} =
  for i in low(lines)..high(lines):
    var line = lines[i]

    result = 0
    for j in low(line)..high(line):
      result += float(this.pos[line[j]])

    if int(abs(result)) == Rows:
      var potential_winner = line[0]
      if potential_winner == int(playerJm):
        return Win
      else:
        return Loss

method getResult(this: Board, playerJM: Mark): float {.base.} =
  for i in low(this.resultLines)..high(this.resultLines):
    var line_eval = this.evaluateLines(this.resultLines[i], playerJM)
    if line_eval != NoWinner: return line_eval

  if len(this.getMoves()) == 0: return Draw

  return NoWinner

proc createBoard*(): Board =
  result = Board(playerJustMoved: markO, resultLines: getResultLines())


when isMainModule:
  var
      b = createBoard()

  echo b.getMoves()
  b.makeMove(0)
  b.makeMove(1)
  b.makeMove(3)
  b.makeMove(4)
  b.makeMove(6)
  echo b.pos
  echo b.getResult(b.playerJustMoved)