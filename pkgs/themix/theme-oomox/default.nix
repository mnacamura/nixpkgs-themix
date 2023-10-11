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

    # This commit causes an error:
    #     Error loading plugin "theme_oomox"
    #     /nix/store/x2qlm51cf1r3zigv6r9zyz420jsnzn7n-themix-gui-1.15.1-oomox-root/opt/oomox/plugins/theme_oomox:
    #     type.__new__() takes exactly 3 arguments (0 given)
    #     
    #     Traceback (most recent call last):
    #       File "/nix/store/qi3xs1hg46aaq5xqpyrijg25n8w724a5-themix-gui-1.15.1-with-plugins/opt/oomox/oomox_gui/plugin_loader.py", line 89, in init_plugins
    #         cls.load_plugin(plugin_name, plugin_path)
    #       File "/nix/store/qi3xs1hg46aaq5xqpyrijg25n8w724a5-themix-gui-1.15.1-with-plugins/opt/oomox/oomox_gui/plugin_loader.py", line 58, in load_plugin
    #         plugin_module = get_plugin_module(
    #       File "/nix/store/qi3xs1hg46aaq5xqpyrijg25n8w724a5-themix-gui-1.15.1-with-plugins/opt/oomox/oomox_gui/helpers.py", line 25, in get_plugin_module
    #         spec.loader.exec_module(module)
    #       File "<frozen importlib._bootstrap_external>", line 883, in exec_module
    #       File "<frozen importlib._bootstrap>", line 241, in _call_with_frames_removed
    #       File "/nix/store/x2qlm51cf1r3zigv6r9zyz420jsnzn7n-themix-gui-1.15.1-oomox-root/opt/oomox/plugins/theme_oomox/oomox_plugin.py", line 24, in <module>
    #         class OomoxThemeExportDialog(CommonGtkThemeExportDialog):
    #       File "/nix/store/x2qlm51cf1r3zigv6r9zyz420jsnzn7n-themix-gui-1.15.1-oomox-root/opt/oomox/plugins/theme_oomox/oomox_plugin.py", line 25, in OomoxThemeExportDialog
    #         OPTIONS = OomoxThemeExportDialogOptions()
    #     TypeError: type.__new__() takes exactly 3 arguments (0 given)
    ./revert-cff6cda7.patch
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
