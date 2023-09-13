# Make a project so that the user can enable/disable openxrremoting support
superbuild_add_project(openxrremoting
  LICENSE_FILES
    "Microsoft Holographic Remoting - Software Development Kit (SDK) Use Terms.txt"
    "Third Party Notices.txt"
  CONFIGURE_COMMAND
    ""
  BUILD_COMMAND
    ""
  INSTALL_COMMAND
    "${CMAKE_COMMAND}"
      -Dsource_location:PATH=<SOURCE_DIR>
      -Dinstall_location:PATH=<INSTALL_DIR>
      -P ${CMAKE_CURRENT_LIST_DIR}/scripts/openxrremoting.install.cmake
  INSTALL_DEPENDS
      ${CMAKE_CURRENT_LIST_DIR}/scripts/openxrremoting.install.cmake
)