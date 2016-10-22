#ifdef __LINUX__
  #include "OS_impl_linux.ml"
#elif defined __OSX__
  #include "OS_impl_osx.ml"
#elif defined __WIN__
  #include "OS_impl_windows.ml"
#endif
