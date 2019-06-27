FROM ubuntu:18.04
ENV OPENCV_VERSION 3.4.6
# Install all dependencies for OpenCV
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        ca-certificates \
        python2.7 \
        python2.7-dev \
        git \
        wget \
        unzip \
        cmake \
        curl \
        llvm \
        ffmpeg \
        clang-3.7 \
        build-essential \
        pkg-config \
        gfortran \
        v4l-utils \
        python-dev \
        python-numpy \
        nano \
        libatlas-base-dev \
        libc++-dev \
        libc++abi-dev \
        libtbb2 \
        libtbb-dev \
        libprotobuf-dev \
        libglew-dev \ 
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
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libswscale-dev \
        libeigen3-dev \
        libboost-all-dev \
        libdc1394-22-dev \
        libgl1-mesa-dri \
	    libgl1-mesa-glx \
        zlib1g-dev \
    &&  rm -rf /var/lib/apt/lists/* && \
# install python dependencies
    wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py && \
    pip install numpy;
# Download OpenCV
RUN wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip -O opencv3.zip && \
    unzip -q opencv3.zip && \
    mv /opencv-$OPENCV_VERSION /opencv && \
    rm opencv3.zip && \
    wget https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip -O opencv_contrib3.zip && \
    unzip -q opencv_contrib3.zip && \
    mv /opencv_contrib-$OPENCV_VERSION /opencv_contrib && \
    rm opencv_contrib3.zip && \
# Prepare OpenCV build
    mkdir /opencv/build && cd /opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D BUILD_opencv_java=OFF \
    -D BUILD_PYTHON_SUPPORT=ON \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D WITH_IPP=OFF \
    -D WITH_FFMPEG=ON \
    -D WITH_CUDA=OFF \
    -D BUILD_TIFF=OFF \
    -D WITH_TBB=ON \
    -D WITH_JASPER=OFF \
    -D BUILD_SHARED_LIBS=OFF \
    -D WITH_WEBP=OFF \
    -D WITH_IMGCODEC_SUNRASTER=OFF \
    -D WITH_IMGCODEC_HDR=OFF \
    -D WITH_IMGCODEC_PXM=OFF \
    -D WITH_GTK=ON \
    -D WITH_V4L=ON ..  && \
# Install OpenCV
    cd /opencv/build && \
    make -j$(nproc) && \
    make install && \
    ldconfig;
# Install DLib
RUN cd ~ && mkdir -p dlib && \
    git clone --depth 1 https://github.com/davisking/dlib.git dlib/ && \
    cd dlib/ && \
    mkdir build && cd build && \
    cmake .. -DUSE_AVX_INSTRUCTIONS=1 && \
    cmake --build . --config Release && \
    make install && \
    ldconfig
# Install OpenFace
RUN cd ~ && mkdir -p OpenFace && \
    git clone --depth 1 https://github.com/TadasBaltrusaitis/OpenFace.git OpenFace/ && \
    cd ~/OpenFace && chmod +x ./download_models.sh && ~/OpenFace/download_models.sh && \
    cd ~/OpenFace/ &&  sed -i -e 's/19.13/19.17/g' CMakeLists.txt && mkdir -p build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE ..  && \
    make -j$(nproc) && \
    cd .. && \
    echo "OpenFace successfully installed."
ENTRYPOINT ["/bin/bash"]
