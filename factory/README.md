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

## Output

The tables are written to the standard output.

- `coords` and `neighbours` are identical to the tables of the game.
- `lines` contains the same mills, but sometimes in a different order: the mills are listed by axis (`x`, then `y`, then `z`), and the two points of each mill are sorted. This makes no difference for `isinmill`, which only needs columns 0-1 and 2-3 to form a mill each.

## Images

Two tools draw the cube, with the same colours: blue for `z = -1`, green for `z = 0`, red for `z = 1`, grey for the lines joining the squares. The lines of the cube which are not lines of the board are dashed, and the unused centres are drawn as hollow circles.

- `svg/drawcube` (Pascal, no dependency) writes an SVG image to the standard output:
  - `./drawcube 3d` draws the cube in an oblique view, the three squares stacked on top of each other;
  - `./drawcube top` draws the cube seen from above, each square being scaled by `z + 2`: this is the board, each point showing its number and its coordinates `(x, y, z)`.
- Two LaTeX/TikZ documents draw the same views, and are compiled with `pdflatex`:
  - `tikz/cube3d.tex` draws the cube in an oblique view;
  - `tikz/cubetop.tex` draws the cube seen from above.

## Build and use

```
make
./factory
```

To write the tables to `tables.inc`:

```
make tables.inc
```

To make the images (`svg/cube3d.svg`, `svg/cubetop.svg`, `tikz/cube3d.pdf`, `tikz/cubetop.pdf` and their PNG versions), which needs `rsvg-convert`, `pdflatex` and `pdftoppm`:

```
make images
```

The `svg` and `tikz` directories have their own `Makefile`: `make` in one of them only makes its own images.

To clean the directory:

```
make clean
make distclean
```
