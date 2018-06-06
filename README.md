## Othello/Reversi game implementation

This project contains implementation of the 2-player game [Reversi](https://en.wikipedia.org/wiki/Reversi) in C++ first, which is then translated to ARM assembly code.

## Motivation

Was created as a lab assignment for one Computer Architecture course.

And to kill boredom :p

## Software

The ARM code makes use to the *EMBEST BOARD PLUG-IN* on the [ARMSim#](http://armsim.cs.uvic.ca/) to draw to board on-screen.

## How to use?

1. Clone this repo, compile and run:
```
git clone http://github.com/recurze/Othello && cd Othello
g++ -o othello othello.cpp && ./othello
```

You can now play it on the terminal. It achieves clear screen and color using strings ("033...."), so it might not work on Windows?

Enjoy the game :)
