# dwm - dynamic window manager
# See LICENSE file for copyright and license details.

include config.mk

SRC = drw.c dwm.c util.c
OBJ = ${SRC:.c=.o}

# Add distribution-specific configurations
ifeq ($(DISTRO),debian)
    CPPFLAGS += -DDISTRO_DEBIAN
else ifeq ($(DISTRO),ubuntu)
    CPPFLAGS += -DDISTRO_DEBIAN
else ifeq ($(DISTRO),fedora)
    CPPFLAGS += -DDISTRO_FEDORA
else ifeq ($(DISTRO),rhel)
    CPPFLAGS += -DDISTRO_FEDORA
else ifeq ($(DISTRO),centos)
    CPPFLAGS += -DDISTRO_FEDORA
else ifeq ($(DISTRO),arch)
    CPPFLAGS += -DDISTRO_ARCH
else
    CPPFLAGS += -DDISTRO_UNKNOWN
endif

all: dwm

.c.o:
	${CC} -c ${CFLAGS} $<

${OBJ}: config.h config.mk

config.h:
	cp config.def.h $@

dwm: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}
	@echo "Compiled for distribution: $(DISTRO)"

clean:
	rm -f dwm ${OBJ} *.orig *.rej
	rm -f /usr/local/bin/terminal

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	install -Dm755 dwm ${DESTDIR}${PREFIX}/bin/dwm
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
	sed "s/VERSION/${VERSION}/g" < dwm.1 > ${DESTDIR}${MANPREFIX}/man1/dwm.1
	chmod 644 ${DESTDIR}${MANPREFIX}/man1/dwm.1
	mkdir -p /usr/share/xsessions/
	test -f /usr/share/xsessions/dwm.desktop || install -Dm644 dwm.desktop /usr/share/xsessions/
	mkdir -p release
	cp -f dwm release/
	tar -czf release/dwm-${VERSION}.tar.gz -C release dwm

	# Install the terminal script
	install -Dm755 ./scripts/terminal /usr/local/bin/terminal

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dwm\
		${DESTDIR}${MANPREFIX}/man1/dwm.1\
		${DESTDIR}${PREFIX}/share/xsession/dwm.desktop\
		/usr/local/bin/terminal  

release: dwm
	mkdir -p release
	cp -f dwm release/
	tar -czf release/dwm-${VERSION}.tar.gz -C release dwm

.PHONY: all clean install uninstall release