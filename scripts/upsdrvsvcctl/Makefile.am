EXTRA_DIST = README

if HAVE_SYSTEMD
EXTRA_DIST += nut-driver-enumerator.sh upsdrvsvcctl
else
if WITH_SOLARIS_SMF
EXTRA_DIST += nut-driver-enumerator.sh upsdrvsvcctl
endif
endif

EXTRA_DIST += nut-driver-enumerator.sh.in upsdrvsvcctl.in

MAINTAINERCLEANFILES = Makefile.in .dirstamp

# Order in court! (If both are requested in parallel builds)
check: all
