cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "flutter_js")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

add_library(${PLUGIN_NAME} SHARED
  "${PLUGIN_NAME}.cc"
)

# quickjs
set(QUICK_JS_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/quickjspp)
file (STRINGS "${QUICK_JS_LIB_DIR}/quickjs/VERSION" QUICKJS_VERSION)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DCONFIG_VERSION=\\\"${QUICKJS_VERSION}\\\"")
add_library(libquickjs SHARED
    ${QUICK_JS_LIB_DIR}/quickjs/cutils.c
    ${QUICK_JS_LIB_DIR}/quickjs/libregexp.c
    ${QUICK_JS_LIB_DIR}/quickjs/libunicode.c
    ${QUICK_JS_LIB_DIR}/quickjs/quickjs.h
    ${QUICK_JS_LIB_DIR}/quickjs/quickjs.c
)
project(libquickjs LANGUAGES C)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE libquickjs)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_js_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/libbass.so"
  PARENT_SCOPE
)
