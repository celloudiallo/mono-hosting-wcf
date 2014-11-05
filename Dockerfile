FROM opensuse:13.2
MAINTAINER Jeff Bonhag <jbonhag@sca-corp.com>

RUN zypper --gpg-auto-import-keys ref
RUN useradd -m docker -G wheel

RUN zypper --non-interactive in sudo
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker

RUN sudo zypper --non-interactive in wget tar
RUN sudo zypper --non-interactive in gcc gcc-c++ gettext make
RUN sudo zypper --non-interactive in ca-certificates unzip autoconf libtool which apache2 apache2-devel
RUN sudo zypper --non-interactive in sqlite3
RUN sudo zypper --non-interactive in ed


WORKDIR /home/docker
RUN wget http://download.mono-project.com/sources/mono/mono-3.6.0.tar.bz2
RUN tar xvf mono-3.6.0.tar.bz2
WORKDIR mono-3.6.0
RUN ./configure && make
RUN sudo make install

WORKDIR /home/docker
RUN wget https://github.com/mono/mod_mono/archive/3.8.zip
RUN unzip 3.8.zip
WORKDIR mod_mono-3.8
RUN ./autogen.sh
RUN make
RUN sudo make install

WORKDIR /home/docker
RUN wget https://github.com/mono/xsp/archive/3.0.11.zip
RUN unzip 3.0.11.zip
WORKDIR xsp-3.0.11
RUN ./autogen.sh
RUN make
RUN sudo make install

# now, we dance
WORKDIR /home/docker
RUN wget https://github.com/jeffbonhag/greetz/archive/master.zip
RUN unzip master.zip
WORKDIR greetz-master

# BUILD, DEPLOY
RUN make deploy

# final apache tweaks
RUN ed -s /etc/apache2/httpd.conf <<< $'185d\nw'

# configuration
ADD greetz.conf /etc/apache2/conf.d/greetz.conf

# RUN
EXPOSE 80
CMD ["sudo", "/usr/sbin/apache2ctl", "-D",  "FOREGROUND"]

