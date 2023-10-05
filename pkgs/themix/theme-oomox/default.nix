{ lib, stdenv, fetchFromGitHub, python3, bc, sassc, glib, librsvg, gdk-pixbuf
, gtk-engine-murrine
, makeFontsConf, freefont_ttf
, fetchpatch
, runCommand
}:

let self =

stdenv.mkDerivation rec {
  pname = "themix-theme-oomox";
  version = "1.12.4";

  src = fetchFromGitHub {
    owner = "themix-project";
    repo = "oomox-gtk-theme";
    rev = version;
    hash = "sha256-X7ZtoaxuBeXbUWTsVVeyeAlgmmr12pic6T9A4yM+b60=";
  };

  patches = [
    # themix-gui generates customized theme by `cp -r` theme skeleton to
    # working directory and modifying it. As the skeleton is in nix store and
    # not writable, the copied one is not modifiable.
    ./writable.patch
  ];

  postPatch = ''
    patchShebangs .

    for bin in packaging/bin/*; do
        sed -i "$bin" -e "s@\(/opt/oomox/\)@$out\1@"
    done
  '';

  nativeBuildInputs = [ python3 ];

  propagatedBuildInputs = [ bc sassc glib librsvg gdk-pixbuf ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  buildPhase = ''
    runHook preBuild
    python -O -m compileall .
    runHook postBuild
  '';

  # No tests
  doCheck = false;

  makefile = "Makefile_oomox_plugin";

  installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  postInstall = ''
    cp -r __pycache__ $out/opt/oomox/plugins/theme_oomox/
  '';

  passthru.generate = { preset, name, hidpi ? false, makeOpts ? "gtk320" }:
  runCommand "${self.name}-generated" {
    buildInputs = [ librsvg bc sassc ];
    # Fontconfig error: Cannot load default config file
    FONTCONFIG_FILE = makeFontsConf {
      fontDirectories = [ freefont_ttf ];
    };
  } ''
    export HOME=.
    ${self}/opt/oomox/plugins/theme_oomox/change_color.sh \
        --output "${name}" \
        --target-dir $out/share/themes \
        ${if hidpi then "--hidpi true" else ""} \
        --make-opts ${makeOpts} \
        ${preset}
  '';

  meta = with lib; {
    description = "Oomox theme plugin for Themix GUI designer";
    homepage = "https://github.com/themix-project/oomox";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ mnacamura ];
    platforms = platforms.linux;
  };
};

in self
