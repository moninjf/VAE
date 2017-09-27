\newpage

Expériences personnelles
=======================

Initiation à l'informatique au cours des années de Lycée
-------------------------------------------

Après une jeunesse passée à pratiquer les mathématiques
\todored{expliquer plus en détail le type de mathématiques et le lien
avec l'info. rebondir sur Knuth}, je me suis intéressé à la
programmation à l'âge de 14 ans (en Seconde), en lisant le manuel de
la calculatrice scientifique requise par le cursus. Le sentiment
d'émerveillement et d'accomplissement en voyant le programme que je
venais d'écrire s'éxécuter devant mes yeux m'a encouragé à approfondir
le sujet (même si le programme en question était intégralement copié
de l'exemple fourni dans le manuel).

J'ai d'abord passé deux ans à apprendre le TI-Basic (le langage de ma
calculatrice, une espèce d'assembleur de haut niveau) en développant
diverses applications simples, d'un simple solveur d'équations
quadratiques à un programme de Yam's comprenant une écran de score,
une reconnaissance de figures, et un bouton d'alibi en plein cours
(bouton qui alterne entre l'affichage du jeu et un tracé de fonction
aléatoire, censé tromper l'enseignant qui jette un coup d'oeil
curieux).

Ensuite, pour des raisons de performance, j'ai voulu apprendre
l'assembleur Z80 (l'assembleur des calculatrices TI), mais ce dernier
nécessitait un PC pour être compilé alors que le TI-Basic était
éditable directement dans la calculatrice. Lorsque j'ai enfin eu un PC
(au cours de mon année de Terminale), j'ai appris le C et ai commencé
un parcours plus classique.

Durant ces explorations lycéennes, je suis allé chercher de la
littérature complémentaire au rayon "informatique" du CDI. C'est là,
entre les ouvrages de "HTML/CSS pour les nuls" et "Les bases du C++",
que j'ai trouvé un humble manuel vert, simplement intitulé "The Art of
Computer Programming" [^aocp] (c'était, je le crois, le seul ouvrage en
anglais de ce rayon). Un rapide feuilletage indiqua une profondeur
intéressante, qui m'incita à l'emprunter pour m'y plonger davantage.

[^aocp]: The art of computer programming

J'ai passé de nombreuses heures depuis ce jour à dévorer cette oeuvre,
tant elle est fascinante. Aujourd'hui encore, après plus de dix ans,
je suis certain de pouvoir y trouver de nouvelles inspirations. Son
approche à la fois formelle et joueuse a parlé très tôt, à la fois à
mon éducation mathématique, et à ma nature facétieuse.

Au cours de mes années à l'université, mystifié par l'apparente
"magie" des compilateurs, j'ai entrepris de concevoir divers langages
et écosystèmes, plus ou moins aboutis. Pour celà, je me suis aidé de
l'ouvrage "Compilateurs: principes, techniques et outils" (le
tristement célèbre "Dragon Book" [^dragon] \todored{developper le
"tristement"} ), puis ai graduellement intégré des méthodes nouvelles
à mes approches : divers algorithmes de ramasse-miette, les piles
"spaghetti" qui servent à implémenter les continuations du Scheme, qui
facilitent la mise en place de tail-call optimization (TCO).

[^dragon]: Le dragon book, difficile pour les débutants.

Après quelques années à travailler pour l'université, j'ai pu apporter
une dimension réelle à la programmation.

World, un build system pour des programmes Haskell et C multi-modulaires 
------------------------------

  - fonctionnement par "frozen environment" (paquets comme monoïdes),
    une mise à jour de dépendance implique la mise à jour de tout ce
    qui en dépend
  - génération d'éxécutables statiques, dynamiques ou profilés pour
    accélérer les performances
  - génération de graphes de dépendances à différents niveaux de
    granularité (paquets / modules)
  - production de documentation pour toutes les dépendances locales
    des modules racines

### Une granularité par module plutôt que par paquet

Suite aux problèmes d'enfer de dépendances engendrés par l'utilisation
de `Cabal`, le gestionnaire de paquets natif du langage Haskell, j'ai
entrepris d'écrire un système de compilation qui ne s'arrête pas aux
contraintes de dépendances décrites dans méta-données des paquets.

