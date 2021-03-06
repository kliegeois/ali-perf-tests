
cmake_minimum_required(VERSION 2.6.4)

PROJECT(ALI_PERF_TESTS NONE)

# Get Trilinos as one entity
IF (DEFINED TRILINOS_DIR)
  SET(CMAKE_PREFIX_PATH ${TRILINOS_DIR} ${CMAKE_PREFIX_PATH})
ENDIF()
FIND_PACKAGE(Trilinos REQUIRED)

SET(Trilinos_BIN_DIRS "${Trilinos_DIR}/../../../bin")

MESSAGE("\nFound Trilinos!  Here are the details: ")
MESSAGE("   Trilinos_DIR = ${Trilinos_DIR}")
MESSAGE("   Trilinos_VERSION = ${Trilinos_VERSION}")
MESSAGE("   Trilinos_BIN_DIRS = ${Trilinos_BIN_DIRS}")
MESSAGE("   Trilinos_TPL_LIST = ${Trilinos_TPL_LIST}")
MESSAGE("   Trilinos_TPL_LIBRARY_DIRS = ${Trilinos_TPL_LIBRARY_DIRS}")
MESSAGE("   Trilinos_BUILD_SHARED_LIBS = ${Trilinos_BUILD_SHARED_LIBS}")
MESSAGE("   Trilinos_CXX_COMPILER_FLAGS = ${Trilinos_CXX_COMPILER_FLAGS}")
MESSAGE("End of Trilinos details\n")

# Ensure SEACASIoss, Iopx are available
LIST(FIND Trilinos_PACKAGE_LIST SEACASIoss SEACASIoss_List_ID)
IF (SEACASIoss_List_ID GREATER -1)
  MESSAGE("-- Looking for SEACASIoss (required) in Trilinos ...        Found!")
ELSE()
  MESSAGE("-- Looking for SEACASIoss (required) in Trilinos ...    NOT Found")
  MESSAGE(FATAL_ERROR "ALI performance tests REQUIRE SEACASIoss. Please, configure Trilinos with guidance from trilinos-cmake script in doc directory.")
ENDIF()

# Find SEACAS decomp
find_program(
  ALBANY_SEACAS_DECOMP
  NAMES decomp
  PATHS ${Trilinos_BIN_DIRS} ENV PATH
)
MESSAGE("-- ALBANY_SEACAS_DECOMP  = ${ALBANY_SEACAS_DECOMP}")

# Configure for openmp or cuda
IF(EXISTS "${Trilinos_INCLUDE_DIRS}/KokkosCore_config.h")
  FILE(READ "${Trilinos_INCLUDE_DIRS}/KokkosCore_config.h" KOKKOS_CORE_CONFIG_FILE)
  STRING(REGEX MATCH "#define KOKKOS_ENABLE_OPENMP" ALBANY_ENABLE_OPENMP ${KOKKOS_CORE_CONFIG_FILE})
  IF(ALBANY_ENABLE_OPENMP)
    MESSAGE("-- Kokkos is configured to use OpenMP, Albany will also.")
  ENDIF()
  STRING(REGEX MATCH "#define KOKKOS_ENABLE_CUDA" ALBANY_ENABLE_CUDA ${KOKKOS_CORE_CONFIG_FILE})
  IF(ALBANY_ENABLE_CUDA)
    MESSAGE("-- Kokkos is configured to use CUDA, Albany will also.")
    STRING(REGEX MATCH "#define KOKKOS_COMPILER_CUDA_VERSION ([0-9]*)" _ ${KOKKOS_CORE_CONFIG_FILE})
    SET(ALBANY_CUDA_COMPILER_VERSION "${CMAKE_MATCH_1}")
    MESSAGE("-- ALBANY_CUDA_COMPILER_VERSION = ${ALBANY_CUDA_COMPILER_VERSION}")
  ENDIF()
ELSE()
  MESSAGE(FATAL_ERROR "\nError: ${Trilinos_INCLUDE_DIRS}/KokkosCore_config.h not found!")
ENDIF()

# Define Albany executable paths
#FIXME: throw error if Albany doesn't have ALI enabled? 
IF (DEFINED SFAD4_EXE_DIR)
  MESSAGE("\n-- SFAD4_EXE_DIR set: ${SFAD4_EXE_DIR}.")
  SET(SFAD4ExePath ${SFAD4_EXE_DIR}/src/Albany) 
  SET(SFAD4ExeAnalysisPath ${SFAD4_EXE_DIR}/src/AlbanyAnalysis) 
ELSE()
  MESSAGE(FATAL_ERROR "SFAD4_EXE_DIR not set!")
ENDIF()
IF (DEFINED SFAD6_EXE_DIR)
  MESSAGE("-- SFAD6_EXE_DIR set: ${SFAD6_EXE_DIR}.")
  SET(SFAD6ExePath ${SFAD6_EXE_DIR}/src/Albany) 
  SET(SFAD6ExeAnalysisPath ${SFAD6_EXE_DIR}/src/AlbanyAnalysis) 
