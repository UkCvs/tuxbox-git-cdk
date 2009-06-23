AC_DEFUN([TUXBOX_RULES_MAKE],[
AC_MSG_CHECKING([$1 rules])
eval `${srcdir}/rules.pl make ${srcdir}/rules-make $1 cdkoutput`
INSTALL_$1=`${srcdir}/rules.pl install ${srcdir}/rules-install${INSTALLRULESETFILE} $1`
CLEANUP_$1="rm -rf $DIR_$1"
CLEANUP="$CLEANUP $DIR_$1"
DEPSCLEANUP="$DEPSCLEANUP .deps/$1"
AC_SUBST(DEPENDS_$1)dnl
AC_SUBST(DIR_$1)dnl
AC_SUBST(PREPARE_$1)dnl
AC_SUBST(VERSION_$1)dnl
AC_SUBST(INSTALL_$1)dnl
AC_SUBST(CLEANUP_$1)dnl
AC_MSG_RESULT(done)
])

AC_DEFUN([TUXBOX_RULES_MAKE_EXDIR],[
AC_MSG_CHECKING([$1 rules])
eval `${srcdir}/rules.pl make ${srcdir}/rules-make $1 cdkoutput`
SOURCEDIR_$1=$DIR_$1
CONFIGURE_$1="../$DIR_$1/configure"
PREPARE_$1="$PREPARE_$1 && ( rm -rf build_$1 || /bin/true ) && mkdir build_$1"
INSTALL_$1=`${srcdir}/rules.pl install ${srcdir}/rules-install${INSTALLRULESETFILE} $1`
CLEANUP_$1="rm -rf $DIR_$1 build_$1"
CLEANUP="$CLEANUP $DIR_$1"
DIR_$1="build_$1"
AC_SUBST(CLEANUP_$1)dnl
AC_SUBST(CONFIGURE_$1)dnl
AC_SUBST(DEPENDS_$1)dnl
AC_SUBST(DIR_$1)dnl
AC_SUBST(INSTALL_$1)dnl
AC_SUBST(PREPARE_$1)dnl
AC_SUBST(SOURCEDIR_$1)dnl
AC_SUBST(VERSION_$1)dnl
AC_MSG_RESULT(done)
])

AC_DEFUN([TUXBOX_NEWMAKE_WARNING],[
AC_MSG_RESULT([
******************************************************************
*                       !!!WARNING!!!                            *
*     You are using a CVS checkout from the newmake branch.      *
*   Please note that this branch is not updated anymore since    *
*  it was moved to CVS HEAD, where current commits take place.   *
*              In order to use current code remove               *
*         "-r newmake" from your CVS checkout command.           *
*                       !!!WARNING!!!                            *
******************************************************************
])
])
