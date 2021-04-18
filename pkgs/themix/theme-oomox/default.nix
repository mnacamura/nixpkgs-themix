{ lib, stdenv, fetchFromGitHub, python3, bc, sassc, glib, libxml2, gdk-pixbuf
, gtk-engine-murrine
, fetchpatch
}:

stdenv.mkDerivation rec {
  pname = "themix-theme-oomox";
  version = "1.12.r2";

  src = fetchFromGitHub {
    owner = "themix-project";
    repo = "oomox-gtk-theme";
    rev = "e0d729510791b4797e80610b73b5beea07673b10";
    sha256 = "1i0pj3hwpxcrwrx1y1yf9xxp38zcaljh7f8na3z3k77f1pldch27";
  };

  patches = [
    (let
       rev = "b695fcb8d303f804c53d85ad7d6396b0cd2b29b4";
       sha256 = "0696bvj8pddf34pnljkxbnl2za6ah80a5rmjj89qjs122xg50n0d";
     in
     fetchpatch {
       url = "https://github.com/themix-project/oomox-gtk-theme/commit/${rev}.patch";
       inherit sha256;
     })
    ./writable.patch
  ];

  postPatch = ''
    patchShebangs .
    for path in packaging/bin/*; do
        sed -i "$path" -e "s@\(/opt/oomox/\)@$out\1@"
    done
  '';

  nativeBuildInputs = [ python3 ];

  propagatedBuildInputs = [ bc sassc glib libxml2 gdk-pixbuf ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  buildPhase = ''
    runHook preBuild
    python -O -m compileall .
    runHook postBuild
  '';

  doCheck = false; 

  installFlags = [ "-f Makefile_oomox_plugin" "DESTDIR=$(out)" "PREFIX=" ];

  postInstall = ''
    cp -r __pycache__ "$out/opt/oomox/plugins/theme_oomox"/
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "Oomox theme plugin for Themix GUI designer";
    platforms = platforms.all;
    maintainers = with maintainers; [ mnacamura ];
    license = licenses.gpl3;
  };
}
