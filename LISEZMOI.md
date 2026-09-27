# Marelle

Jeu de la marelle (ou des mérelles, ou des moulins) pour MSEide+MSEgui.

## Représentation du plateau

Le plateau est représenté dans `game.pas`, qui ne connaît aucune coordonnée à l'écran.

### Les 24 intersections dans un tableau à une dimension

```pascal
fpoints: array[0..pointcount - 1] of integer;   // pointcount = 24
```

Chaque case contient **0** si l'intersection est vide, **1** pour un pion des Blancs et **2** pour un pion des Noirs. Les numéros de joueur sont les mêmes que dans `fplayer`, ce qui permet d'écrire `3 - fplayer` pour passer d'un joueur à l'autre.

Les points sont numérotés de 0 à 23, ligne par ligne, de haut en bas et de gauche à droite :

```
 0-----------1-----------2
 |           |           |
 |   3-------4-------5   |
 |   |       |       |   |
 |   |   6---7---8   |   |
 |   |   |       |   |   |
 9--10--11      12--13--14
 |   |   |       |   |   |
 |   |  15--16--17   |   |
 |   |       |       |   |
 |  18------19------20   |
 |           |           |
21----------22----------23
```

### La géométrie dans deux tables constantes

Le tableau `fpoints` ne sait rien de la forme du plateau. La géométrie est décrite séparément par deux tables :

- **`neighbours[24, 0..3]`** : les points adjacents à chaque point, pour les déplacements. Un point a de 2 à 4 voisins, et les places inutilisées valent `-1` (par exemple `(1, 9, -1, -1)` pour le point 0). `maymove` et `canmove` utilisent cette table.
- **`lines[24, 0..3]`** : les deux alignements qui passent par chaque point. Ce sont deux paires : les indices 0-1 forment une ligne, les indices 2-3 forment l'autre. Pour le point 0, `(1, 2, 9, 21)` correspond à la ligne 0-1-2 et à la ligne 0-9-21. `isinmill` teste ainsi un moulin en deux comparaisons, sans parcourir de liste de moulins.

### Le reste de l'état de la partie

- `fhand[1..2]` : le nombre de pions encore en réserve pour chaque joueur (9 au départ).
- `fplayer` : le joueur dont c'est le tour.
- `fphase` : la phase en cours (`ph_place`, `ph_move`, `ph_remove`, `ph_over`).
- `fwinner` : le gagnant.

### Représentation cubique

