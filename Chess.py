from AI import AI
import chess
import ast
from Player import Player
import json
# import os
from datetime import datetime
from Points import heuristic, piecePoints
import time
# ------------------------------------------
# import chess.svg
# from cairosvg import svg2png
# from PIL import Image
# import matplotlib.pyplot as plt
# from io import BytesIO
# ------------------------------------------


def symbolprint(board):
    print(board.unicode(invert_color=True))


arr = ['\nWHITE\'S TURN\n', '\nBLACK\'S TURN\n']
# player1 = None
# player2 = None
# AI = None


class chessGame:
    #Points = 0

    async def menu(self, client):
        global player1
        global player2
        global AIPlayer
        global userColorForAIMode
        mode = 0
        print('------------------------------')
        print('Smart Chess by The Segfaults')
        print('------------------------------')

        data = await client.recv()
        print(data, "\n")
        # dataParsed = ast.literal_eval(data)
        dataParsed = json.loads(data)
        print(dataParsed, "\n")

        if(dataParsed["gamemode"] == 1):
            player1 = Player(dataParsed["player1"])
            player2 = Player(dataParsed["player2"])
            return 1
        elif(dataParsed["gamemode"] == 2):
            player1 = Player(dataParsed["player1"])
            AIPlayer = AI(False, 0)
            userColorForAIMode = dataParsed["usercolor"]
            return 2
        elif(dataParsed["gamemode"] == 3):
            player1 = AI(False, 0)
            player2 = AI(False, 0)
            return 3

        return

    async def start(self, gameMode, client):
        turn = False  # WHITE IS 0, BLACK IS 1
        numberOfMoves = 0
        isGameOver = None
        board = chess.Board()
        history = []
        lastmove = None
        while (not board.is_checkmate() or not board.is_stalemate() or not board.is_fivefold_repetition()):
            # isGameOver = await client.recv()

            print('\n')
            print('-----------')
            print('Smart Chess')
            print('-----------')

            symbolprint(board)

            print('-----------')
            print(arr[turn])
            # print('SCORE: ', heuristic(board, turn))
            if (board.is_checkmate()):
                print('GAME ENDED BY CHECKMATE')
                if turn == 1:
                    print("White Wins")
                    moveData = {"move": board.peek().uci(), "board": boardlist, "status": "checkmate", "winner": "white"}
                    await client.send(json.dumps(moveData))
                else:
                    moveData = {"move": board.peek().uci(), "board": boardlist, "status": "checkmate", "winner": "black"}
                    await client.send(json.dumps(moveData))
                    print("Black Wins")
                break

            elif (board.is_stalemate()):
                print('GAME ENDED BY STALEMATE')
                moveData = {"move": board.peek().uci(), "board": boardlist, "status": "stalemate"}
                await client.send(json.dumps(moveData))
                break
            elif (board.is_fivefold_repetition()):
                print('GAME ENDED BY FIVEFOLD REPETITION')
                moveData = {"move": board.peek().uci(), "board": boardlist, "status": "repetition"}
                await client.send(json.dumps(moveData))
                break
            print(board.legal_moves)
            if(gameMode == 1):
                if turn == 0:
                    board = await player1.makeMove(board, 3, turn, client)
                else:
                    board = await player2.makeMove(board, 3, turn, client)
            elif(gameMode == 2):
                if userColorForAIMode == False:  # The user is white because 0 is white
                    if turn == 0:
                        board = await player1.makeMove(board, 3, turn, client)
                    else:
                        if(numberOfMoves < 2):
                            board = AIPlayer.makeFirstMove(board)
                        else:
                            board = AIPlayer.makeMove(board, 3, turn)
                else:  # The user is black because 1 is black
                    if turn == 0:
                        if(numberOfMoves < 2):
                            board = AIPlayer.makeFirstMove(board)
                        else:
                            board = AIPlayer.makeMove(board, 3, turn)
                    else:
                        board = await player1.makeMove(board, 3, turn, client)
            elif(gameMode == 3):
                if turn == 0:
                    if(numberOfMoves < 2):
                        board = player1.makeFirstMove(board)
                    else:
                        board = player1.makeMove(board, 3, turn)
                else:
                    if(numberOfMoves < 2):
                        board = player2.makeFirstMove(board)
                    else:
                        board = player2.makeMove(board, 3, turn)
            try:
                board.peek()
            except:
                print('game ended with no moves made')
                break
            if (lastmove == board.peek()):
                print('same board')
                break
            lastmove = board.peek()
            turn = not turn
            boardlist = list()
            columns = chess.FILE_NAMES
            for j in reversed(range(1,9)):
                for i in columns:
                    sqr = board.piece_at(chess.parse_square(i+str(j)))
                    if (sqr != None):
                        boardlist.append(sqr.symbol())
                    else:
                        boardlist.append('.')
            
            legal = []
            for x in list(board.legal_moves):
                legal.append(x.uci())
            moveData = {"move": board.peek().uci(), "board": boardlist, "status": "inprogress", "legalmoves": legal, 'ischeck': board.is_check()}
            print(boardlist)
            await client.send(json.dumps(moveData))
            time.sleep(0.5)
            isGameOver = await client.recv()
            if (isGameOver == 'Time'):
                print('GAME ENDED BY TIME')
                break
            if (isGameOver == 'Draw'):
                print('GAME ENDED BY DRAW')
                # Save game up to here
                break
            elif isGameOver == 'Resign':
                print("GAME ENDED BY RESIGNATION")
                # Save game up to here
                break
            time.sleep(0.5)
            print('MESSAGE SENT')
            numberOfMoves += 1


def main():
    game = chessGame()
    gameMode = game.menu()
    game.start(gameMode)


if __name__ == "__main__":
    main()
