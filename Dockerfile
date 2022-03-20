FROM ubuntu:20.04
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Preferre IPv4 over IPv6 when host supports both
RUN sed -i '/precedence.*::ffff:0:0\/96.*100/s/^#//' /etc/gai.conf

RUN apt-get update && apt-get dist-upgrade -yf && apt-get clean && apt-get autoremove
RUN apt-get install -y git subversion axel wget zip unzip cmake build-essential pulseaudio

RUN apt-get install -y libcanberra-gtk-module xterm

RUN apt install -y python3-gi gobject-introspection gir1.2-gtk-3.0
RUN apt install -y libcanberra-gtk-module libcanberra-gtk3-module

WORKDIR /usr/local/src/
RUN wget https://github.com/gnuradio/gnuradio/releases/download/v3.8.2.0/gnuradio-3.8.2.0.tar.xz
RUN tar xvf gnuradio*.tar.xz

RUN apt install -y swig python3-pkgconfig
RUN apt-get install -y cmake git g++ libboost-all-dev swig libzmq3-dev \
	libfftw3-dev libgsl-dev libcppunit-dev doxygen libcomedi-dev  \
	libsdl1.2-dev libusb-1.0-0-dev pkg-config

RUN apt-get install -y git cmake g++ libboost-all-dev libgmp-dev \
  swig python3-numpy python3-mako python3-sphinx python3-lxml \
  doxygen libfftw3-dev libcomedi-dev libsdl1.2-dev libgsl-dev \
  libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 liblog4cpp5-dev \
  libzmq3-dev python3-yaml python3-click python3-click-plugins
RUN apt-get install -y python3-cairo-dev python3-cairo python3-gi-cairo libcairo2 libcairo-gobject2 libpangocairo-1.0-0

RUN apt-get install -y libgps-dev libboost-python-dev libudev-dev gpsd-clients python3-gps gpsd libgps-dev libgps26 gpsd gpsd-clients python3-gps

WORKDIR /usr/src
RUN git clone --recursive https://github.com/gnuradio/volk.git && \
    mkdir /usr/src/volk/build
WORKDIR /usr/src/volk/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 ../ && \
    make -j$(nproc) && \
    make install && \
    ldconfig

#RUN git clone https://github.com/EttusResearch/liberio.git
#WORKDIR /usr/local/src/liberio
#RUN autoreconf -i
#RUN ./configure 
#RUN make && make install

#WORKDIR /usr/local/src/
#RUN wget https://github.com/EttusResearch/uhd/archive/v3.14.1.1.L.tar.gz
#RUN tar xvf v3*.tar.gz

#RUN \
#        cd /usr/local/src/uhd-*/host && \
#        mkdir build && \
#        cd build && \
#        cmake ../ -DENABLE_PYTHON3=ON -DENABLE_PYTHON_API=on && \
#        make -j8 && \
#        make install

WORKDIR /usr/local/src/
RUN apt-get install -y libqt5svg5-dev portaudio19-dev libthrift-dev libgsm1-dev libcodec2-dev libmpfr-dev
RUN \
        cd /usr/local/src/gnuradio-* && \
        mkdir build && \
        cd build && \
        cmake .. -DPYTHON_EXECUTABLE=$(which python3) \
                -DENABLE_GNURADIO_RUNTIME=on \
                -DENABLE_GR_CTRLPORT=on \
                -DENABLE_GR_BLOCKS=on \
                -DENABLE_GR_FEC=on \
                -DENABLE_GR_FFT=on \
                -DENABLE_GR_ANALOG=on \
                -DENABLE_GR_DIGITAL=on \
                -DENABLE_GR_DTV=on \
                -DENABLE_GR_AUDIO=on \
                -DENABLE_GR_QTGUI=on \
                -DENABLE_GR_TRELLIS=on \
#                -DENABLE_GR_UHD=ON \
                -DENABLE_GR_UTILS=on \
                -DENABLE_GR_VOCODER=on \
                -DENABLE_GR_WAVELET=on \
                -DENABLE_GR_ZEROMQ=on \
                -DENABLE_GRC=on 

WORKDIR /usr/local/src/gnuradio-3.8.2.0/build
RUN make -j 8
RUN make install
ENV PYTHONPATH /usr/local/lib/python3/dist-packages/
ENV LD_LIBRARY_PATH /usr/local/lib/

#RUN uhd_images_downloader

ENV XDG_RUNTIME_DIR /tmp/
RUN apt-get update
RUN apt-get install -y librtlsdr-dev
RUN \
        cd /usr/local/src/ && \
        git clone git://git.osmocom.org/gr-osmosdr -b gr3.8 && \
        cd gr-osmosdr && \
        mkdir build && \
        cd build && \
        cmake ../ \
                -DENABLE_HACKRF=on \
                && \
        make -j8 && \
        make install && \
        ldconfig

RUN  apt-get install -y autoconf libtalloc-dev libgnutls28-dev libmnl-dev libsctp-dev libpcsclite-dev
RUN \
        cd /usr/local/src/ && \
        git clone git://git.osmocom.org/libosmocore.git  && \
        cd libosmocore && \
        autoreconf -i && \
        ./configure && \
        make -j8 && \
        make install && \
        ldconfig -i


WORKDIR /usr/local/src/
RUN git clone https://git.osmocom.org/gr-gsm gr-gsm
WORKDIR /usr/local/src/gr-gsm/build
RUN cmake ..
RUN mkdir $HOME/.grc_gnuradio/ $HOME/.gnuradio/
RUN make
RUN make install
RUN ldconfig


RUN DEBIAN_FRONTEND=noninteractive  apt-get install -y vim wireshark net-tools mplayer python3-scapy
WORKDIR /usr/local/src/
RUN git clone https://github.com/Oros42/IMSI-catcher.git

RUN apt-get install -y libfaad-dev

RUN git clone https://github.com/andrmuel/gr-dab.git
COPY gr_dab_CMakeLists.txt /usr/local/src/gr-dab/python/app/CMakeLists.txt
WORKDIR /usr/local/src/gr-dab/build
RUN cmake ../
RUN make
RUN make install
RUN ldconfig

RUN apt-get install -y alsa-base pulseaudio
WORKDIR /usr/local/src/
COPY dab_test.sh .

RUN git clone https://github.com/bistromath/gr-ais.git
WORKDIR /usr/local/src/gr-ais/build
RUN cmake ../
RUN make
RUN make install
RUN ldconfig
WORKDIR /usr/local/src/

RUN apt-get install -y python3-gevent python3-flask-socketio python3-zmq
RUN git clone https://github.com/mhostetter/gr-adsb.git
WORKDIR /usr/local/src/gr-adsb/build
RUN cmake ../
RUN make
RUN make install
RUN ldconfig

WORKDIR /usr/local/src/
RUN git clone https://github.com/muccc/gr-iridium.git
WORKDIR /usr/local/src/gr-iridium/
RUN git checkout maint-3.8
WORKDIR /usr/local/src/gr-iridium/build
RUN cmake ../
RUN make
RUN make install
RUN ldconfig
RUN apt-get install -y python3-scipy


WORKDIR /usr/local/src/
ENTRYPOINT      ["/bin/bash"]
