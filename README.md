## 手动安装

1. 下载template到home目录下 

``nix-shell -p git``

``git clone https://github.com/world1tree/nixos-dotfiles.git .dotfiles``

``cd .dotfiles``

2. 使用disko进行分区并挂载(可能需要修改disk-config文件)
``sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes github:nix-community/disko -- --mode zap_create_mount ./modules/nixos/disk-config.nix``

3. 生成配置文件
``sudo nixos-generate-config --root /mnt``

``sudo rm /mnt/etc/nixos/configruation.nix``

``sudo cp /mnt/etc/nixos/hardware-configuration.nix .``

4. 安装系统
``sudo nixos-install --flake .#x86_64-linux``

## 镜像

# 使用上海交通大学的镜像源
# 官方文档: https://mirror.sjtu.edu.cn/docs/nix-channels/store
nixos-rebuild switch --option substituters "https://mirror.sjtu.edu.cn/nix-channels/store"

# 使用中国科学技术大学的镜像源
# 官方文档: https://mirrors.ustc.edu.cn/help/nix-channels.html
nixos-rebuild switch --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store"

# 使用清华大学的镜像源
# 官方文档: https://mirrors.tuna.tsinghua.edu.cn/help/nix-channels/
nixos-rebuild switch --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
