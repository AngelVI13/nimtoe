import algorithm
import board
import defines
import math
import strformat


type
  Node* = ref object
    move*: int
    parent*: Node
    childNodes*: seq[Node]
    wins*: float32
    visits*: float32
    untriedMoves*: seq[int]
    playerJustMoved*: Mark

method update*(this: Node, game_result: float) {.base.} =
  this.visits += 1.0
  this.wins += game_result

method addChild*(this: Node, move: int, state: Board): Node {.base.} =
  new(result)
  result.move = move
  result.parent = this
  result.untriedMoves = state.getMoves()
  result.playerJustMoved = state.playerJustMoved
  
  this.childNodes.add(result)

  var moveIdx = -1
  for idx, m in this.untriedMoves:
    if move == m:
      moveIdx = idx
  
  if moveIdx != -1:
    this.untriedMoves.delete(moveIdx)
  else:
    echo fmt("Couldn't find move in untried moves {move}")

proc ucb1(n: Node): float =
  result = (n.wins/n.visits) + sqrt(2*ln(n.visits)/n.visits)
    
proc ucb1Compare(x, y: Node): int =
  if ucb1(x) < ucb1(y): -1 else: 1

method uctSelectChild*(this: Node): Node {.base.} =
  var sortedNodes = sorted(this.childNodes, ucb1Compare)
  echo "Sorted child nodes"
  for n in sortedNodes:
    echo ucb1(n)
  echo "End of child nodes"
  result = sortedNodes[^1]

proc createRootNode*(state: Board): Node =
  new(result)
  result.untriedMoves = state.getMoves()
  result.playerJustMoved = state.playerJustMoved

when isMainModule:
  var b = createBoard()
  var rootnode = createRootNode(state=b)
  echo rootnode.untriedMoves, rootnode.parent == nil
