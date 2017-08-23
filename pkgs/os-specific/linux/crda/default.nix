{ stdenv, fetchurl, libgcrypt, libnl, pkgconfig, python2Packages, wireless-regdb }:

stdenv.mkDerivation rec {
  name = "crda-${version}";
  version = "3.18";

  src = fetchurl {
    sha256 = "1gydiqgb08d9gbx4l6gv98zg3pljc984m50hmn3ysxcbkxkvkz23";
    url = "http://kernel.org/pub/software/network/crda/crda-${version}.tar.xz";
  };

  buildInputs = [ libgcrypt libnl ];
  nativeBuildInputs = [
    pkgconfig python2Packages.m2crypto python2Packages.python
  ];

  patches = [
    (fetchurl {
      url = 
"https://raw.githubusercontent.com/openembedded/meta-openembedded/f25fd7a2ef99d493afe2e7dbad29cd2a813c93a1/meta-networking/recipes-connectivity/crda/crda/use-target-word-size-instead-of-host-s.patch";
      sha256 = "0pc3c15967i9wdsa9yfj4kfvj68nvaz1389vd7ssnqnzjjlbwgnm";
    })
    (fetchurl {
       url = 
"https://raw.githubusercontent.com/openembedded/meta-openembedded/f25fd7a2ef99d493afe2e7dbad29cd2a813c93a1/meta-networking/recipes-connectivity/crda/crda/fix-issues-when-USE_OPENSSL-1.patch";
       sha256 = "0cyw1clrh8g0ww9lbn2vfwiri1d1gqz0i4fpq7xyfian2v92bpc8";
    })
    (fetchurl {
      url = "https://raw.githubusercontent.com/openembedded/meta-openembedded/f25fd7a2ef99d493afe2e7dbad29cd2a813c93a1/meta-networking/recipes-connectivity/crda/crda/fix-gcc-6-unused-variables.patch";
      sha256 = "1243021rb31z8czds1ll6gz81xiqlz1ivpxf5aijssvgp3gcs4d6";
    })
  ];

  postPatch = ''
    patchShebangs utils/
    substituteInPlace Makefile --replace ldconfig true
    sed -i crda.c \
      -e "/\/usr\/.*\/regulatory.bin/d" \
      -e "s|/lib/crda|${wireless-regdb}/lib/crda|g"
  '';

  makeFlags = [
    "PREFIX=$(out)"
    "SBINDIR=$(out)/bin/"
    "UDEV_RULE_DIR=$(out)/lib/udev/rules.d/"
    "REG_BIN=${wireless-regdb}/lib/crda/regulatory.bin"
  ];

  buildFlags = [ "all_noverify" ];
  enableParallelBuilding = true;

  doCheck = true;
  checkTarget = "verify";

  meta = with stdenv.lib; {
    description = "Linux wireless Central Regulatory Domain Agent";
    longDescription = ''
      CRDA acts as the udev helper for communication between the kernel and
      userspace for regulatory compliance. It relies on nl80211 for communication.

      CRDA is intended to be run only through udev communication from the kernel.
      To use it under NixOS, add

        services.udev.packages = [ pkgs.crda ];

      to the system configuration.
    '';
    homepage = http://drvbp1.linux-foundation.org/~mcgrof/rel-html/crda/;
    license = licenses.free; # "copyleft-next 0.3.0", as yet without a web site
    platforms = platforms.linux;
    maintainers = with maintainers; [ nckx ];
  };
}
