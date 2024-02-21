#!/bin/sh

XVFB_RUN=""
if test `uname` = "Linux"
then
  XVFB_RUN="xvfb-run -s '-screen 0 640x480x24'"
fi

# hmaarrfk -- 2023/11/17
# Qt seems to look for the VULKAN_SDK environment variable when detecting vulkan support
export VULKAN_SDK=${PREFIX}

pushd sources/shiboken6

if test "$CONDA_BUILD_CROSS_COMPILATION" = "1"
then
  (
    mkdir -p build_native && cd build_native

    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH//$PREFIX/$BUILD_PREFIX}
    export CFLAGS=${CFLAGS//$PREFIX/$BUILD_PREFIX}
    export CXXFLAGS=${CXXFLAGS//$PREFIX/$BUILD_PREFIX}

    # hide host libs
    mkdir -p $BUILD_PREFIX/${HOST}
    mv $BUILD_PREFIX/${HOST} _hidden

    cmake -LAH -G "Ninja" \
      -DCMAKE_PREFIX_PATH=${BUILD_PREFIX} \
      -DCMAKE_IGNORE_PREFIX_PATH="${PREFIX}" \
      -DCMAKE_INSTALL_RPATH:STRING=${BUILD_PREFIX}/lib \
      -DCMAKE_RANLIB=$BUILD_PREFIX/bin/${CONDA_TOOLCHAIN_BUILD}-ranlib \
      -DCMAKE_INSTALL_PREFIX=${BUILD_PREFIX} \
      -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
      -DBUILD_TESTS=OFF \
    ..
    cmake --build . --target install
    mv _hidden $BUILD_PREFIX/${HOST}
  )
  # wrapper path is hardcoded in sources/shiboken6/cmake/ShibokenHelpers.cmake:
  mkdir -p ${BUILD_PREFIX}/../build/shiboken6/.qfp/bin
  echo -e '#!/bin/bash\n$@' > ${BUILD_PREFIX}/../build/shiboken6/.qfp/bin/shiboken_wrapper.sh
  chmod +x ${BUILD_PREFIX}/../build/shiboken6/.qfp/bin/shiboken_wrapper.sh

  rm -r build_native
  CMAKE_ARGS="${CMAKE_ARGS} -DQFP_SHIBOKEN_HOST_PATH=${BUILD_PREFIX} -DQT_HOST_PATH=${BUILD_PREFIX} -DQFP_PYTHON_HOST_PATH=${BUILD_PREFIX}/bin/python"

  if test `uname` = "Darwin"
  then
    CMAKE_ARGS="${CMAKE_ARGS} -DPython_SOABI=cpython-${PY_VER//./}-darwin"
  fi
fi

mkdir build && cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DBUILD_TESTS=OFF \
  ..
cmake --build . --target install
popd

mkdir ${SP_DIR}/shiboken6-${PKG_VERSION}.dist-info
cp ${RECIPE_DIR}/METADATA.shiboken6.in ${SP_DIR}/shiboken6-${PKG_VERSION}.dist-info/METADATA
echo "Version: ${PKG_VERSION}" >> ${SP_DIR}/shiboken6-${PKG_VERSION}.dist-info/METADATA

pushd sources/pyside6
mkdir build && cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_MACOSX_RPATH=ON \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -D_qt5Core_install_prefix=${PREFIX} \
  -DBUILD_TESTS=ON \
  ..
cmake --build . --target install

mkdir ${SP_DIR}/PySide6-${PKG_VERSION}.dist-info
cp ${RECIPE_DIR}/METADATA.pyside6.in ${SP_DIR}/PySide6-${PKG_VERSION}.dist-info/METADATA
echo "Version: ${PKG_VERSION}" >> ${SP_DIR}/PySide6-${PKG_VERSION}.dist-info/METADATA
cat ${SP_DIR}/PySide6-${PKG_VERSION}.dist-info/METADATA

if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  cp -v ./tests/pysidetest/libpysidetest${SHLIB_EXT} ${PREFIX}/lib
  cp -v ./tests/pysidetest/testbinding.abi3.so ${SP_DIR}
  eval ${XVFB_RUN} ctest -j${CPU_COUNT} --output-on-failure --timeout 30 -V || echo "no ok"
  rm ${PREFIX}/lib/libpysidetest${SHLIB_EXT} ${SP_DIR}/testbinding.abi3.so
fi

popd

pushd sources/pyside-tools
mkdir build && cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  ..
cmake --build . --target install

# Move pyside_tool.py to the right location
mkdir -p "${SP_DIR}"/PySide6/scripts
touch "${SP_DIR}"/PySide6/scripts/__init__.py
mv ${PREFIX}/bin/pyside_tool.py "${SP_DIR}"/PySide6/scripts/pyside_tool.py
