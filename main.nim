import board
import defines
import uct
import strutils
import strformat


when isMainModule:
  var b = createBoard()
  while b.getResult(b.playerJustMoved) == NoWinner:
    if b.playerJustMoved == markO:
      var availableMoves = b.getMoves()
      echo fmt("Enter move (available: {availableMoves})>")
      var move = parseInt(readLine(stdin))
      assert move in availableMoves
      b.makeMove(move)
      echo b
    else:
      echo "Engine thinking..."
      var move = getEngineMove(b, 100000)
      b.makeMove(move)
      echo fmt("Engine makes move {move}")
      echo b

  case b.getResult(markO)
    of Draw: echo "Draw!"
    of Win: echo "O wins"
    of Loss: echo "X wins"