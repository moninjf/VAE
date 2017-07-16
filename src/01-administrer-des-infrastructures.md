\newpage
Administrer et configurer des infrastructures informatiques
======================

En quatre années à travailler comme administrateur système à l'UFR
IM²AG, j'ai été confronté à de nombreuses demandes d'administration
d'infrastructures, de la mise en place de machines virtuelles à usage
unique pour un TP à la configuration d'un système de déploiement
d'images disques par le réseau dans nos salles de TP.

Je commencerai par décrire les éxigences d'un 

Un système de déploiements d'images en PXE
------------------------------

Une problématique qui survient souvent lors de l'administration d'un
parc informatique est celle de l'installation des postes clients. En
effet, la procédure manuelle d'installation d'une machine peut
aisément occuper plusieurs heures, et ne se parallélise pas
naturellement, en plus d'être affreusement sujette à l'erreur
humaine. À la main, l'installation d'une salle de 16 machines, comme
nous en avons une vingtaine à l'UFR IM²AG, peut ainsi prendre une
semaine ou deux, selon le degré d'investissement du technicien.

Ces délais se traduisent directement par une insatisfaction des
"clients" de nos salles informatiques, puisqu'ils nous empêchent de
répondre aux problématiques urgentes en un temps acceptable. Si un
enseignant avait besoin d'une installation spécifique pour un TPs, il
serait contraint de nous en faire la demande plusieurs mois en avance,
sous peine de se retrouver fort dépourvu le jour J face à une classe
d'étudiants goguenards.

Afin d'éviter ces situations délicates, et de faciliter le travail des
techniciens, j'ai mis en place, au cours de l'été 2013, un système qui
permet l'installation parallèle des machines d'une salle, doublée
d'une garantie d'uniformité des installations.

Le PXE (Preboot eXecution Environment, en anglais dans le texte) est
un protocole réseau, voire même un ensemble de protocoles réseaux, qui
permet à des machines de démarrer un système installé sur un
serveur. Dans notre cas, ce protocole sert à démarrer un système de
clonage d'images disques, du nom de CloneZilla, auquel on demande de
restaurer une image commune sur chaque poste de notre réseau. Cette
image commune doit au préalable être extraite d'un poste d'example
,appelé le "master", que l'on peut configurer à notre guise.

Bien que conceptuellement simple, le PXE n'est pas un protocole très
facile à mettre en place. En particulier, il nécessite dans un premier
temps la configuration d'un serveur DHCP[^dhcp] pour envoyer des
options spécifiques aux postes clients de manière à ce que ces
derniers puissent démarrer sur le réseau.

Dans un second temps, un poste qui vient de démarrer en PXE va devoir
interroger un serveur TFTP[^tftp] pour récupérer un
chargeur d'amorçage, ou "bootloader", qui se charge de démarrer le
reste du système.

[^dhcp]: le Dynamic Host Configuration Protocol, qui sert d'ordinaire
à une machine pour récupérer automatiquement une adresse dans un
réseau

