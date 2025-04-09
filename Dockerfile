# Base image
FROM ubuntu:20.04

# Set timezone to avoid interactive prompts
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    libsystemd-dev \
    libssl-dev \
    pkg-config \
    libx11-dev \
    libglu1-mesa-dev \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-doc \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio \
    emacs \
    unzip \
    apache2 \
    git && \
    apt-get clean

# Create necessary directories
RUN mkdir -p /home/together/Devel/app && \
    mkdir -p /home/together/Devel/together && \
    mkdir -p /home/together/.together/prod && \
    mkdir -p /home/together/.together/1.0.0 && \
    mkdir -p /home/together/.together/servers && \
    mkdir -p /home/together/.together/Together && \
    mkdir -p /home/together/incoming && \
    mkdir -p /home/together/gambit/app && \ 
    chmod 777 /home/together/incoming

# Clone repositories
WORKDIR /home/together/Devel/app
RUN git clone https://github.com/jazzscheme/jas-linux jas

WORKDIR /home/together/Devel/together 
RUN git clone -b stable https://github.com/gcartier/together prod && \
   cd prod && \
   mkdir -p /home/together/Devel/together/prod/update && \
   git clone -b stable https://github.com/gcartier/world && \
   git clone -b stable https://github.com/gcartier/jiri && \
   git clone -b stable https://github.com/jazzscheme/jazz && \
   git clone -b stable https://github.com/jazzscheme/gaea

   #git clone https://github.com/gcartier/together-server server

# WORKDIR /home/together/Devel/together/server/home
# RUN cp .emacs .gitconfig .profilerc $HOME 
# RUN cat .emacs .profilerc >> $HOME/.bashrc 


WORKDIR /home/together/gambit/app
RUN git clone https://github.com/jazzscheme/gambit devel && \
    cd devel && \
    ./configure '--enable-single-host' '--enable-openssl' '--enable-rtlib-debug-location' '--enable-rtlib-debug-environments' '--enable-systemd' && \
    make -j2 && \
    make install 




WORKDIR /home/together/Devel/together/prod
RUN echo "export JAZCONF=prod" > .jaz && \
    export PATH=$PATH:/home/together/gambit/app/devel/gsc && \
    ./jaz make kernel && \
    ./jaz make jazz && \
    ./jaz make zlib && \
    ./jaz download && \
    ./jaz make -j 2 

 
# Set up system configurations
RUN echo "net.ipv4.tcp_keepalive_time=60" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_keepalive_intvl=60" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_keepalive_probes=5" >> /etc/sysctl.conf && \
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

# Copy systemd service and socket files, .server file
COPY together-prod.service /etc/systemd/system/together-prod.service
COPY together-prod.socket /etc/systemd/system/together-prod.socket
COPY jazz.server /home/together/.together/.server

# Reload systemd to recognize the new files
RUN systemctl daemon-reload

# Enable the service and socket
RUN systemctl enable together-prod.service together-prod.socket
RUN systemctl start together-prod

# Expose necessary ports
EXPOSE 50000-50050 50100-50150 50200-50250 50300-50350 50400-50450 50500-50550 51000-51050

# Set up entrypoint
CMD ["/bin/bash"]
