# Marelle

*MSEgui* implementation of [Nine Men's Morris](https://en.wikipedia.org/wiki/Nine_men%27s_morris) (*jeu du moulin*, *mérelles*, *marelle*), for two players or one player against the computer.

The game logic comes from [Mérelles](https://gitlab.com/rchastain/merelles), a C/SDL program by [Paul-Maxime](https://github.com/paul-maxime/merreles). The rule about taking pieces from mills comes from [Morris](https://nine-mens-morris.net) by Dirk Farin.

## Screenshot

![Screenshot](screenshot.png)

## Rules

### Board and pieces

The board is made of three nested squares joined by four lines at the middle of their sides. The pieces stand on the 24 points where lines meet or end. Two points are neighbours when a line joins them without passing through another point.

Each player has nine pieces: White and Black. White plays first, then the players take turns.

### Mills

A mill is a row of three pieces of the same colour along a line: one side of a square, or one of the four lines joining the squares. There are 16 possible mills.

Each time a player forms a mill, by placing or moving a piece, they remove one opponent piece from the board. The removed piece is out of the game for good. A mill can be opened and closed again later: every new closing counts.

A piece belonging to a mill cannot be taken, unless all the opponent pieces belong to mills. In that case, any of them can be taken.

A move closing two mills at once only allows one piece to be taken.

### Placing

At first, the players place their pieces one at a time on any free point. This phase ends when both players have placed their nine pieces.

### Moving

Then, on each turn, the player moves one of their pieces along a line to a neighbouring free point. Pieces cannot jump over other pieces.

### Flying

A player left with three pieces may move a piece to any free point of the board, not only to a neighbouring one.

### End of the game

A player loses the game when, at their turn to move:

- they have fewer than three pieces, so they can no longer form a mill;
- or none of their pieces can move, all of them being blocked.

The program does not detect draws: when the game goes around in circles, start a new game.

## Usage

Click a free point to place a piece. To move a piece, drag it to its destination, or click it (it gets a green circle and its possible destinations are marked with green dots), then click the destination. After a mill, the pieces that can be taken have a red circle: click one of them.

The status line shows whose turn it is, what to do and how many pieces are left to place.

### Menus

| Menu | Item | Effect |
|---|---|---|
| *Partie* | *Nouvelle partie* | Starts a new game (also available as a button). |
| | *Quitter* | Closes the program. |
| *Coups* | *Jouer* | The computer plays the current turn, including the removal of a piece after a mill. If *Réponse automatique* is checked, the computer takes over the side to move. |
| | *Réponse automatique* | When checked, the computer answers each move: it plays the side that is not to move when the option is checked. |
| *Aide* | *À propos...* | Shows information about the program. |

For now, the computer plays a random legal action: it is only a placeholder for a real opponent (see below).

## Building

You need Free Pascal and [MSEgui](https://github.com/mse-org/mseide-msegui):

```Bash
make MSEDIR=/path/to/mseide-msegui/
```

## Writing a real computer opponent

Everything is ready for it: only `chooseaction` in `computer.pas` has to be replaced. It receives the game and returns one action for the current phase (`target`: the point to place on, to move to or to take; `source`: the piece to move, used in the moving phase only). The main window calls it repeatedly until the turn is over, so a move that closes a mill is followed by a second call for the removal.

A search (minimax with alpha-beta pruning, for instance) should not work on `tgame` itself: its actions write to the log. A light copy of the position (24 points, side to move, phase, pieces in hand) is better. A long search should also run in a thread, so that the window stays responsive. `LISEZMOI.md` describes all this in detail, with the evaluation criteria and a way to measure the strength of the new player against the random one.

## Credits

- Board, pieces, marks and icon: images drawn with [AGGPas](https://github.com/graemeg/fpGUI) and saved with *MSEgui* by the programs of the `images` directory (`make` in that directory rebuilds them).
- Wood texture from [Wood Texture Tiles](https://opengameart.org/content/wood-texture-tiles).
- Former images, kept in `images/old`: from *Mérelles*.
