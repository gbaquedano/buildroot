Buildroot
=========

Dependencias
------------
En ubuntu, instalar las dependencias

	sudo apt-get install build-essential git subversion cvs unzip whois ncurses-dev bc mercurial

Compilando
----------
Obtener el código con

	git clone git://github.com/gbaquedano/buildroot.git

o

	git clone https://github.com/gbaquedano/buildroot.git

seguido de

	cd buildroot

y configúralo

	make raspberrypi2_urt_defconfig

si deseas añadir paquetes adicionales

	make menuconfig

o modificar opciones del Kernel

	make linux-menuconfig

para iniciar la compilación

	make

