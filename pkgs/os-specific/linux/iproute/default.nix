{ fetchurl, stdenv, lib, flex, bison, db, iptables, pkgconfig
, enableFan ? false
}:

stdenv.mkDerivation rec {
  name = "iproute2-4.6.0";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/net/iproute2/${name}.tar.xz";
    sha256 = "01nl55l4dbpi6gr1j5hhkspl4nrqmyxmi0cz2md0kgl5s256mz3l";
  };

  patches = lib.optionals enableFan [
    # These patches were pulled from:
    # https://launchpad.net/ubuntu/xenial/+source/iproute2
    ./1000-ubuntu-poc-fan-driver.patch
    ./1001-ubuntu-poc-fan-driver-v3.patch
    ./1002-ubuntu-poc-fan-driver-vxlan.patch
  ];

  preConfigure = ''
    patchShebangs ./configure
    sed -e '/ARPDDIR/d' -i Makefile
  '';

  makeFlags = [
    "DESTDIR="
    "LIBDIR=$(out)/lib"
    "SBINDIR=$(out)/sbin"
    "MANDIR=$(out)/share/man"
    "DOCDIR=$(TMPDIR)/share/doc/${name}" # Don't install docs
  ];

  buildFlags = [
    "CONFDIR=/etc/iproute2"
  ];

  installFlags = [
    "CONFDIR=$(out)/etc/iproute2"
  ];

  buildInputs = [ db iptables ];
  nativeBuildInputs = [ bison flex pkgconfig ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = http://www.linuxfoundation.org/collaborate/workgroups/networking/iproute2;
    description = "A collection of utilities for controlling TCP/IP networking and traffic control in Linux";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ eelco wkennington ];
  };
}
