cmake_minimum_required(
    VERSION
      3.8 # CUDA language support
  )
  
  project(CUDA-Conway
    LANGUAGES
      CXX
      CUDA
  )

  add_executable(kernel kernel.cu)