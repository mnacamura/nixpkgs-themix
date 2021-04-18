{ lib, stdenv, themix-gui, python3
, enableColorthief ? false
, enableColorz ? false
, enableHaishoku ? false
}:

let
  inherit (lib) optionals;
in

stdenv.mkDerivation rec {
  pname = "themix-import-images";

  inherit (themix-gui) version src;

  propagatedBuildInputs = with python3.pkgs;
  [ pillow ] ++
  optionals enableColorthief [ colorthief ] ++
  optionals enableColorz [ colorz ] ++
  optionals enableHaishoku [ haishoku ];

  buildPhase = ''
    runHook preBuild
    python -O -m compileall plugins/import_pil
    runHook postBuild
  '';

  installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  installTargets = "install_import_images";

  meta = themix-gui.meta // {
    description = "Plugin for Themix GUI designer to get color palettes from images";
  };
}
