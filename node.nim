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

# Todo pointer to state ?
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

method ucb1(this: Node, n: Node): float {.base.} =
  result = (n.wins/n.visits) + sqrt(2*ln(this.visits)/n.visits)

method uctSelectChild*(this: Node): Node {.base.} =
  # Find most promising child by comparing their ucb1 scores
  # If score is bigger than the biggest current score -> update current biggest
  var bestChildIndex = 0
  var bestChildScore = 0.0

  for idx, child in this.childNodes:
    var childScore = this.ucb1(child)
    if childScore > bestChildScore:
      bestChildScore = childScore
      bestChildIndex = idx

  result = this.childNodes[bestChildIndex]

proc createRootNode*(state: Board): Node =
  new(result)
  result.untriedMoves = state.getMoves()
  result.playerJustMoved = state.playerJustMoved

when isMainModule:
  var b = createBoard()
  var rootnode = createRootNode(state=b)
  echo rootnode.untriedMoves, rootnode.parent == nil