En temps normal, les dépendances inter-paquets sont opaques, à
l'instar des dépendances entre modules (si Main importe a, et A
importe B, Main n'a pas accès aux fonctions de B). Cette opacité est
justifiable entre module, mais incorrecte au vu du modèle
d'encapsulation choisi.

Il y a quelques années, si un module Haskell était 

Omega, un kernel simple pour du x86
---------------------------

Capable de gérer de multiples processus séparés, avec du partage de
mémoire et de temps processeur, et des capacités d'interception des
appels systèmes des processus enfants pour permettre une abstraction
de la plateforme.

C'est un système qui repose sur un principe de virtualisation des
espaces mémoire enfants : les appels systèmes des enfants sont
interceptés par tous les processus parents qui le souhaitent, et
peuvent être traités indépendamment du fonctionnement basique d'Omega.

Chaque espace mémoire peut créer des threads sur des "points d'entrée"
d'autres espaces mémoire, et chaque thread peut "voyager" entre les
espaces mémoires par ces mêmes points d'entrée. Chaque espace mémoire
décide donc de son interface avec le monde extérieur.

La synchronisation inter-processus se fait de façon bloquante, en
créant des sémaphores sur des pages de mémoire partagée. C'est
l'adresse physique sous-jacente qui fait office d'identifiant de
synchronisation, ce qui garantit qu'un processus ne peut pas
interférer avec le fonctionnement d'un autre processus avec lequel il
ne partage pas de mémoire. Comme les processus sont responsables de la
mémoire qu'ils partagent avec les autres, ils ont un contrôle total de
leurs interactions.

### MeXa, un langage de script réactif

