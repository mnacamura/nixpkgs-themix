{ stdenv, themix-gui, python3, papirus-icon-theme }:

stdenv.mkDerivation rec {
  pname = "themix-icons-papirus";

  inherit (themix-gui) version src;

  patches = [ ./writable.patch ];

  postPatch = ''
    patchShebangs plugins/icons_papirus

    # No need to remove .git*
    sed -i Makefile -e '/$(RM) -r .\+\.git\*/d'

    cp -rT "${papirus-icon-theme.src}" plugins/icons_papirus/papirus-icon-theme
  '';

  nativeBuildInputs = [ python3 ];

  buildPhase = ''
    runHook preBuild
    python -O -m compileall plugins/icons_papirus
    runHook postBuild
  '';

  doCheck = false; 

  installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  installTargets = "install_icons_papirus";

  meta = themix-gui.meta // {
    description = "Papirus icons plugin for Themix GUI designer";
  };
}