[^tftp]: Trivial File Transfer Protocol, ou "protocole trivial de
transfert de fichiers". Ce protocole est une version simplifiée de
FTP, utilisée par le BIOS (ou l'UEFI dans les machines récentes) pour
récupérer l'image du bootloader.

Dans notre cas, et comme indiqué ci-dessus, le système à démarrer est
CloneZilla, qui est capable de sauvegarder et de restaurer des images
disques à partir de diverses solutions de stockage (un disque de
sauvegarde, ou un lecteur réseau, par exemple). Pour les usages de l'UFR, j'ai choisi de garder nos images disques sur un serveur NFS[^nfs]
fourni par notre baie de stockage, de façon à ce que la même image
puisse être déployée sur plusieurs postes simultanément (ce qui est
difficile si l'image se trouve sur un disque qui ne peut être branché
que sur un seul poste).

[^nfs]: Network File System, ou "système de fichiers en réseau". Ce
protocole permet le partage de dossiers entre machines, et permet à
plusieurs client d'accéder aux mêmes donnée sans nécessiter de copie.

CloneZilla étant conçu comme un système de rescousse, il va par défaut
poser quelques questions à l'administrateur lors de son démarrage pour
déterminer la marche à suivre. Dans un contexte de déploiement, les
réponses à ces questions sont prédéterminées et doivent être
directement communiquées à CloneZilla, de manière à éviter de fournir
16 fois les mêmes informations (et l'erreur humaine qui
s'ensuit). Voici un example de la configuration du chargeur d'amorçage
qui permet ce comportement :

    default clone
    label clone
      kernel images/CloneZilla/vmlinuz
      initrd images/CloneZilla/initrd.img
      append boot=live union=overlay username=user config components
        quiet noswap edd=on nomodeset nodmraid noeject
        locales=fr_FR.UTF-8 keyboard-layouts=fr vga=788 ip=
        net.ifnames=0 nosplash i915.blacklist=yes radeonhd.blacklist=yes
        nouveau.blacklist=yes vmwgfx.enable_fbdev=1
        fetch=tftp://SERVEUR_TFTP/boot/images/CloneZilla/filesystem.squashfs
        ocs_live_batch=yes ocs_prerun1="mount -t nfs SERVEUR_NFS:CHEMIN_RACINE /home/partimag"
        ocs_live_run=ocs-live-restore
        ocs_live_extra_param="-scr -p reboot restoredisk CHEMIN-IMAGE DISQUE"

En conclusion, la mise en place d'une infrastructure de déploiement
nécessite des compétences diverses d'installation et de configuration
de protocoles qui oeuvrent sur le réseau, ainsi qu'une connaissance
poussée des systèmes d'exploitation que l'on démarre.

Un serveur de paquets pour des installations différées
------------------------------------------------

Un système de déploiement par images, bien que répondant aux critères
de reproduisibilité de nos utilisateurs, est très demandeur en
ressources, à la fois sur les postes et sur le réseau. En effet, pour
déployer des images d'approximativement 80Go de taille, dans des
salles de 16 machines, à raison d'un débit théorique de 10Mo/s sur de
l'Ethernet 100M (débit que l'on atteint rarement en conditions
réelles), il nous faudrait presque une journée entière ($\frac{16
\times 80000}{3600} \approx 22$ heures d'utilisation continue du
réseau). En raison de multiple optimisations apportées par CloneZilla
(compression des images disques, élimination des espaces non occupés
par des fichiers, ...), ce temps est quelque peu réduit, puisque nos
déploiements prennent en réalité entre 8 et 10 heures au lieu des 22
théoriques.

En dépit de ces optimisations, un tel système ne peut pas répondre aux
exigences immédiates de certains utilisateurs peu préparés. En effet,
si un enseignant se rend compte au cours d'un TP qu'il lui manque une
installation particulière, il ne peut pas demander aux étudiants de
revenir une semaine plus tard pour faire le TP en de meilleures
conditions. Dans une telle situation, il nous faut une réactivité de
l'ordre des 5 minutes, pas d'une journée entière.

La cause principale de la lenteur d'une installation par image est sa
masse : elle redéploie intégralement tout le disque à la moindre
modification. Or, une installation habituelle change assez peu
d'information par rapport au système entier (de quelques kilo-octets à
quelques centaines de méga-octets, par rapport aux dizaines de
giga-octets du système entier). Idéalement, on aimerait pouvoir
bénéficier à la fois de l'uniformité des images disques, avec
l'incrémentalité des installations manuelles.

C'est exactement ce problème que les gestionnaires de paquets sont
conçus pour résoudre. L'installation d'un paquet ne déclenche pas une
reconfiguration du système entier, mais un paquet peut être mis à jour
pour accomoder de nouveaux besoins, et imposer de nouvelles
dépendances.

Dans l'écosystème Linux, il existe déjà des dépôts de paquets qui
fournissent une grande partie des applications dont l'UFR a
besoin. Malheureusement, certaines applications ne sont pas librement
accessible à tout public (pour raisons légales ou commerciales), et
doivent être paramétrées localement. Pour celà, il nous faut ajouter
un dépôt local aux sources de paquets de nos machines, qui définit les
installations qui ne sont pas disponibles ailleurs.

Par chance, la majorité de nos systèmes Linux est composée de dérivés
de Debian, qui utilisent tous le même gestionnaire de
paquets[^dpkg]. Celà m'a évité de gérer plusieurs systèmes de paquets,
qui ont chacun leur structure et leurs particularités. J'ai donc pu me
concentrer sur la construction et le déploiement de paquets au format
`.deb`.

### Hébergement et structure du dépôt

L'hébergement d'un dépôt Debian n'est pas difficile à mettre en
oeuvre. `apt-get`[^apt-get] est capable de récupérer ses paquets sur un
serveur HTTP, donc l'hébergement peut consister en un simple serveur
Apache[^apache] qui dessert un répertoire statique dont la structure est
dictée par la documentation Debian[^debian-repo].

