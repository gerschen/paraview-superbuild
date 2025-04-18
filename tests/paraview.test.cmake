set(paraview_extract_dir "${CMAKE_CURRENT_BINARY_DIR}/paraview/test-extraction")
if (WIN32)
  set(generator "ZIP")
  set(paraview_exe "${paraview_extract_dir}/bin/paraview.exe")
  set(pvpython_exe "${paraview_extract_dir}/bin/pvpython.exe")
  set(pvserver_exe "${paraview_extract_dir}/bin/pvserver.exe")
  set(pvbatch_exe  "${paraview_extract_dir}/bin/pvbatch.exe")
elseif (APPLE)
  set(generator "DragNDrop")
  include(paraview-appname)
  set(paraview_exe "${paraview_extract_dir}/${paraview_appname}/Contents/MacOS/paraview")
  set(pvpython_exe "${paraview_extract_dir}/${paraview_appname}/Contents/bin/pvpython")
  set(pvserver_exe "${paraview_extract_dir}/${paraview_appname}/Contents/bin/pvserver")
  set(pvbatch_exe  "${paraview_extract_dir}/${paraview_appname}/Contents/bin/pvbatch")
else ()
  set(generator "TGZ")
  set(paraview_exe "${paraview_extract_dir}/bin/paraview")
  set(pvpython_exe "${paraview_extract_dir}/bin/pvpython")
  set(pvserver_exe "${paraview_extract_dir}/bin/pvserver")
  set(pvbatch_exe  "${paraview_extract_dir}/bin/pvbatch")
endif ()

if (PARAVIEW_PACKAGE_FILE_NAME)
  set(glob_prefix "${PARAVIEW_PACKAGE_FILE_NAME}")
else ()
  include(paraview.suffix)
  set(name_suffix "")
  if (paraview_version_patch LESS "20200101")
    set(glob_prefix "ParaView${name_suffix}-${paraview_version_major}.${paraview_version_minor}.${paraview_version_patch}*")
  else ()
    set(glob_prefix "ParaView${name_suffix}-${paraview_version_full}*")
  endif ()
  if (PARAVIEW_PACKAGE_SUFFIX)
    string(APPEND glob_prefix "-${PARAVIEW_PACKAGE_SUFFIX}")
  endif ()
endif ()
superbuild_add_extract_test("paraview" "${glob_prefix}" "${generator}" "${paraview_extract_dir}"
  LABELS "ParaView")

if (UNIX AND NOT APPLE)
  set(ldd_excludes)
  if (openimagedenoise_SOURCE_SELECTION STREQUAL "2.7.1")
    list(APPEND ldd_excludes
      # Older OIDN forces the rpath.
      "libOpenImageDenoise")
  endif ()

  superbuild_test_loadable_modules("paraview" "${generator}" "${paraview_extract_dir}"
    EXCLUDES
      # Copied from the system; does not have rpath entries.
      "libgfortran"
      # Python stdlib requirements; provided by the system.
      "nis.cpython" # libnsl
      # Libraries which use Fortran standard libraries.
      "__nnls.cpython" # scipy
      "_cobyla.cpython" # scipy
      "_dop.cpython" # scipy
      "_fitpack.cpython" # scipy
      "_specfun.cpython" # scipy
      # Qt plugins; provided by the system.
      "libqtaudio_alsa" # libasound
      # MEDReader plugin has a test, but the rpaths are not 100% correct.
      # Ignore for now.
      "MEDReader/lib" # paraview/common-superbuild#73
      ${ldd_excludes}
      )
endif ()

if (NOT qt5_enabled AND NOT qt6_enabled)
  set(paraview_exe)
endif ()

if (NOT python3_enabled)
  set(pvpython_exe)
  set(pvbatch_exe)
endif ()

if (NOT mpi_enabled)
  set(pvbatch_exe)
endif ()

function (paraview_add_test name exe)
  if (NOT exe)
    return ()
  endif ()

  add_test(
    NAME    "paraview-${name}"
    COMMAND "${exe}"
            ${ARGN})
  set_tests_properties(paraview-${name}
    PROPERTIES
      LABELS  "ParaView"
      DEPENDS "extract-paraview-${generator}")
  if (UNIX)
    # Run unit test with EGL
    add_test(
      NAME    "paraview-egl-${name}"
      COMMAND "${exe}"
              ${ARGN})
    set_tests_properties(paraview-egl-${name}
      PROPERTIES
        ENVIRONEMNT "VTK_DEFAULT_OPENGL_WINDOW=vtkEGLRenderWindow"
        LABELS  "ParaView"
        DEPENDS "extract-paraview-${generator}")
    # Run unit test with OSMesa
    if (osmesa_enabled)
      add_test(
        NAME    "paraview-osmesa-${name}"
        COMMAND "${exe}"
                ${ARGN})
      set_tests_properties(paraview-osmesa-${name}
        PROPERTIES
          ENVIRONEMNT "VTK_DEFAULT_OPENGL_WINDOW=vtkOSOpenGLRenderWindow"
          LABELS  "ParaView"
          DEPENDS "extract-paraview-${generator}")
    endif ()
  endif ()
