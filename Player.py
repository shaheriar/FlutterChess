import chess
from cairosvg import svg2png
from Points import piecePoints
import Points
from MoveEval import MoveEval
from math import inf
import json


class Player:
    # parameters
    recommendMoves = False

    def __init__(self, recommendMoves):
        self.recommendMoves = recommendMoves

    def recommend(self, board, depth, turn, alpha, beta):
        #boardCopy = copy.deepcopy(board)
        if depth == 0 or board.is_checkmate() or board.is_stalemate():
            eval = Points.heuristic(board,turn)
            endEval = MoveEval("empty", eval)
            return endEval

        if(not turn): 
            maxValue = MoveEval("", -inf)
            for i in board.legal_moves:
                #boardCopy = copy.deepcopy(board)
                # print(boardCopy)
                # print('\n')
                board.push(i)
                value = self.recommend(board, depth - 1, True, alpha, beta)
                board.pop()
                # print(value)
                if(value.evaluation >= maxValue.evaluation):
                    maxValue = value
                    maxValue.move = i.uci()
                if (maxValue.evaluation >= alpha.evaluation):
                    alpha = maxValue
                if (beta.evaluation <= alpha.evaluation):
                    break
            return maxValue
        else:
            minValue = MoveEval("", inf)
            for i in board.legal_moves:
                #boardCopy = copy.deepcopy(board)
                # print(boardCopy)
                # print('\n')
                board.push(i)
                value = self.recommend(board, depth - 1, False, alpha, beta)
                board.pop()
                # print(value)
                if(value.evaluation <= minValue.evaluation):
                    minValue = value
                    minValue.move = i.uci()
                if (minValue.evaluation <= beta.evaluation):
                    beta = minValue
                if (beta.evaluation <= alpha.evaluation):
                    break
            return minValue

    async def makeMove(self, board, depth, turn, client):
        if(self.recommendMoves == True):
            print('\nRECOMMENDED MOVE:',self.recommend(board, depth, turn, MoveEval("",-inf),MoveEval("",inf)).move)
        while(1):
            move = await client.recv()
            print(move, "\n")
            # dataParsed = ast.literal_eval(data)
            movedata = json.loads(move)
            if (movedata['status'] != 'inprogress'):
                print('returning same')
                return board
            movefrom = chess.SQUARES[movedata['from']]
            print(movefrom)
            moveto = chess.SQUARES[movedata['to']]
            print(moveto)
            try:
                board.push(board.find_move(from_square=movefrom,to_square=moveto))
                return (board)
                # history.append(board.fen())
            except:
                print('INVALID MOVE\n')
            
