{ config, pkgs, lib, ... }:

let
  name = "zaiheshi";
  user = "zaiheshi";
  email = "zaiheshi@gmail.com";
in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    stateVersion = "23.11";
  };

  programs = {
    gpg.enable = true; 

    git = {
      enable = true;
      ignores = [ "*.swp" ];
      userName = name;
      userEmail = email;
      lfs = {
        enable = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "vim";
          autocrlf = "input";
        };
        commit.gpgsign = true;
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };

    vim = {
      enable = true;
      extraConfig = ''
        let mapleader=" "
        colorscheme desert
        set encoding=utf-8
        set mouse=a

        set nocompatible
        set nobackup
        set noswapfile
        set ignorecase
        set textwidth=80

        filetype plugin on
        syntax on

        " 解决insert模式下面退格键不能用的问题
        set backspace=indent,eol,start

        set nu
        " set relativenumber
        set ts=4
        set shiftwidth=4
        set expandtab

        nnoremap <leader>w :w<CR>
        nnoremap <leader>q :q<CR>
        nnoremap j gj
        '';
       };

   alacritty = {
      enable = true;
      settings = {
        cursor = {
          style = "Block";
        };

        window = {
          opacity = 1.0;
          padding = {
            x = 24;
            y = 24;
          };
        };

        # font = {
          # normal = {
            # family = "MesloLGS NF";
            # style = "Regular";
          # };
          # size = lib.mkMerge [
            # (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 10)
            # (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 14)
          # ];
        # };

        dynamic_padding = true;
        decorations = "full";
        title = "Terminal";
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };

        colors = {
          primary = {
            background = "0x1f2528";
            foreground = "0xc0c5ce";
          };

          normal = {
            black = "0x1f2528";
            red = "0xec5f67";
            green = "0x99c794";
            yellow = "0xfac863";
            blue = "0x6699cc";
            magenta = "0xc594c5";
            cyan = "0x5fb3b3";
            white = "0xc0c5ce";
          };

          bright = {
            black = "0x65737e";
            red = "0xec5f67";
            green = "0x99c794";
            yellow = "0xfac863";
            blue = "0x6699cc";
            magenta = "0xc594c5";
            cyan = "0x5fb3b3";
            white = "0xd8dee9";
          };
        };
      };
    };
  };

}
