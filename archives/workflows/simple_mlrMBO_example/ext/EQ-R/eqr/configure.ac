
# EQ.R
# CONFIGURE.AC

# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.68])
AC_INIT([EQ.R], [0.1], [wozniak@mcs.anl.gov])
AC_CONFIG_SRCDIR([BlockingQueue.h])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CXX
AC_PROG_CPP
AC_PROG_MAKE_SET

# SWIG
AC_PATH_PROG([SWIG],[swig],[nope])
[[ ${SWIG} == "nope" ]] && AC_MSG_ERROR([Could not find SWIG!])

# Tcl
TCL_VERSION=0
AC_ARG_WITH(tcl-version,
              AS_HELP_STRING([--with-tcl-version],
                             [Tcl version: 8.5 or 8.6.  Default 8.6]),
              [TCL_VERSION=$withval],
              [TCL_VERSION=8.6])
AC_MSG_RESULT([Using Tcl version: $TCL_VERSION])
AC_PREFIX_DEFAULT($PWD/..)

USE_TCLSH=tclsh$TCL_VERSION
AC_PATH_PROG([TCL],[$USE_TCLSH],[nope])
[[ ${TCL} == "nope" ]] && AC_MSG_ERROR([Could not find $USE_TCLSH!])
AC_SUBST([USE_TCLSH])

# We only need C++
AC_LANG(C++)

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL

# Checks for library functions.

AC_CHECK_LIB([tcl$TCL_VERSION], [Tcl_Init])
AC_SUBST(TCL_VERSION)

# Checks for header files.

AC_CHECK_HEADER([tcl.h], [],
                [AC_MSG_ERROR([Could not find Tcl header!])])

AC_CHECK_HEADER([R.h], [],
                [AC_MSG_ERROR([Could not find R header!])])
AC_CHECK_HEADER([Rcpp.h], [],
                [AC_MSG_ERROR([Could not find Rcpp header!])])
AC_CHECK_HEADER([RInside.h], [],
                [AC_MSG_ERROR([Could not find RInside header!])])

USE_SED_I="sed -i"
AC_ARG_ENABLE(mac-bsd-sed,
              AS_HELP_STRING([--enable-mac-bsd-sed],
                             [Call sed -i ''.  Use this on a Mac!]),
              [USE_SED_I="sed -i ''"],[])
AC_SUBST(USE_SED_I)

AC_SUBST(CPPFLAGS)

AC_CONFIG_FILES([Makefile settings.mk])
AC_OUTPUT
