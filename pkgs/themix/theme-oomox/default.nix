{ lib, stdenv, fetchFromGitHub, python3, bc, sassc, glib, libxml2, gdk-pixbuf
, gtk-engine-murrine
}:

stdenv.mkDerivation rec {
  pname = "themix-theme-oomox";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "themix-project";
    repo = "oomox-gtk-theme";
    rev = version;
    sha256 = "015yj9hl283dsgphkva441r1fr580wiyssm4s2x4xfjprqksxg8w";
  };

  patches = [ ./writable.patch ];

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
