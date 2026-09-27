
# Comparaison avec d'autres programmes

Les programmes comparés sont :

- [Mérelles](https://codeberg.org/rchastain/merelles) (C/SDL)
- [Morris 0.4](https://github.com/farindk/morris) (C++/GTK)
- *Morris 0.1.2* (C++/GNOME)
- [Mühlespiel](https://forum.qbasic.at/viewtopic.php?t=8708) (FreeBASIC)

## Représentation du plateau (couche logique)

| Programme | Numérotation des 24 points | Contenu d'une case | Moulins | Voisins |
|---|---|---|---|---|
| **Marelle** | ligne par ligne (0-1-2 en haut, 21-22-23 en bas) | `0` / `1` / `2` | `lines[24][4]` : deux paires par point | `neighbours[24][4]`, complété par `-1` |
| **Mérelles** | identique | `0` / `1` / `2` (`int *field`) | `field_lines[96]` : mêmes valeurs | `field_moves[96]` : mêmes valeurs |
| **Morris 0.4** | identique | `0` / `+1` / `-1` (`PL_White`, `PL_Black`) | liste des 16 moulins (`MM_9_milltab_short`), convertie en « moulins passant par chaque point » | `MM_9_neighbour` : mêmes valeurs |
| **Morris 0.1.2** | par carré : 0-7 extérieur, 8-15 milieu, 16-23 intérieur, dans le sens horaire depuis le coin en haut à gauche | `0` / `+1` / `-1` | 16 moulins (`milltab_short`) convertis au démarrage en `milltab[24][2][2]` | `neighbour[24][4]` |
| **Mühlespiel** | par carré, comme *Morris 0.1.2* | deux bitboards de 24 bits (`BF_Brett(0)` pour les Blancs, `BF_Brett(1)` pour les Noirs) | 16 masques de bits (`Tripletts`), et pour chaque point les indices de ses deux moulins | masque de bits, plus un voisin par direction (haut, droite, bas, gauche), lus dans des fichiers CSV |

Numérotation par carré (*Morris 0.1.2* et *Mühlespiel*) :

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

- Les tables `lines` et `neighbours` de *Marelle* sont identiques, valeur pour valeur, à celles de *Mérelles*. La table des voisins de *Morris 0.4* est aussi la même.
- Avec `+1` et `-1`, *Morris 0.1.2* et *Morris 0.4* obtiennent l'adversaire par `-joueur`. *Marelle* utilise `3 - joueur` pour la même chose.
- Dans la numérotation par carré, chaque point s'écrit `carré*8 + position`. *Morris 0.1.2* s'en sert pour sa notation des coups (lettre = `n>>3`, chiffre = `n&7`).
- *Mühlespiel* ne garde pas le nombre de pions en réserve. Il ne stocke que le numéro du demi-coup (`Halbzug`) et en déduit la phase : la pose dure jusqu'au demi-coup 18 ; ensuite, avec 3 pions, le joueur peut sauter.

## Règles du jeu

Les règles de base sont communes aux cinq programmes : 9 pions par joueur, pose puis déplacement vers un point voisin, saut libre à 3 pions, retrait d'un pion adverse quand on forme un moulin, défaite avec moins de 3 pions ou quand on ne peut plus bouger. Les différences :

| Règle | *Marelle* | *Mérelles* | *Morris 0.1.2* | *Morris 0.4* (règle standard) | *Mühlespiel* |
|---|---|---|---|---|---|
| Un pion dans un moulin est protégé (sauf si tous les pions adverses sont dans des moulins) | oui | non : on peut prendre n'importe quel pion adverse (`phase_del.c`) | oui | oui (on peut le désactiver par une option) | oui |
| Double moulin | 1 pion retiré | 1 pion | 1 pion | 1 pion (plusieurs par une option) | 2 pions retirés |
| Partie nulle | non | non | non | oui, si la même position revient 3 fois | non |
| Variantes | non | non | non | oui : Lasker, Morabaraba, 6 et 12 pions, Windmill, etc. | non |

Pour le saut et la défaite, tous ces programmes se comportent en pratique de la même façon. La principale différence avec *Marelle* se trouve donc dans *Mérelles*, qui ne protège pas les pions déjà dans un moulin.
