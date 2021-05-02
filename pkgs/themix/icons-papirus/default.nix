{ stdenv, themix-gui, python3, papirus-icon-theme
, runCommand
}:

let self =

stdenv.mkDerivation rec {
  pname = "themix-icons-papirus";
  inherit (themix-gui) version src;

  patches = [
    # themix-gui generates customized theme by `cp -r` theme skeleton to
    # working directory and modifying it. As the skeleton is in nix store and
    # not writable, the copied one is not modifiable.
    ./writable.patch

    # Enable change_color.sh to have option -t|--target-dir
    ./destpathroot.patch
  ];

  postPatch = ''
    patchShebangs plugins/icons_papirus

    # No need to remove .git*
    sed -i Makefile -e '/$(RM) -r .\+\.git\*/d'

    # Fix original Papirus icon path
    sed -i plugins/icons_papirus/change_color.sh \
        -e 's@$root/papirus-icon-theme@${papirus-icon-theme.src}@'
  '';

  nativeBuildInputs = [ python3 ];

  buildPhase = ''
    runHook preBuild
    python -O -m compileall plugins/icons_papirus
    runHook postBuild
  '';

  # No tests
  doCheck = false;

  installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  installTargets = "install_icons_papirus";

  passthru.generate = { preset, name }:
  runCommand "${self.name}-generated" { } ''
    export HOME=.
    ${self}/opt/oomox/plugins/icons_papirus/change_color.sh \
        --output "${name}" \
        --target-dir $out/share/icons \
        ${preset}
  '';


  meta = themix-gui.meta // {
    description = "Papirus icons plugin for Themix GUI designer";
  };
};

in self
