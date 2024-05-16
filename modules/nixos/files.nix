{ user, ... }:

let
  home           = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";
  xdg_scriptDir = "/home/${user}/.config/scripts";
in {

  "${xdg_configHome}/bspwm/bspwmrc" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      sxhkd -m -1 &
      # wmname LG3D

      bspc monitor -d I II III IV V VI VII VIII IX X

      bspc config border_width         2
      bspc config window_gap          12

      bspc config split_ratio          0.52
      bspc config borderless_monocle   true
      bspc config gapless_monocle      true
      bspc config focus_follows_pointer true

      [ -e "$PANEL_FIFO" ] && bspc subscribe report > "$PANEL_FIFO" &
      pgrep -x panel > /dev/null || panel &

      bspc rule -a Zathura state=tiled
    '';
  };

  "${xdg_configHome}/sxhkd/sxhkdrc" = {
    text = ''
      super + Return
          bspc rule -a Alacritty -o state=floating rectangle=1024x768x0x0 center=true && alacritty

      super + g
          dmenu_run

      super + shift + r
          pkill -USR1 -x sxhkd

      super + shift + q
          pkill -x panel;bspc quit

      super + q
          bspc node -{c,k}

      super + o
          st -e htop

      super + equal
          ${xdg_scriptDir}/change-volume up

      super + minus
          ${xdg_scriptDir}/change-volume down

      super + shift + equal
          ${xdg_scriptDir}/change-brightness up

      super + shift + minus
          ${xdg_scriptDir}/change-brightness down

      @Print
          ${xdg_scriptDir}/screenshot fullscreen

      super + @Print
          ${xdg_scriptDir}/screenshot select

      super + r
          bspc node --state \~fullscreen
      super + u
              bspc node --state \~floating
      super + t
              bspc node --state \~tiled

      super + {_,shift + }{h,j,k,l}
          bspc node -{f,s} {west,south,north,east}

      super + {p,b,comma,period}
          bspc node -f @{parent,brother,first,second}

      super + {_,shift + }c
          bspc node -f {next,prev}.local

      super + bracket{left,right}
          bspc desktop -f {prev,next}.local

      super + {1-9,0}
          ${xdg_scriptDir}/toggle-desktop '{1-9,10}'

      super + shift + {1-9,0}
          bspc node -d '^{1-9,10}'

      super + ctrl + {h,j,k,l}
          bspc node -p {west,south,north,east}

      super + ctrl + {1-9}
          bspc node -o 0.{1-9}

      super + ctrl + space
          bspc node -p cancel

      super + ctrl + shift + space
          bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel

      super + alt + {h,j,k,l}
          bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

      super + alt + shift + {h,j,k,l}
          bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}

      super + {Left,Down,Up,Right}
          bspc node -v {-20 0,0 20,0 -20,20 0}

      # Program launcher
      # super + @space
            # rofi -config -no-lazy-grab -show drun -modi drun -theme /home/${user}/.config/rofi/launcher.rasi

    '';
  };

  "${xdg_scriptDir}/change-brightness" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      function send_notification() {
          brightness=$(printf "%.0f\n" $(brillo -G))
          dunstify -a "changebrightness" -u low -r 9991 -h int:value:"$brightness" "Brightness: $brightness%" -t 2000
      }

      case $1 in
      up)
          brillo -A 5 -q
          send_notification
          ;;
      down)
          brillo -U 5 -q
          send_notification
          ;;
      esac
    '';
  };

  "${xdg_scriptDir}/check-battery" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # battery_capacity=$(acpi | awk '{print $4}' | grep -Eo "[0-9]+")
      battery_capacity=$(acpi | grep -Eo "[0-9]+%" | tr -d '%')

      if [[ $battery_capacity -lt 40 ]]; then
         dunstify -a "check battery" -u critical "Warning: battery $battery_capacity%" -t 10000
      fi
    '';
  };

  "${xdg_scriptDir}/change-volume" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      function send_notification() {
              volume=$(amixer get Master | grep '%' | awk -F'[' '{print $2}' | awk -F'%' '{print $1}')
              dunstify -a "changevolume" -u low -r "9993" -h int:value:"$volume" "Volume: $volume%" -t 2000
      }

      case $1 in
      up)
          amixer set Master 3%+
              send_notification
              ;;
      down)
          amixer set Master 3%-
              send_notification
              ;;
      esac

    '';
  };

  "${xdg_scriptDir}/screenshot" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # case "$1" in
        # "fullscreen") grim - | xclip -selection c -t image/png -i ;;
        # "select") grim -g "$(slurp -d)" - | xclip -selection c -t image/png -i ;;
      # esac

      case "$1" in
        "fullscreen") scrot - | xclip -selection c -t image/png -i ;;
        "select") scrot -s -l mode=edge - | xclip -selection c -t image/png -i ;;
      esac

      dunstify -a "screenshot" -u low "Screenshot Done." -t 2000
    '';
  };

  "${xdg_scriptDir}/toggle-desktop" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      function toggle_desktop_hypr (){
        desktop_name=$(hyprctl activeworkspace | grep -oP "ID \K\d+")

        if [[ $1 == $desktop_name ]]; then
            # dunstify "same workspace" -t 2000
            hyprctl dispatch workspace previous > /dev/null
        else
            # dunstify "different workspace" -t 2000
            hyprctl dispatch workspace $1 > /dev/null
        fi
      }

      function toggle_desktop (){
        arr=(blank I II III IV V VI VII VIII IX X)
        desktop_name=$(bspc query -T -d focused | jq -r .name)

        if [[ $arr[$1] == $desktop_name ]]; then
            # dunstify "same workspace" -t 2000
            bspc desktop -f last
        else
            # dunstify "different workspace" -t 2000
            bspc desktop -f ^$1
        fi
      }

      toggle_desktop $1

    '';
  };

}
