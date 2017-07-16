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
permet l'installation parallèle des machines d'une salle, avec une
garantie d'uniformité des installations.

Le PXE (Preboot eXecution Environment, en anglais dans le texte) est
un protocole réseau, ou plutôt un ensemble de protocoles réseaux, qui
permet à des machines de démarrer un système fourni par un
serveur. Dans notre cas, ce protocole sert à démarrer un système
spécialisé dans le clonage d'images disques, du nom de CloneZilla,
auquel on demande de restaurer une image commune sur chaque poste de
notre réseau. Cette image commune doit au préalable être extraite d'un
poste d'exemple, appelé le "master", que l'on peut configurer à notre
guise avant l'extraction.

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
sauvegarde, ou un lecteur réseau, par exemple). Pour les usages de
l'UFR, j'ai choisi de garder nos images disques sur un serveur
NFS[^nfs] fourni par notre baie de stockage, de façon à ce que la même
image puisse être déployée sur plusieurs postes simultanément (ce qui
est difficile si l'image se trouve sur un disque qui ne peut être
branché que sur un seul poste).

[^nfs]: Network File System, ou "système de fichiers en réseau". Ce
protocole permet le partage de dossiers entre machines, et permet à
plusieurs client d'accéder aux mêmes données sans nécessiter de copie.

CloneZilla étant conçu comme un système de rescousse, il va par défaut
poser quelques questions à l'administrateur au moment du démarrage
pour décider des actions à effectuer. Dans un contexte de déploiement,
les réponses à ces questions sont prédéterminées et doivent être
directement communiquées à CloneZilla, de manière à éviter de fournir
16 fois les mêmes informations (et l'erreur humaine qui en
découle). Voici un exemple de la configuration du chargeur d'amorçage
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



En résumé, la mise en place d'une infrastructure de déploiement a
nécessité l'acquisition et la mise en oeuvre de compétences diverses
d'installation et de configuration de services qui oeuvrent sur le
réseau. 

