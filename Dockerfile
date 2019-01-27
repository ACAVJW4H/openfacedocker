# https://www.learnopencv.com/install-opencv3-on-ubuntu/

FROM ubuntu:18.04
ENV OPENCV_VERSION 3.4.5

# Install all dependencies for OpenCV
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        python2.7 \
        python2.7-dev \
        git \
        wget \
        unzip \
        cmake \
        curl \
        llvm \
        clang-3.7 \
        libc++-dev \
        libc++abi-dev \
        build-essential \
        pkg-config \
        libatlas-base-dev \
        gfortran \
        libjasper-dev \
        libgtk2.0-dev \
        libopenblas-dev \
        liblapack-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libv4l-dev \
        python-dev \
        python-numpy \
        libtbb2 \
        libtbb-dev \
        checkinstall \
        nano \
        libboost-all-dev=1.58.0.1ubuntu1 \
        libdc1394-22-dev \
    &&  rm -rf /var/lib/apt/lists/*  \

# install python dependencies
&& wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py && \
    pip install numpy \

# Download OpenCV
&&  wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip -O opencv3.zip && \
    unzip -q opencv3.zip && \
    mv /opencv-$OPENCV_VERSION /opencv && \
    rm opencv3.zip && \
    wget https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip -O opencv_contrib3.zip && \
    unzip -q opencv_contrib3.zip && \
    mv /opencv_contrib-$OPENCV_VERSION /opencv_contrib && \
    rm opencv_contrib3.zip \

# Prepare OpenCV build
&&  mkdir /opencv/build && cd /opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_PYTHON_SUPPORT=ON \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
    -D BUILD_EXAMPLES=OFF \
    -D WITH_IPP=OFF \
    -D WITH_FFMPEG=ON \
    -D WITH_CUDA=OFF \
    -D BUILD_TIFF=ON \
    -D WITH_TBB=ON \
    -D WITH_JASPER = OFF \
    -D BUILD_SHARED_LIBS=OFF \
    -D WITH_V4L=ON .. \

# Install OpenCV
&&  cd /opencv/build && \
    make -j$(nproc) && \
    make install && \
    ldconfig; && \

# Install DLib
    cd ~ && mkdir -p dlib && \
    git clone https://github.com/davisking/dlib.git dlib/ && \
    cd dlib/ && \
    mkdir build && cd build && \
    cmake .. -DUSE_AVX_INSTRUCTIONS=1 && \
    cmake --build . --config Release && \
    make install && \
    ldconfig && \

# Install OpenFace
    cd ~ && mkdir -p OpenFace && \
    git clone https://github.com/TadasBaltrusaitis/OpenFace.git OpenFace/ && \
    cd ~/OpenFace && chmod +x ./download_models.sh && ~/OpenFace/download_models.sh && \
    cd ~/OpenFace/ &&  sed -i -e 's/19.13/19.16/g' CMakeLists.txt && mkdir -p build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE ..  && \
    make -j$(nproc) && \
    cd .. && \
    echo "OpenFace successfully installed."