Afin de simplifier la maintenance de cette structure, j'ai écrit un
programme de construction du dépôt à partir d'une spécification
humaine, qui se base sur `make`[^make] pour éviter les reconstructions
inutiles lorsqu'une petite modification est apportée à un paquet.

Enfin, j'ai utilisé `watchman`[^watchman] pour déclencher la
reconstruction dès qu'un fichier source est modifié, et partagé ces
fichiers sources sur le réseau, de façon à pouvoir travailler dessus
en tout confort. De cette façon, pour mettre un paquet à jour, il
suffit d'ouvrir le fichier contenant sa description, d'apporter les
changements souhaités, et d'enregistrer le fichier. Le reste est
automatique.

[^dpkg]: `dpkg`, ou "Debian Package Manager"

[^apt-get]: `apt-get` est une surcouche de `dpkg` qui est capable
d'installer des paquets depuis des dépôts distants. `dpkg` en
contraste, ne sait installer que des paquets qui sont déjà sur le
disque

[^watchman]: un outil de surveillance d'une arborescence de fichiers,
qui peut déclencher un autre programme lors de modifications apportées
par ailleurs.

[^make]: `make`: un gestionnaire de construction, traditionnellement
utilisé pour compiler des programmes, et capable de minimiser le
nombre d'étapes d'un processus complexe et intradépendant
(<https://www.gnu.org/software/make/manual/html_node/index.html>)

[^apache]: Apache est une implémentation extensible et efficace de `httpd`,
une spécification de serveur HTTP

[^debian-repo]: disponible sur
<https://wiki.debian.org/DebianRepository/Format>

### Mises à jour des postes clients

Une fois le paquet correctement placé sur le dépôt, il suffit
d'ajouter ledit dépôt à la liste des sources
logicielles[^sources-list] et de tenter une installation de paquet
habituelle.

Cette méthode fonctionne parfaitement sur des serveurs, qui sont
perpétuellement allumés, mais risque de ne pas être suffisante pour
les installations en salle machine. En effet, au moment de
l'installation, les postes peuvent être éteints, ou (comme nous
offrons un double boot à l'UFR) démarrés sur un autres système. Ces
postes ne peuvent pas récupérer la mise à jour immédiatement, mais il
faudrait qu'ils la récupèrent lors de leur prochain redémarrage, ou
silencieusement au fil de leur utilisation.

Pour celà, j'ai choisi de représenter les installations comme des
dépendances d'un paquet "racine" (appelé `im2ag-role` dans le cas de
l'UFR IM²AG). Le système de paquet garantit que toutes les dépendances
d'un paquet sont installées avant le paquet lui-même. Ainsi, en
installant la dernière version du paquet racine à intervalles
réguliers, le gestionnaires de paquet va par la même occasion
installer les nouvelles dépendances qui y sont ajoutées. Si la
dernière version est déjà installée, le gestionnaire de paquets ne
fait rien et la machine est à jour.

C'est pourquoi, sur nos postes clients Linux, j'ai utilisé
`cron`[^cron] pour déclencher une mise à jour du paquet racine toutes
les heures. De cette manière, les machines peuvent être autonomes dans
leurs mises à jour, et n'ont que rarement besoin d'installations
lourdes comme CloneZilla.

Un autre avantage de l'approche par paquet racine se découvre lors de
l'installation d'une nouvelle machine. En l'absence d'un système de
paquets, la réponse à toutes les demandes faites au service
informatique au cours des cinq dernières années n'est pas simple,
surtout si chaque erreur coûte une journée de déploiement. Par
contraste, grâce au gestionnaire de dépendances, la simple
installation du paquet racine suffit à configurer un poste à
l'identique de ceux qui sont en salle machines, et sans intervention
humaine.

Pour donner une idée de la complexité des installations qui sont
exigées, voici un extrait de la configuration de notre paquet racine,
après quatre ans de demandes :

    Package: im2ag-role
    Version: 3.0-289
    Section: base
    Priority: optional
    Architecture: all
    Maintainer: Marc Coiffier <marc.coiffier@ujf-grenoble.fr>
    Pre-depends: im2ag-auto-ppas (>= 1.0-5)
    Depends: im2ag-core (>= 1.0-36), im2ag-drivers (>= 2.0-5),
             im2ag-bootloader (>= 1.0-20), im2ag-grub, im2ag-sh (>=
             1.0-40), im2ag-auto-updates (>= 1.0-52), im2ag-homes (>=
             1.0-5), im2ag-auth (>= 1.0-60), im2ag-greeter (>=
             1.0-22), im2ag-wallpapers (>= 1.0-8), im2ag-menus (>=
             2.0-9), im2ag-window-managers (>= 1.0-2),
             im2ag-language-support (>= 1.0), im2ag-print-client,
             im2ag-terminals, im2ag-editors (>= 1.0-16), im2ag-profs
             (>= 1.0-47), im2ag-ues (>= 1.0-6), im2ag-extras (>=
             1.0-8), im2ag-default-accounts (>= 1.0-8), im2ag-ibus (>=
             1.0-5), im2ag-vmrc-plugin (>= 5.5.0-4), im2ag-ocs-client
             (>= 1.0-2), build-essential, texlive, ddd, dbus, kate,
             clang, flex, byacc, pari-gp, r-base, cmake, rstudio (>=
             0.99), rdesktop, vncviewer, libcurl4-openssl-dev,
             libxml++2.6-dev, libxslt-dev, im2ag-salome (>= 7.7.1-3),
             inkscape, kdevelop, libopencv-dev, qemu-system-arm,
             im2ag-maven, empathy, bison, gnuplot-x11, coq, coqide,
             im2ag-modelio (>= 1.0-8), im2ag-android-studio (>=
             1.0-9), im2ag-android-studio-config (>= 1.0-7), dia,
             valgrind, arandr, libsdl2-dev, libsdl2-mixer-dev,
             libsdl2-ttf-dev, libsdl2-image-dev, im2ag-persycup (>=
             1.0-1), pinta, libnss-ldapd, libpam-ldapd, curl, r-base
             (>= 3.2), r-cran-ggplot2, r-cran-reshape, r-cran-plyr,
             im2ag-r (>= 1.0-15), qt5-doc, qt5-doc-html, python-tk,
             spyder, kde-icon-cache (>= 0.0.7-3), kwin |
             kubuntu-desktop, im2ag-nodejs (>= 1.0-14),
             cmake-curses-gui, octave, im2ag-webstorm (>= 1.0-5),
             im2ag-pycharm (>= 5.0.4-2), sagemath-upstream-binary,
             manpages-dev, manpages-fr-dev, nmap, tcl-dev,
             python-skimage, python-skimage-doc, libgtkmm-3.0-dev,
             im2ag-libtiff (>= 1.0-5), scilab-image-processing,
             cimg-dev, mesa-common-dev, libglm-dev, libglfw-dev,
             qemu-user, libopencv2.4-java, jdbcdrivers, libeigen3-dev,
             libqt5svg5-dev, docker-engine (>= 1.12), blender (>=
             2.69), texlive-lang-french, freefem++, im2ag-comsol (>=
             5.0-2), python-numpy, python-scipy, python-matplotlib,
             ganttproject, im2ag-fiji (>= 1.50-2), evoluspencil,
             klayout, im2ag-rsyslog, python-pygame, kmix, sitecopy,
             kodi, bluej, dconf-editor, texmaker, xsltproc, im2ag-z3
             (>= 1.0-1), im2ag-systemc, im2ag-intellij,
             im2ag-anyconnect, tig, manpages-posix-dev, im2ag-stlink
             (>= 1.2.0-1), im2ag-des, im2ag-sqldeveloper, idle3,
             gcc-arm-none-eabi, gdb-arm-none-eabi,
             libnewlib-arm-none-eabi, binutils-arm-none-eabi, swig,
             sublime-text, automake, autoconf, im2ag-mosek (>=
             1.0-10), scala, sbt, im2ag-scala-ide, im2ag-jupyter (>=
             1.0-5), mirage, libcgal-dev, gfortran, python-pip,
             rabbitmq-server, python3-numpy, python3-matplotlib,
             ipython3, python-cvxopt
    Provides: im2ag-glm
    Conflicts: im2ag-glm, avahi-daemon, update-notifier,
      plexmediaserver, network-manager, bbswitch-dkms, nvidia-375
    Replaces: im2ag-glm, subversion, libnss-ldapd, libpam-ldapd,
      im2ag-ldap-client (>= 1.0-12), docker-engine
    Description: Le paquet racine des machines en salle de
      TP. Installer ce paquet devrait configurer entièrement un PC pour
    l'utilisation dans les salles de l'UFR.



[^sources-list]: sur les systèmes Debian, il s'agit d'ajouter la ligne
`deb http://DEPOT DIST SECTION...` au fichier `/etc/apt/sources.list`

[^cron]: `cron` est un service Linux (aussi appelé "démon") qui
éxécute un programme à intervalles réguliers
