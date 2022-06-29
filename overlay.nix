{
  self,
  fnctl,
  do-nixpkgs,
  ...
} @ inputs: final: prev: with prev; {
  fnctl = fnctl.packages.${system};
  do-nixpkgs = do-nixpkgs.packages.${system};
  neovim = (neovim.override {
      vimAlias = true;
      viAlias = true;
      configure = {
        packages.myPlugins = with vimPlugins; {
          start = [ vim-lastplace vim-nix ]; 
          opt = [];
        };
        customRC = ''
          " your custom vimrc
          set nocompatible
          set backspace=indent,eol,start
          " ...
        '';
      };
    }
  );
}
