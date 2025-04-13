# paraview-superbuild
Paraview-superbuild with some extras:
- MEDReader plugin on Mac
- LATA reader in VisItBridge

# Instructions
1) clone and cd
2) make a "build" subdiretory and cd into it
3) run one of these cmake commands :
   -  Mac: cmake -Dparaview_GIT_TAG:STRING=b879efe3 -Dmedcoupling_GIT_TAG:STRING=f43dae0 -Dmedconfiguration_GIT_TAG:STRING=e749ee22 -Dmedreader_GIT_TAG:STRING=706dd5b -DCMAKE_INSTALL_PREFIX=$PWD/../bin -DENABLE_medreader:BOOL=ON -DENABLE_visitbridge:BOOL=ON -DENABLE_qt5:BOOL=ON -DQt5_DIR=<location of cmake/Qt5> -DPARAVIEW_EXTRA_CMAKE_ARGUMENTS:STRING=-DPARAVIEW_QT_VERSION=5 ..
   -  Linux: cmake -Dparaview_GIT_TAG:STRING=b879efe3 -Dmedcoupling_GIT_TAG:STRING=f43dae0 -Dmedconfiguration_GIT_TAG:STRING=e749ee22 -Dmedreader_GIT_TAG:STRING=706dd5b -DCMAKE_INSTALL_PREFIX=$PWD/../bin -DENABLE_medreader:BOOL=ON -DENABLE_visitbridge:BOOL=ON -DENABLE_mpi:BOOL=ON -DPARAVIEW_EXTRA_CMAKE_ARGUMENTS:STRING="-DCMAKE_NO_SYSTEM_FROM_IMPORTED:BOOL=ON" ..
   -  Linux (headless, server only): cmake -Dparaview_GIT_TAG:STRING=b879efe3 -Dmedcoupling_GIT_TAG:STRING=f43dae0 -Dmedconfiguration_GIT_TAG:STRING=e749ee22 -Dmedreader_GIT_TAG:STRING=706dd5b -DCMAKE_INSTALL_PREFIX=$PWD/../bin -DENABLE_medreader:BOOL=ON -DENABLE_visitbridge:BOOL=ON -DENABLE_mpi:BOOL=ON -DENABLE_egl:BOOL=ON -DPARAVIEW_EXTRA_CMAKE_ARGUMENTS:STRING="-DCMAKE_NO_SYSTEM_FROM_IMPORTED:BOOL=ON" ..
4) run make -j1 install
5) enjoy a Paraview installation in ../bin :-)
