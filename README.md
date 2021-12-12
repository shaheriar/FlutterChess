# Flutter Chess

## Overview
This is a branch made by Shaheriar Malik from the original project from our senior design class, the Smart Chessboard. This is a standalone software web app that can run a chess game.

The chess engine, AI, and the websocket server are made using Python, and the Frontend is made using Flutter.

The AI uses minimax hard coded at a depth of 3 to find the best move to make based on material cost and if the move results in a checkmate.



## Usage

## How To Run
This application needs 3 terminals to be running at the same time; one for the websocket server, one for the game engine, and one for the frontend.


### To run the server: `python server.py`

### To run the game engine: `python servergame.py`

### To run the frontend
- `cd chessboard`
- `flutter build web`
- `cd build/web`
- `npm serve`

Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.<br />
You will also see any errors in the console.
## Screenshot
The game currently looks like this:
![game](https://github.com/shaheriar/FlutterChess/blob/main/game.png?raw=true)

## Dependencies
Install Node Package Manager (npm).

Install Python.

Install Flutter SDK.

