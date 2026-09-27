
# Factory

Programme en ligne de commande qui génère le code source Pascal des tables du plateau utilisées par le jeu : `coords` (dans `main.pas`), `lines` et `neighbours` (dans `game.pas`).

Au lieu d'être saisies à la main, les tables sont calculées à partir d'un modèle géométrique du plateau : les trois carrés imbriqués sont vus comme les couches d'un cube de 3×3×3 cases.

Le cube est une [idée][1] de Philippe Guesset.

## Le cube

Chaque point du plateau reçoit trois coordonnées comprises entre `-1` et `1` :

- `z` désigne le carré : `-1` pour le carré intérieur, `0` pour le carré du milieu, `1` pour le carré extérieur ;
- `x` et `y` donnent la position sur le carré : `-1` pour la gauche ou le haut, `0` pour le milieu, `1` pour la droite ou le bas.

Le cube compte 27 cases. Les trois cases où `x = 0` et `y = 0` (les centres des carrés) ne sont pas utilisées, ce qui laisse les 24 points du plateau.

```
 (-1,-1)------(0,-1)------(1,-1)
    |            |           |
    |            |           |
 (-1, 0)                  (1, 0)
    |            |           |
    |            |           |
 (-1, 1)------(0, 1)------(1, 1)
```

Les points sont numérotés de 0 à 23 en parcourant la grille 7×7 du plateau ligne par ligne, de haut en bas et de gauche à droite, comme dans le jeu.

## Règles

### Voisins

Deux points sont voisins quand leurs coordonnées diffèrent de 1 sur un seul axe. Un déplacement selon `z` (d'un carré à l'autre) n'est possible qu'au milieu d'un côté, c'est-à-dire quand `(x and y) = 0`.

### Moulins

Un moulin est formé des trois points d'une ligne du cube selon un axe, avec deux exceptions :

- une ligne selon `x` ou `y` qui passe par le centre d'un carré n'est pas un moulin ;
- une ligne selon `z` qui passe par les coins n'est pas un moulin.

On obtient 4 moulins par carré et 4 moulins qui relient les carrés : 16 moulins.

### Coordonnées à l'écran

La position d'un point sur la grille 7×7 est `4 + x * (z + 2)`, `4 + y * (z + 2)`.

[1]: https://www.developpez.net/forums/d2089226/autres-langages/pascal/representation-jeu-moulin/#post11949548
