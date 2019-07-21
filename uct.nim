import node
import board
import defines
import random
import algorithm
import strformat


# randomize()  # generates a random seed

type Score = tuple
  wins: float32
  visits: float32

proc visitsCmp(x,y: Node): int = 
  if x.visits < y.visits: -1 else: 1

proc uct*(rootstate: Board, itermax: int): Score =
  var rootnode = createRootNode(rootstate)

  var state = rootstate
  for i in 0..<itermax:
    # echo "root ", rootnode.untriedMoves, " ", rootnode.parent == nil, " ", len(rootnode.childNodes)
    # echo fmt("Starting state\n{state}")
    var node = rootnode
    var movesToRoot: int = 0

    # Select stage
    # node is fully expanded and non-terminal
    while len(node.untriedMoves) == 0 and len(node.childNodes) > 0:
      node = node.uctSelectChild()
      # echo "Select ", node.untriedMoves, " ", node.parent == nil, " ", len(node.childNodes)
      state.makeMove(node.move)
      # echo fmt("Select. make node move {node.move} -> pos\n{state}")
      inc(movesToRoot)

    # Expand
    # if we can expand (i.e. state/node is non-terminal)
    if len(node.untriedMoves) > 0:
      var move = sample(node.untriedMoves)
      # echo node.untriedMoves
      # echo fmt("Expand. move {move}")
      state.makeMove(move)
      # echo fmt("Expand resulting state\n {state}")
      inc(movesToRoot)
      # add child and descend tree
      node = node.addChild(move=move, state=state)
      # echo "Expand ", node.untriedMoves, " ", node.parent == nil, " ", len(node.childNodes)

    # Rollout - this can often be made orders of magnitude quicker using a state.GetRandomMove() function
    # while state is non-terminal
    while state.getResult(state.playerJustMoved) == NoWinner:
      var m = sample(state.getMoves())
      # echo fmt("Rollout. sample move {m}")
      state.makeMove(m)
      # echo fmt("Rollout. pos\n {state}")
      inc(movesToRoot)

    # echo fmt("Terminal node is reached - pos\n{state}")
    # Backpropagate
    # backpropagate from the expanded node and work back to the root node
    while node != nil:
      # state is terminal. Update node with result from POV of node.playerJustMoved
      var gameResult = state.getResult(node.playerJustMoved)
      node.update(gameResult)
      node = node.parent

    for j in 0..<movesToRoot:
      state.takeMove()

  # echo fmt("Final node stats: Children: {len(rootnode.childNodes)}, UntriedMoves: {rootnode.untriedMoves}, Score: {rootnode.wins} / {rootnode.visits}")
  var sortedNodes = sorted(rootnode.childNodes, visitsCmp)
  var bestNode = sortedNodes[^1]
  result = (wins: bestNode.wins, visits: bestNode.visits)

when isMainModule:
  var rootstate = createBoard()
  for move in rootstate.getMoves():
    echo fmt("Starting pos\n{rootstate}")
    var state = rootstate
    state.makeMove(move)
    echo fmt("Analyzing score for move {move} and pos\n {state}")
    var score = uct(state, itermax=10)
    echo fmt("Move: {move} : {score}")
    # break

              