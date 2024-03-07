# paraview-superbuild
Paraview-superbuild with some extras:
- MEDReader plugin on Mac
- LATA reader in VisItBridge

# Instructions
1) clone and cd
2) make a "build" subdiretory and cd into it
3) run one of these cmake commands :
   -  Mac: cmake -Dparaview_GIT_TAG:STRING=v5.12.0 -DCMAKE_INSTALL_PREFIX=$PWD/../bin -DENABLE_medreader:BOOL=ON -DENABLE_visitbridge:BOOL=ON -DENABLE_qt5:BOOL=ON -DQt5_DIR=/opt/homebrew/Cellar/qt@5/5.15.10/lib/cmake/Qt5 ..
   -  Linux: cmake -Dparaview_GIT_TAG:STRING=v5.12.0 -DCMAKE_INSTALL_PREFIX=$PWD/../bin -DENABLE_medreader:BOOL=ON -DENABLE_visitbridge:BOOL=ON -DENABLE_mpi:BOOL=ON -DPARAVIEW_EXTRA_CMAKE_ARGUMENTS:STRING="-DCMAKE_NO_SYSTEM_FROM_IMPORTED:BOOL=ON" ..
   -  Linux (headless, server only): cmake -Dparaview_GIT_TAG:STRING=v5.12.0 -DCMAKE_INSTALL_PREFIX=$PWD/../bin -DENABLE_medreader:BOOL=ON -DENABLE_visitbridge:BOOL=ON -DENABLE_mpi:BOOL=ON -DENABLE_egl:BOOL=ON -DPARAVIEW_EXTRA_CMAKE_ARGUMENTS:STRING="-DCMAKE_NO_SYSTEM_FROM_IMPORTED:BOOL=ON" ..
4) run make -j<N> install
5) enjoy a Paraview installation in ../bin :-)
