import node
import board
import defines
import random
import algorithm
import strformat


randomize()  # generates a random seed

type
  Score = tuple
    wins: float32
    visits: float32

  RankedMove = tuple
    score: float
    move: int

proc visitsCmp(x,y: Node): int =
  if x.visits < y.visits: -1 else: 1

proc uct*(rootstate: Board, itermax: int): Score =
  var rootnode = createRootNode(rootstate)

  var state = rootstate
  for i in 0..<itermax:
    var node = rootnode
    var movesToRoot: int = 0

    # Select stage
    # node is fully expanded and non-terminal
    while len(node.untriedMoves) == 0 and len(node.childNodes) > 0:
      node = node.uctSelectChild()
      state.makeMove(node.move)
      inc(movesToRoot)

    # Expand
    # if we can expand (i.e. state/node is non-terminal)
    if len(node.untriedMoves) > 0:
      var move = sample(node.untriedMoves)
      state.makeMove(move)
      inc(movesToRoot)
      # add child and descend tree
      node = node.addChild(move=move, state=state)

    # Rollout
    #  - this can often be made orders of magnitude quicker
    #    using a state.GetRandomMove() function

    # while state is non-terminal
    while state.getResult(state.playerJustMoved) == NoWinner:
      var m = sample(state.getMoves())
      state.makeMove(m)
      inc(movesToRoot)

    # Backpropagate
    # backpropagate from the expanded node and work back to the root node
    while node != nil:
      # state is terminal.
      # Update node with result from POV of node.playerJustMoved
      var gameResult = state.getResult(node.playerJustMoved)
      node.update(gameResult)
      node = node.parent

    for j in 0..<movesToRoot:
      state.takeMove()

  var sortedNodes = sorted(rootnode.childNodes, visitsCmp)
  var bestNode = sortedNodes[^1]
  result = (wins: bestNode.wins, visits: bestNode.visits)

proc getEngineMove*(state: Board, simulations: int): int =
  var availableMoves = state.getMoves()
  var simPerMove = int(simulations / len(availableMoves))

  var bestMove: RankedMove = (score: 1.0, move: BoardSize + 1)
  for move in availableMoves:
    var b = state
    b.makeMove(move)
    var score = uct(b, itermax=simPerMove)
    var move_score = score.wins/score.visits
    echo fmt("Move: {move} : {move_score}")
    # here the move_score refers to the best enemy reply
    # therefore we want to minimize that i.e. chose the move
    # which leads to the lowest scored best enemy reply
    if move_score < bestMove.score:
      bestMove.score = move_score
      bestMove.move = move

  result = bestMove.move

when isMainModule:
  import times
  var currentTime = cpuTime()

  var rootstate = createBoard()
  for move in rootstate.getMoves():
    var state = rootstate
    state.makeMove(move)
    var score = uct(state, itermax=50000)
    echo fmt("Move: {move} : {score}, {score[0]/score[1]}%")

  echo fmt("Elapsed time {cpuTime()-currentTime}")
