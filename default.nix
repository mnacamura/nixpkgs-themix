self: super:

{
  python3 = super.python3.override ({
    packageOverrides = pyself: pysuper:
    {
      colorthief = pyself.callPackage ./pkgs/python/colorthief {};

      colorz = pyself.callPackage ./pkgs/python/colorz {};

      haishoku = pyself.callPackage ./pkgs/python/haishoku {};
    };
  });

  themix-gui = self.callPackage ./pkgs/themix/gui {
    unwrapped = self.callPackage ./pkgs/themix/gui/unwrapped.nix {};
    plugins = with self.themixPlugins; [
      (import-images.override {
        enableColorthief = true;
        enableColorz = true;
        enableHaishoku = true;
      })
      theme-oomox
      icons-papirus
    ];
  };

  themixPlugins = {
    import-images = self.callPackage ./pkgs/themix/import-images {};

    theme-oomox = self.callPackage ./pkgs/themix/theme-oomox {};

    icons-papirus = self.callPackage ./pkgs/themix/icons-papirus {};
  };
}