ELSE()
  MESSAGE(FATAL_ERROR "SFAD6_EXE_DIR not set!")
ENDIF()
IF (DEFINED SFAD8_EXE_DIR)
  MESSAGE("-- SFAD8_EXE_DIR set: ${SFAD8_EXE_DIR}.")
  SET(SFAD8ExePath ${SFAD8_EXE_DIR}/src/Albany) 
  SET(SFAD8ExeAnalysisPath ${SFAD8_EXE_DIR}/src/AlbanyAnalysis) 
ELSE()
  MESSAGE(FATAL_ERROR "SFAD8_EXE_DIR not set!")
ENDIF()
IF (DEFINED SFAD12_EXE_DIR)
  MESSAGE("-- SFAD12_EXE_DIR set: ${SFAD12_EXE_DIR}.")
  SET(SFAD12ExePath ${SFAD12_EXE_DIR}/src/Albany) 
  SET(SFAD12ExeAnalysisPath ${SFAD12_EXE_DIR}/src/AlbanyAnalysis) 
ELSE()
  MESSAGE(FATAL_ERROR "SFAD12_EXE_DIR not set!")
ENDIF()
IF (DEFINED MESH_FILE_DIR)
  MESSAGE("-- MESH_FILE_DIR set: ${MESH_FILE_DIR}.\n")
ELSE()
  MESSAGE(FATAL_ERROR "MESH_FILE_DIR not set!")
ENDIF()

# Define Albany executables, procs and args
IF(ALBANY_ENABLE_CUDA)
  SET(ALBANY_NUM_PROCS 8)
  SET(ALBANY_SFAD4_EXE ${Trilinos_MPI_EXEC} "--map-by" "ppr:2:socket" ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD4ExePath})
  SET(ALBANY_SFAD6_EXE ${Trilinos_MPI_EXEC} "--map-by" "ppr:2:socket" ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD6ExePath})
  SET(ALBANY_SFAD8_EXE ${Trilinos_MPI_EXEC} "--map-by" "ppr:2:socket" ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD8ExePath})
  SET(ALBANY_SFAD12_EXE ${Trilinos_MPI_EXEC} "--map-by" "ppr:2:socket" ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD12ExePath})
  SET(ALBANY_ANALYSIS_SFAD4_EXE ${Trilinos_MPI_EXEC} "--map-by" "ppr:2:socket" ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD4ExeAnalysisPath})
  SET(ALBANY_ANALYSIS_SFAD6_EXE ${Trilinos_MPI_EXEC} "--map-by" "ppr:2:socket" ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD6ExeAnalysisPath})
  SET(ALBANY_ANALYSIS_SFAD8_EXE ${Trilinos_MPI_EXEC} "--map-by" "ppr:2:socket" ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD8ExeAnalysisPath})
  SET(ALBANY_ANALYSIS_SFAD12_EXE ${Trilinos_MPI_EXEC} "--map-by" "ppr:2:socket" ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD12ExeAnalysisPath})
  SET(ALBANY_EXTRA_ARGS "--kokkos-num-devices=4")
ELSE()
  SET(ALBANY_NUM_PROCS 384)
  SET(ALBANY_SFAD4_EXE ${Trilinos_MPI_EXEC} "--bind-to" "core" "--npernode" 48 ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD4ExePath})
  SET(ALBANY_SFAD6_EXE ${Trilinos_MPI_EXEC} "--bind-to" "core" "--npernode" 48 ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD6ExePath})
  SET(ALBANY_SFAD8_EXE ${Trilinos_MPI_EXEC} "--bind-to" "core" "--npernode" 48 ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD8ExePath})
  SET(ALBANY_SFAD12_EXE ${Trilinos_MPI_EXEC} "--bind-to" "core" "--npernode" 48 ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD12ExePath})
  SET(ALBANY_ANALYSIS_SFAD4_EXE ${Trilinos_MPI_EXEC} "--bind-to" "core" "--npernode" 48 ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD4ExeAnalysisPath})
  SET(ALBANY_ANALYSIS_SFAD6_EXE ${Trilinos_MPI_EXEC} "--bind-to" "core" "--npernode" 48 ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD6ExeAnalysisPath})
  SET(ALBANY_ANALYSIS_SFAD8_EXE ${Trilinos_MPI_EXEC} "--bind-to" "core" "--npernode" 48 ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD8ExeAnalysisPath})
  SET(ALBANY_ANALYSIS_SFAD12_EXE ${Trilinos_MPI_EXEC} "--bind-to" "core" "--npernode" 48 ${Trilinos_MPI_EXEC_NUMPROCS_FLAG} ${ALBANY_NUM_PROCS} ${SFAD12ExeAnalysisPath})
ENDIF()

enable_testing()

add_subdirectory(perf_tests)