endfunction ()

function (paraview_add_ui_test name script)
  paraview_add_test("${name}" "${paraview_exe}"
    "--dr"
    "--test-directory=${CMAKE_BINARY_DIR}/Testing/Temporary"
    "--test-script=${CMAKE_CURRENT_LIST_DIR}/xml/${script}.xml"
    ${ARGN}
    "--exit")
endfunction ()

set(python_exception_regex "exception;Traceback")

function (paraview_add_python_test name script)
  paraview_add_test("${name}" "${pvpython_exe}"
    "${CMAKE_CURRENT_LIST_DIR}/python/${script}.py")
  # check for exceptions and tracebacks during python execution
  if (TEST "paraview-${name}")
    set_tests_properties("paraview-${name}" PROPERTIES
      FAIL_REGULAR_EXPRESSION "${python_exception_regex}"
    )
  endif ()
  if (TEST "paraview-egl-${name}")
    set_tests_properties("paraview-egl-${name}" PROPERTIES
      FAIL_REGULAR_EXPRESSION "${python_exception_regex}"
    )
  endif ()
  if (TEST "paraview-osmesa-${name}")
    set_tests_properties("paraview-osmesa-${name}" PROPERTIES
      FAIL_REGULAR_EXPRESSION "${python_exception_regex}"
    )
  endif ()
endfunction ()

function (paraview_add_pvbatch_test name script)
  paraview_add_test("${name}" "${pvbatch_exe}"
    "${CMAKE_CURRENT_LIST_DIR}/python/${script}.py")
endfunction ()

if (python3_enabled)
  # Simple test to launch the application and load all plugins.
  if (qt5_enabled)
    paraview_add_ui_test("testui" "TestUI-qt5")
  elseif (qt6_enabled)
    paraview_add_ui_test("testui" "TestUI-qt6")
  endif ()

  if (numpy_enabled)
    paraview_add_ui_test("finddata" "TestFindData"
      "--test-baseline=${CMAKE_CURRENT_LIST_DIR}/baselines/Superbuild-TestFindData.png")
  endif ()

  paraview_add_test("pvpython-help" "${pvpython_exe}"
    -c "help()")
endif ()

# Simple test to test pvpython/pvbatch.
paraview_add_python_test("pvpython" "basic_python")
if (NOT WIN32)
  # MSMPI has issues with pvbatch.
  paraview_add_pvbatch_test("pvbatch" "basic_python")
endif ()

if (numpy_enabled)
  paraview_add_python_test("import-numpy" "import_numpy")
endif ()

if (scipy_enabled) # Always packaged because the `ZIP` is tested, not the installers.
  paraview_add_python_test("import-scipy" "import_scipy")
endif ()

if (sympy_enabled)
  paraview_add_python_test("import-sympy" "import_sympy")
endif ()

if (matplotlib_enabled)
  paraview_add_python_test("import-matplotlib" "import_matplotlib")
endif ()

if (mpi_enabled AND python3_enabled)
  paraview_add_python_test("import-mpi4py" "import_mpi4py")
endif ()

if (catalyst_enabled AND numpy_enabled)
  paraview_add_python_test("import-catalyst" "import_catalyst")
  paraview_add_python_test("import-catalyst-conduit" "import_catalyst_conduit")
endif ()

if (pythonpandas_enabled)
  paraview_add_python_test("import-pandas" "import_pandas")
endif ()

if (openpmd_enabled)
  paraview_add_python_test("import-openpmd" "import_openpmd")
endif ()

if (proj_enabled AND numpy_enabled)
  paraview_add_python_test("import-vtkGeoVis" "import_vtkGeoVis")
endif ()

# Test to load various data files to ensure reader support.
if (silo_enabled)
  paraview_add_ui_test("data-csg.silo" "TestData-cs_silo"
    "--data=${CMAKE_CURRENT_LIST_DIR}/data/csg.silo")
endif ()

# Disabling this test for now since the Data file is too big. We probably need
# to add support for Data repository similar to ParaView/VTK soon.
if (xdmf3_enabled AND FALSE)
  paraview_add_ui_test("data-scenario1_p1.xmf" "TestData"
    "--data=${CMAKE_CURRENT_LIST_DIR}/data/Scenario1_p1.xmf")
endif ()

