FROM ubuntu:16.04

RUN apt update && \
    apt install -y --no-install-recommends bash dpkg ssh sudo tzdata vim

RUN echo America/Los_Angeles > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

ARG NAME
ARG UID
ARG GID

RUN groupadd -g $GID $NAME
RUN useradd -u $UID -g $NAME --groups sudo --shell /bin/bash $NAME
RUN echo "$NAME ALL = NOPASSWD: ALL" > /etc/sudoers.d/$NAME

ADD build.sh /home/$NAME/build/
RUN chown -R $NAME:$NAME /home/$NAME
USER $NAME
WORKDIR /home/$NAME/build
RUN ./build.sh
WORKDIR /home/$NAME
