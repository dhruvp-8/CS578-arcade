dnl modules enabled in this directory by default

dnl APACHE_MODULE(name, helptext[, objects[, structname[, default[, config]]]])

APACHE_MODPATH_INIT(core)

APR_CHECK_APR_DEFINE(APR_HAS_DSO)

case "x$enable_so" in
    "xyes")
        if test $ac_cv_define_APR_HAS_DSO = "no"; then
            AC_MSG_ERROR([mod_so has been requested but cannot be built on your system])
        fi
        ;;
    "xshared")
        AC_MSG_ERROR([mod_so can not be built as a shared DSO])
        ;;
    "xno")
        ;;
    "x")
        enable_so=$ac_cv_define_APR_HAS_DSO
        ;;
esac

dnl mod_so can only be built statically. Override the default here.
if test "x$enable_so" = "xyes"; then
    enable_so="static"
fi

if test "x$enable_so" = "xstatic"; then
    APR_ADDTO(HTTPD_LDFLAGS, [-export-dynamic])
    INSTALL_DSO=yes
else
    INSTALL_DSO=no
fi
APACHE_SUBST(INSTALL_DSO)

if test "$sharedobjs" = "yes"; then
    if test $ac_cv_define_APR_HAS_DSO = "no"; then
        AC_MSG_ERROR([shared objects have been requested but cannot be built since mod_so cannot be built])
    elif test $enable_so = "no"; then
        AC_MSG_ERROR([shared objects have been requested but cannot be built since mod_so was disabled])
    fi
fi

APACHE_MODULE(so, DSO capability, , , $enable_so)

APR_CHECK_APR_DEFINE(APR_HAS_THREADS)

if test -z "$enable_watchdog"; then
    if test $ac_cv_define_APR_HAS_THREADS = "no"; then
        enable_watchdog="no"
    else
        enable_watchdog="most"
    fi
fi

APACHE_MODULE(watchdog, Watchdog module, , , $enable_watchdog, [
    if test $ac_cv_define_APR_HAS_THREADS = "no"; then
        AC_MSG_ERROR([mod_watchdog requires apr to be built with --enable-threads])
    fi
])

APR_ADDTO(INCLUDES, [-I\$(top_srcdir)/$modpath_current])

APACHE_MODPATH_FINISH
