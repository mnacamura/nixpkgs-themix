final: prev:

{
  python3 = prev.python3.override ({
    packageOverrides = pyfinal: pyprev:
    {
      colorthief = pyfinal.callPackage ./pkgs/python/colorthief {};
      colorz = pyfinal.callPackage ./pkgs/python/colorz {};
      haishoku = pyfinal.callPackage ./pkgs/python/haishoku {};
    };
  });

  themix-gui = final.callPackage ./pkgs/themix/gui {
    unwrapped = final.callPackage ./pkgs/themix/gui/unwrapped.nix {};
    plugins = with final.themixPlugins; [
      import-images
      theme-oomox
      icons-papirus
    ];
  };

  themixPlugins = final.lib.recurseIntoAttrs {
    import-images = final.callPackage ./pkgs/themix/import-images {};
    theme-oomox = final.callPackage ./pkgs/themix/theme-oomox {};
    icons-papirus = final.callPackage ./pkgs/themix/icons-papirus {};
  };
}