Une autre façon de voir le plateau a été proposée sur [developpez.net](https://www.developpez.net/forums/d2089226/autres-langages/pascal/representation-jeu-moulin/#post11949548) : les trois carrés sont les trois couches d'un cube de 3 × 3 × 3 cases, vu de dessus. Chaque point reçoit trois coordonnées comprises entre -1 et 1 : `z` désigne le carré (-1 intérieur, 0 milieu, 1 extérieur), `x` et `y` la position sur ce carré. Les trois centres (`x = y = 0`) ne sont pas utilisés, ce qui laisse les 24 points.

La géométrie se déduit alors des coordonnées :

- **voisins** : deux points dont les coordonnées diffèrent de 1 sur un seul axe ; on ne change de carré (axe `z`) qu'au milieu d'un côté, c'est-à-dire quand `(x and y) = 0` ;
- **moulins** : les trois points d'une ligne du cube, sauf les lignes qui passent par un centre et les lignes selon `z` qui passent par les coins. On retrouve les 16 moulins ;
- **position à l'écran**, sur la grille 7 × 7 : `4 + x * (z + 2)`, `4 + y * (z + 2)`.

Le programme du dossier `factory` calcule ainsi les tables `neighbours` et `lines` de `game.pas`, et la table `coords` de `main.pas` : il retrouve les mêmes données. Le même dossier dessine le cube, en SVG et avec TikZ.

## Implémenter un adversaire artificiel

Le programme est prêt à recevoir un vrai adversaire : il suffit de remplacer la fonction `chooseaction` de `computer.pas`. Le reste (menus, déclenchement, enchaînement du tour, journal) n'a pas à changer.

### Le contrat de `chooseaction`

```pascal
type
  computeractionty = record
    source: integer;
    target: integer;
  end;

function chooseaction(const agame: tgame): computeractionty;
```

La fonction reçoit la partie et renvoie **une seule action**, pour la phase en cours :

| Phase | `source` | `target` |
|---|---|---|
| `ph_place` | inutilisé (-1) | point libre où poser |
| `ph_move` | pion à déplacer | point d'arrivée |
| `ph_remove` | inutilisé (-1) | pion adverse à prendre |

`playturn` (dans `main.pas`) l'appelle en boucle tant que le joueur n'a pas changé : un coup qui ferme un moulin est donc suivi d'un second appel, en phase `ph_remove`, pour la prise. Deux conséquences :

- l'action renvoyée doit être **légale**. Une action refusée par `tgame` arrête la boucle, et le tour de l'ordinateur reste inachevé : la souris est alors bloquée, puisque c'est toujours à l'ordinateur de jouer ;
- `target = -1` signifie « aucune action possible ». Cela ne devrait pas arriver, puisque la partie se termine dès qu'un joueur ne peut plus bouger.

Un moteur qui calcule un coup complet (déplacement et prise) doit donc garder la prise en mémoire entre les deux appels, ou la recalculer au second appel.

### Ce que `tgame` met à disposition

En lecture : `points[i]` (0, 1 ou 2), `player`, `phase`, `hand[joueur]`, `winner`, et les fonctions `maymove`, `maytake`, `isinmill`, `countpieces`, `canmove`, `mayjump`, `positionstr`.

Deux limites à connaître :

- **Les actions de `tgame` écrivent dans le journal.** Une recherche qui jouerait et déjouerait des coups sur `tgame` remplirait `marelle.log` de milliers de lignes, et serait très lente, puisque chaque ligne ouvre et referme le fichier. `tgame` ne sait d'ailleurs pas annuler un coup.
- **Les tables `neighbours` et `lines` sont privées** : elles sont déclarées dans la partie `implementation` de `game.pas`.

Il vaut donc mieux que le moteur ait **sa propre représentation**, légère et sans journal : les 24 points, le joueur qui a le trait, la phase, les réserves. Pour les tables, on peut les déplacer dans la partie `interface` de `game.pas`, ou inclure celles que produit `factory` (`make tables.inc`).

Sans recherche, on obtient déjà un adversaire nettement meilleur que le hasard :

- **pose et déplacement** : fermer un moulin si c'est possible ; sinon empêcher l'adversaire de fermer le sien au coup suivant ; sinon préparer un moulin (deux pions alignés avec une case libre) ; sinon jouer au hasard ;
- **prise** : retirer de préférence un pion qui menace de fermer un moulin, ou qui en bloque un.

### Garder la fenêtre réactive

`playturn` s'exécute dans le fil principal : pendant qu'il calcule, la fenêtre ne se redessine plus et ne répond plus. Pour une recherche de plus d'une fraction de seconde :

- lancer la recherche dans un `tthread` ;
- afficher « L'ordinateur réfléchit... » dans la ligne d'état ;
- à la fin du calcul, transmettre le coup au fil principal par un événement asynchrone (`asyncevent`, comme le fait déjà `checkcomputer`), qui le joue avec `tgame`.

Les clics sont déjà ignorés pendant le tour de l'ordinateur (`mouseev` teste `fcomputer = fgame.player`). Il faudra en plus désactiver « Jouer » et « Nouvelle partie » pendant le calcul, ou savoir interrompre la recherche.

### Mesurer la force du nouvel adversaire

Le dossier `test` contient `logtest`, qui fait jouer une partie entière à l'ordinateur contre lui-même, avec une graine du hasard fixe. Sur ce modèle, un programme de match peut faire jouer le nouvel adversaire contre l'ancien (le hasard) sur une centaine de parties, en alternant les couleurs, et compter les victoires, les défaites et les parties arrêtées au bout d'un nombre maximal de coups. Pour que ce soit rapide, il faudra pouvoir couper l'écriture du journal (par exemple avec une variable de `log.pas`).

Avec la graine fixe, `logtest.log` sert aussi de référence : un `diff` entre deux versions (en ignorant l'horodatage, par exemple avec `cut -c14-`) montre tout de suite si le déroulement d'une partie a changé.

## Comparaison avec d'autres programmes

Les programmes comparés sont : *merelles* (C/SDL), *morris-0.4* (C++/GTK), *gnmm-0.1.2* (C++/GNOME) et *muehle* (FreeBASIC).

### Représentation du plateau (couche logique)

| Programme | Numérotation des 24 points | Contenu d'une case | Moulins | Voisins |
|---|---|---|---|---|
| **marelle** | ligne par ligne (0-1-2 en haut, 21-22-23 en bas) | `0` / `1` / `2` | `lines[24][4]` : deux paires par point | `neighbours[24][4]`, complété par `-1` |
| **merelles** | identique | `0` / `1` / `2` (`int *field`) | `field_lines[96]` : mêmes valeurs | `field_moves[96]` : mêmes valeurs |
| **morris-0.4** | identique | `0` / `+1` / `-1` (`PL_White`, `PL_Black`) | liste des 16 moulins (`MM_9_milltab_short`), convertie en « moulins passant par chaque point » | `MM_9_neighbour` : mêmes valeurs |
| **gnmm-0.1.2** | par carré : 0-7 extérieur, 8-15 milieu, 16-23 intérieur, dans le sens horaire depuis le coin en haut à gauche | `0` / `+1` / `-1` | 16 moulins (`milltab_short`) convertis au démarrage en `milltab[24][2][2]` | `neighbour[24][4]` |
| **muehle** | par carré, comme gnmm | deux bitboards de 24 bits (`BF_Brett(0)` pour les Blancs, `BF_Brett(1)` pour les Noirs) | 16 masques de bits (`Tripletts`), et pour chaque point les indices de ses deux moulins | masque de bits, plus un voisin par direction (haut, droite, bas, gauche), lus dans des fichiers CSV |

Numérotation par carré (gnmm et muehle) :

```
 0-----------1-----------2
 |           |           |
 |   8-------9------10   |
 |   |       |       |   |
 |   |  16--17--18   |   |
 |   |   |       |   |   |
 7--15--23      19--11---3
 |   |   |       |   |   |
 |   |  22--21--20   |   |
 |   |       |       |   |
 |  14------13------12   |
 |           |           |
 6-----------5-----------4
```

Remarques :

- Les tables `lines` et `neighbours` de marelle sont identiques, valeur pour valeur, à celles de merelles. La table des voisins de morris est aussi la même.
- Avec `+1` et `-1`, gnmm et morris obtiennent l'adversaire par `-joueur`. marelle utilise `3 - joueur` pour la même chose.
- Dans la numérotation par carré, chaque point s'écrit `carré*8 + position`. gnmm s'en sert pour sa notation des coups (lettre = `n>>3`, chiffre = `n&7`).
- muehle ne garde pas le nombre de pions en réserve. Il ne stocke que le numéro du demi-coup (`Halbzug`) et en déduit la phase : la pose dure jusqu'au demi-coup 18 ; ensuite, avec 3 pions, le joueur peut sauter.

### Règles du jeu

Les règles de base sont communes aux cinq programmes : 9 pions par joueur, pose puis déplacement vers un point voisin, saut libre à 3 pions, retrait d'un pion adverse quand on forme un moulin, défaite avec moins de 3 pions ou quand on ne peut plus bouger. Les différences :

| Règle | marelle | merelles | gnmm | morris (règle standard) | muehle |
|---|---|---|---|---|---|
| Un pion dans un moulin est protégé (sauf si tous les pions adverses sont dans des moulins) | oui | non : on peut prendre n'importe quel pion adverse (`phase_del.c`) | oui | oui (on peut le désactiver par une option) | oui |
| Double moulin | 1 pion retiré | 1 pion | 1 pion | 1 pion (plusieurs par une option) | 2 pions retirés |
| Partie nulle | non | non | non | oui, si la même position revient 3 fois | non |
| Variantes | non | non | non | oui : Lasker, Morabaraba, 6 et 12 pions, Windmill, etc. | non |

Pour le saut et la défaite, tous ces programmes se comportent en pratique de la même façon. La principale différence avec marelle se trouve donc dans merelles, qui ne protège pas les pions déjà dans un moulin.
