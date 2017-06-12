
.. Build this document with: rst2pdf Readme.rst

.. sectnum::

========================================
 EQ.R: Workflow Algorithms via Queues: R
========================================

**EQ.R** allows us to rapidly prototype high-level algorithms in R by
providing queues that connect R to a Swift/T workflow.

The initial ABC/Swift/Tcl integration is now an EQ.R project, in
``EQ.R-tests/ABC``.

Overview
========

This is a Swift/T compatible version of the C++/R framework Jonathan Ozik
and Nick Collier put together.

The point of this is to make Tcl bindings for the C++ functions so
that Tcl can communicate with R, and thus allows Swift/T to
communicate with R.

Start by looking at ``EQ.R-tests/ABC/test-cpp.cpp`` - this version of
the C++ driver has been broken down into component features (R/thread
control, queue operations, and a computational task).  The thread and
queue features are placed in library ``EQR.cpp``.  The task is
specific to the project.

Then, we made those tasks callable from Tcl just as they would be
called from C++.  We did that by making a SWIG/Tcl package for
``EQR.cpp``, which involves adding the SWIG interface file.

Then, the Makefile is able to build the whole thing.

The symbol names have been updated to match the MRTC paper, Figure 2.

File index
==========

``BlockingQueue.h``
  A queue for inter-thread communication.

``EQR.h EQR.cpp``
  The main functionality to enable EQ.R- thread and queue control
  interfaces for access from Tcl and Swift.

``EQR.i``
  The SWIG interface file for EQ.R.

``settings.mk.in``
  Filters into ``settings.mk`` at configure time.  This can be
  ``include`` <!--- --> by other Makefiles to obtain build settings, for
  example, to compile task code that will be called from Swift.


Build
=====

Outline
-------

#. ``./bootstrap``

#. ``source settings.sh``

#. ``./configure ...``

#. ``make install``

Details
-------

Run ``./bootstrap``.  This runs ``autoconf`` and generates ``./configure``.

Then, you need to set ``CPPFLAGS``, ``CXXFLAGS``, and ``LDFLAGS``.
The recommended way to do this is to make a personal copy of
``settings.template.sh``, edit it to contain your settings, and source
it.

Then, run ``./configure``.  You can use ``./configure --help``.  Key
settings are:

* ``--prefix``: EQ.R install location
* ``--enable-mac-bsd-sed``: For Mac users
* ``--with-tcl-version=8.5``: If you are using Tcl 8.5

Then do ``make install``.

You can do ``make clean`` or ``make distclean``.
