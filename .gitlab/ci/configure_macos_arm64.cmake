set(CMAKE_OSX_DEPLOYMENT_TARGET 11.0 CACHE STRING "")

# GCC doesn't build yet on aarch64-apple-darwin.
#   https://gcc.gnu.org/bugzilla/show_bug.cgi?id=96168
#   https://github.com/iains/gcc-darwin-arm64#readme
set(ENABLE_fortran OFF CACHE BOOL "")
set(ENABLE_scipy OFF CACHE BOOL "")
set(ENABLE_surfacetrackercut OFF CACHE BOOL "")

# TBB doesn't provide arm64 binaries for macOS yet.
set(ENABLE_tbb OFF CACHE BOOL "")

# No LookingGlass binaries for arm64 yet.
set(ENABLE_lookingglass OFF CACHE BOOL "")

include("${CMAKE_CURRENT_LIST_DIR}/configure_macos.cmake")