if (matplotlib_enabled)
  paraview_add_ui_test("matplotlib" "TestMatplotlib"
    "--test-baseline=${CMAKE_CURRENT_LIST_DIR}/baselines/Superbuild-TestMatplotlib.png"
    "--test-threshold=15")
endif ()

if (ospray_enabled)
  paraview_add_ui_test("ospray" "OSPRay"
    "--test-baseline=${CMAKE_CURRENT_LIST_DIR}/baselines/OSPRay.png")
endif ()

paraview_add_test("version-server" "${pvserver_exe}"
  "--version")
paraview_add_test("version-client" "${paraview_exe}"
  "--version")

if (mesa_enabled AND python3_enabled)
  set(mesa_llvm_arg)
  set(mesa_swr_arg)
  if (launchers_enabled)
    set(mesa_llvm_arg --mesa --backend llvmpipe)
    set(mesa_swr_arg --mesa --backend swr)
  endif ()

  paraview_add_test("mesa-llvm" ${pvpython_exe}
    ${mesa_llvm_arg}
    "${CMAKE_CURRENT_LIST_DIR}/python/CheckOpenGLVersion.py"
    "mesa" "llvmpipe")

  if (TEST "paraview-egl-mesa-llvm")
    # Do not run mesa llvmpipe test with egl because the bundled mesa does not provide libEGL.
    set_tests_properties(paraview-egl-mesa-llvm PROPERTIES
      DISABLED TRUE)
  endif ()
  if (mesa_USE_SWR)
    # Either don't add or add but explicitly disable this test for now
    # until the underlying VTK segfault is fixed.
    if (CMAKE_VERSION VERSION_GREATER_EQUAL 3.9)
      paraview_add_test("mesa-swr" "${pvpython_exe}"
        ${mesa_swr_arg}
        "${CMAKE_CURRENT_LIST_DIR}/python/CheckOpenGLVersion.py"
        "mesa" "swr")
      # Mesa exits with failure.
      set_tests_properties(paraview-mesa-swr PROPERTIES
        PASS_REGULAR_EXPRESSION "SWR (detected|could not initialize)"
        DISABLED TRUE)
      if (TEST "paraview-egl-mesa-swr")
        # Do not run mesa swr test with egl because the bundled mesa does not provide libEGL.
        set_tests_properties(paraview-egl-mesa-swr PROPERTIES
          DISABLED TRUE)
      endif ()
      if (TEST "paraview-osmesa-mesa-swr")
        # Do not run mesa swr test with osmesa for the same reason paraview-mesa-swr is disabled
        set_tests_properties(paraview-osmesa-mesa-swr PROPERTIES
          DISABLED TRUE)
      endif ()
    endif ()
  endif ()
endif ()

paraview_add_ui_test("loaddistributedplugins" "LoadDistributedPlugins"
  "--test-baseline=${CMAKE_CURRENT_LIST_DIR}/baselines/LoadDistributedPlugins.png")

# Supplemental plugins tests

if (vortexfinder2_enabled)
  paraview_add_ui_test("loadvortexfinderplugins" "LoadVortexFinderPlugins")
endif ()

if (cinemaexport_enabled)
  paraview_add_ui_test("loadcinemaexportplugin" "LoadCinemaExportPlugin")
endif ()

if (surfacetrackercut_enabled)
  paraview_add_ui_test("loadsurfacetrackercutplugin" "LoadSurfaceTrackerCutPlugin")
endif ()

if (medreader_enabled)
  paraview_add_ui_test("loadmedreaderplugin" "LoadMEDReaderPlugin"
    "--data-directory=${CMAKE_CURRENT_LIST_DIR}/data"
    "--test-baseline=${CMAKE_CURRENT_LIST_DIR}/baselines/LoadMEDReaderPlugin.png")
endif ()

# vtk-m tests
if (vtkm_enabled)
  paraview_add_ui_test("vtkm-contour" "VTKmContour"
    --test-plugin=VTKmFilters)
  paraview_add_ui_test("vtkm-gradient" "VTKmGradient"
    --test-plugin=VTKmFilters)
  paraview_add_ui_test("vtkm-threshold" "VTKmThreshold"
    --test-plugin=VTKmFilters)
endif ()

# Translations test
if (paraviewtranslations_enabled)
  paraview_add_test("setlanguagetofrench" "${CMAKE_COMMAND}"
    "-Dparaview_exe=${paraview_exe}"
    "-Dtest_directory=${CMAKE_BINARY_DIR}/Testing/Temporary"
    "-Dtest_xml_set=${CMAKE_CURRENT_SOURCE_DIR}/xml/SetLanguageToFrench.xml"
    "-Dtest_xml_check=${CMAKE_CURRENT_SOURCE_DIR}/xml/CheckLanguageFrench.xml"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/paraviewtranslations.cmake")
endif()
