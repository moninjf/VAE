\newpage

Expériences personnelles
=======================

World, un build system pour des programmes Haskell et C multi-modulaires 
------------------------------

  - fonctionnement par "frozen environment" (paquets comme monoïdes),
    une mise à jour de dépendance implique la mise à jour de tout ce
    qui en dépend
  - granularité par module plutôt que par paquet
  - génération d'éxécutables statiques, dynamiques ou profilés pour
    accélérer les performances
  - génération de graphes de dépendances à différents niveaux de
    granularité (paquets / modules)
  - production de documentation pour toutes les dépendances locales
    des modules racines

Omega, un kernel simple pour du x86
---------------------------

Capable de gérer de multiples processus séparés, avec du partage de
mémoire et de temps processeur, et des capacités d'interception des
appels systèmes des processus enfants pour permettre une abstraction
de la plateforme.

Alpha : compilateur très bas niveau, impératif, structuré, optimisant
----------------------------

Allocation de registres, analyse bidirectionnelle du flot de contrôle
pour minimiser les copies. Dans ses bons jours, il compilait un
algorithme de PGCD en 7 instructions.

Langage non typé, mais structuré. Spécialisé pour travailler sur une
mémoire linéaire, et capable d'une analyse statique d'interpolation de
variables par provenance des alias. Les alias proviennent de 

Problème : un funeste jour, la perte d'un disque dur occasiona la
perte de 3 mois de travail, et je n'ai pas eu le courage de reprendre
depuis.

Curly : compilateur haut niveau, lambda-calcul, reproduisible
-----------------------------------

Après Alpha, un petit interpréteur lambda-calcul pour simplifier le
processus de conception du langage.

Au départ, sensé être non-typé pour aller au plus simple, mais
l'expérience montra qu'un typage simple était nécessaire afin d'éviter
certaines erreurs de runtime (`"abc"(3)` cause une segfault si on
néglige les erreurs de types). 

Pour maximiser l'expressivité du langage, introduction de types
isorécursifs (par exemple, le type du combinateur $\Omega = \lambda
x. x x$ est $A = A \rightarrow a = (A \rightarrow a) \rightarrow a =
...$), qui permettent la définition de combinateurs de récursion au
sein du langage.

Introduction de types abstraits, qui capturent des variables de types
dans leur constructeur pour les libérer dans le destructeur. Par
exemple :

    $ type Bool = if_then_else_ : ....
    $ what's Bool
    (A -> A -> A) -> Bool  # variable "rigide" dans le constructeur
    $ what's if_then_else_
    Bool -> (a -> a -> a)  # variable "fluide" dans le destructeur
    $ type List a = foldList : .....
    $ what List
    ((a -> A -> A) -> A -> A) -> List a
    $ what foldList
    List a -> (a -> b -> b) -> b -> b

Système de modules indexé par contenu (Merkle tree, hash-indexed
stores, ...), distribuable sur un réseau Peer-to-peer (curly-dht) ou
sur par des moyens plus traditionels (HTTP, FTP, ou même un protocole
inconnu de Curly). Résolution des problèmes de "dependency hell", par
isolation de chaque contexte de compilation.





