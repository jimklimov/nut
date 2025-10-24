dnl Check for LIBPOWERMAN compiler flags. On success, set nut_have_libpowerman="yes"
dnl and set LIBPOWERMAN_CFLAGS and LIBPOWERMAN_LIBS. On failure, set
dnl nut_have_libpowerman="no". This macro can be run multiple times, but will
dnl do the checking only once.

AC_DEFUN([NUT_CHECK_LIBPOWERMAN],
[
if test -z "${nut_have_libpowerman_seen}"; then
	nut_have_libpowerman_seen=yes
	AC_REQUIRE([NUT_CHECK_PKGCONFIG])

	dnl save CFLAGS and LIBS
	CFLAGS_ORIG="${CFLAGS}"
	LIBS_ORIG="${LIBS}"
	CFLAGS=""
	LIBS=""
	depCFLAGS=""
	depCFLAGS_SOURCE=""
	depLIBS=""
	depLIBS_SOURCE=""

	AS_IF([test x"$have_PKG_CONFIG" = xyes],
		[AC_MSG_CHECKING([for LLNC libpowerman version via pkg-config])
		 POWERMAN_VERSION="`$PKG_CONFIG --silence-errors --modversion libpowerman 2>/dev/null`"
		 dnl Unlike other pkg-config enabled projects we use,
		 dnl libpowerman (at least on Debian) delivers an empty
		 dnl "Version:" tag in /usr/lib/pkgconfig/libpowerman.pc
		 dnl (and it is the only file in that dir, others going
		 dnl to /usr/lib/x86_64-linux-gnu/pkgconfig/ or similar
		 dnl for other architectures). Empty is not an error here!
		 if test "$?" != "0" ; then # -o -z "${POWERMAN_VERSION}"; then
		    POWERMAN_VERSION="none"
		 fi
		 AC_MSG_RESULT(['${POWERMAN_VERSION}' found])
		],
		[POWERMAN_VERSION="none"
		 AC_MSG_NOTICE([can not check LLNC libpowerman settings via pkg-config])
		]
	)

	AS_IF([test x"$POWERMAN_VERSION" != xnone],
		[depCFLAGS="`$PKG_CONFIG --silence-errors --cflags libpowerman 2>/dev/null`"
		 depLIBS="`$PKG_CONFIG --silence-errors --libs libpowerman 2>/dev/null`"
		 depCFLAGS_SOURCE="pkg-config"
		 depLIBS_SOURCE="pkg-config"
		],
		[depCFLAGS=""
		 depLIBS=""
		 depCFLAGS_SOURCE="default"
		 depLIBS_SOURCE="default"
		]
	)

	AC_MSG_CHECKING([for libpowerman cflags])
	NUT_ARG_WITH_LIBOPTS_INCLUDES([powerman], [auto], [libpowerman])
	AS_CASE([${nut_with_powerman_includes}],
		[auto], [],	dnl Keep what we had found above
			[depCFLAGS="${nut_with_powerman_includes}"
			 depCFLAGS_SOURCE="confarg"]
	)
	AC_MSG_RESULT([${depCFLAGS} (source: ${depCFLAGS_SOURCE})])

	AC_MSG_CHECKING(for libpowerman libs)
	NUT_ARG_WITH_LIBOPTS_LIBS([powerman], [auto], [libpowerman])
	AS_CASE([${nut_with_powerman_libs}],
		[auto], [],	dnl Keep what we had found above
			[depLIBS="${nut_with_powerman_libs}"
			 depLIBS_SOURCE="confarg"]
	)
	AC_MSG_RESULT([${depLIBS} (source: ${depLIBS_SOURCE})])

	dnl check if libpowerman is usable
	CFLAGS="${CFLAGS_ORIG} ${depCFLAGS}"
	LIBS="${LIBS_ORIG} ${depLIBS}"
	AC_CHECK_HEADERS(libpowerman.h, [nut_have_libpowerman=yes], [nut_have_libpowerman=no], [AC_INCLUDES_DEFAULT])
	AC_CHECK_FUNCS(pm_connect, [], [
		dnl Some systems may just have libpowerman in their
		dnl standard paths, but not the pkg-config data
		AS_IF([test "${nut_have_libpowerman}" = "yes" && test "$POWERMAN_VERSION" = "none" && test -z "$LIBS"],
			[AC_MSG_CHECKING([if libpowerman is just present in path])
			 depLIBS="-L/usr/lib -L/usr/local/lib -lpowerman"
			 unset ac_cv_func_pm_connect || true
			 LIBS="${LIBS_ORIG} ${depLIBS}"
			 AC_CHECK_FUNCS(pm_connect, [], [nut_have_libpowerman=no])
			 AC_MSG_RESULT([${nut_have_libpowerman}])
			], [nut_have_libpowerman=no]
		)]
	)

	if test "${nut_have_libpowerman}" = "yes"; then
		LIBPOWERMAN_CFLAGS="${depCFLAGS}"
		LIBPOWERMAN_LIBS="${depLIBS}"
	fi

	unset depCFLAGS
	unset depLIBS
	unset depCFLAGS_SOURCE
	unset depLIBS_SOURCE

	dnl restore original CFLAGS and LIBS
	CFLAGS="${CFLAGS_ORIG}"
	LIBS="${LIBS_ORIG}"
fi
])