\todored{tartiner sur le GC, Java, etc.}
En cherchant à rendre Oméga plus interactif, j'ai conçu un langage de
script capable de représenter la "mécanique" interne d'une application
dynamique (d'où son nom). Pour celà, il suffit de considérer chaque
expression comme un "engrenage" qui se lie à d'autres expressions pour
produire un "torque" (une valeur, paresseusement calculée), à partir
des torque de ses sous-expressions.

Dans la métaphore mécanique, il est naturel de vouloir remplacer
certaines pièces de la machinerie, pour en changer le fonctionnement
ou parce qu'elles sont devenues obsolètes. Avec MeXa, on peut
remplacer des engrenages en grâce à l'opérateur d'affectation `x = y`.

La particularité de cet opérateur est qu'il s'applique à tous types de
valeurs, symboliques ou calculées. Pour illustrer, si `f(a)` produit
l'expression à un certain indice dans le tableau `a`, alors
l'instruction `f(a) = 3` modifiera le tableau `a` à l'indice en
question. Conceptuellement, on remplace l'expression calculée `f(a)`
(qui se trouve être un alias d'une expression dans `a`) par `3`, en
propageant les changement à tous les endroits où cette expression et
ses alias ont été référencés.

Du point de vue de l'implémentation, j'ai commencé par envisager de
représenter chaque expression comme un "thunk", qui oscille entre deux
états : défini, et évalué. Dans les langages paresseux traditionnels,
l'oscillation n'arrive que dans un seul sens, de l'état défini vers
l'état évalué, par un processus que l'on appelle l'évaluation. Dans
ces langages, un "thunk" évalué ne peut jamais revenir à son état
défini.

En MeXa, l'oscillation peut revenir à un état défini en attente
d'évaluation, lorsqu'une sous-expression est remplacée par exemple. On
appelle ce processus l'invalidation. Pour permettre celà, chaque
expression doit garder des références, non seulement vers ses
sous-expressions au cas où elle serait évaluée, mais également vers
ses sur-expressions au cas où elle serait invalidée.

Celà engendre un graphe de référence bidirectionnel, ce qui s'avère
être intéressant du point de vue de la gestion de la mémoire. En
effet, l'un des problèmes majeurs des algorithmes de ramasse-miette
est la détection des cycles dans le graphe de références. Dans les
langages où les références sont mutables, et même avec les algorithmes
de ramasse-miette générationnels, des cycles savamment placés peuvent
nécessiter une analyse complète du graphe, ce qui est coûteux (plus
précisément, celà a un coût linéaire en la taille du graphe, c'est à
dire un coût croissant selon la taille de l'application).

L'information bidirectionelle permet de détecter les cycles
dynamiquement formés, dès qu'ils se forment (donc sans délai de
ramasse-miette), grâce à une analyse locale du graphe de valeurs. En
échange, ils occupent plus de place en mémoire que des objets
traditionnelt, ce qui convient à un langage de script.

Alpha : compilateur très bas niveau, impératif, structuré, optimisant
----------------------------

Allocation de registres, analyse bidirectionnelle du flot de contrôle
pour minimiser les copies. Dans ses bons jours, il compilait un
algorithme de PGCD en 7 instructions.

Langage non typé, mais structuré. Spécialisé pour travailler sur une
mémoire linéaire, et capable d'une analyse statique d'interpolation de
variables par provenance des alias. Les alias proviennent de "binding"
entre des symboles et des adresses. 

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

### Éviter l'enfer des dépendances pour une compilation sans maux de têtes

\todored{
  Donner le lien avec les systèmes de paquets de distrib.
}

La plupart des compilateurs offrent un système de modules afin de
permettre une compilation séparée de projets complexes, ainsi que le
partage et la réutilisation de code. En général, il est plutôt
intuitif d'utiliser du code provenant d'un module externe `A`, à
l'aide d'une directive `include` ou `import` : 
 
    # On peut importer un module complet
    import A
    # On peut aussi souvent importer un module partiel
    import A (foo, bar, baz)
    # Les modules peuvent être hiérarchisés et organisés en paquets
    import package-a.A

Dans la plupart des langages, la directive `import A` va chercher le
module `A` dans un chemin (`PYTHONPATH`, `JAVA_HOME`, ou même
`LD_LIBRARY_PATH`), et charger le premier fichier de module ainsi
trouvé.

Cette approche est trompeuse. Bien que conceptuellement simple, et
capable de résoudre correctement les dépendances d'un programme de
complexité moyenne, elle ne guarantit pas la composabilité de modules
arbitraires dans tous les cas. 

Prenons le cas typique d'enfer des dépendances, à savoir les
dépendances en diamant : un programme `Main` dépend de deux librairies
`A` et `B`, qui elles-mêmes dépendent toutes deux d'une même librairie
`C`. 

Dans certains cas, la configuration ne pose pas de problème. Par
exemple, lorsque les deux versions de `C` sont compatibles entre
elles.

%image "dep-hell"

Dans d'autres cas, les contraintes de version sur `C` sont
incompatibles entre elles, et des conflits peuvent survenir lors de la
résolution des symboles (le symbole `C.foo` fait-il référence à
`C-1.0` ou `C-2.0` ?).

%image "dep-hell-2"

Pour résoudre cela, il faut une isolation complète des dépendances à
l'intérieur des modules qui y font référence. 

%image "dep-hell-3"

En Java, il est difficile de décrire la situation ci-dessus (peut-être
est-ce plus simple avec le nouveau système de modules de Java 9). Avec
Curly, c'est une affaire de préciser les identifiants de librairie au
moment où on compile le source (les dépendances au moment de la
compilation sont conservées dans les fichiers objets, de manière à
rendre les builds reproduisibles sur toute plateforme). En voici la
commande :

    curly --mount "main src   = source[main] main.cy" \
          --mount "main A src = source[main A] A.cy" \
          --mount "main A C   = source[main A C] C2.cy"
          --mount "main B src = source[main B] B.cy" \ 
          --mount "main B C   = source[main B C] C1.cy" \
          ....

C

Ce contexte de compilation peut ensuite être enregistré dans un
fichier de configuration au format similaire : 

     #!/usr/bin/curly
     mount main src   = source[main] main.cy
     mount main A src = source[main A] A.cy
     mount main A C   = source[main A C] C2.cy
     mount main B src = source[main B] B.cy
     mount main B C   = source[main B C] C1.cy
     

Si ce fichier s'appelle `mon-projet`, Curly peut reproduire le même
contexte de compilation avec la commande `curly mon-projet`, ou tout
simplement `./mon-projet` si le fichier est éxécutable.

Non trié
-----

Système de modules indexé par contenu (Merkle tree, hash-indexed
stores, ...), distribuable sur un réseau Peer-to-peer (curly-dht) ou
sur par des moyens plus traditionels (HTTP, FTP, ou même un protocole
inconnu de Curly). Résolution des problèmes de "dependency hell", par
isolation de chaque contexte de compilation.





