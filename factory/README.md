
# Factory

Command-line programs generating the Pascal source code of the board tables used by the game: `coords` (in `main.pas`), `lines` and `neighbours` (in `game.pas`).

Instead of being typed by hand, the tables are computed from a geometric model of the board: the three nested squares are seen as the layers of a 3×3×3 cube.

## The cube

Each point of the board receives three coordinates in `-1..1`:

- `z` is the square: `-1` for the inner one, `0` for the middle one, `1` for the outer one;
- `x` and `y` give the position on the square: `-1` for left or top, `0` for the middle, `1` for right or bottom.

The cube has 27 cells. The three cells with `x = 0` and `y = 0` (the centres of the squares) are not used, which leaves the 24 points of the board.

```
 (-1,-1)------(0,-1)------(1,-1)
    |            |           |
    |            |           |
 (-1, 0)                  (1, 0)
    |            |           |
    |            |           |
 (-1, 1)------(0, 1)------(1, 1)
```

The points are numbered from 0 to 23 by scanning the 7×7 grid of the board row by row, from top to bottom and from left to right, as in the game.

## Rules

### Neighbours

Two points are neighbours when their coordinates differ by 1 on one axis only. A move along `z` (from one square to another) is only possible at the middle of a side, that is when `(x and y) = 0`.

### Mills

A mill is made of the three points of a line of the cube along one axis, with two exceptions:

- a line along `x` or `y` passing through the centre of a square is not a mill;
- a line along `z` passing through the corners is not a mill.

This gives 4 mills per square and 4 mills joining the squares: 16 mills.

### Screen coordinates

The position of a point on the 7×7 grid is `4 + x * (z + 2)`, `4 + y * (z + 2)`.
