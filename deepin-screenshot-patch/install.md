1. Make a dir for patch `mkdir deepin-screenshot-patch`
2. cd `deepin-screenshot-patch`
3. Download PKGBUILD with `wget https://gist.githubusercontent.com/msenol86/c0c7daad3de32a7922486e5d669f24c6/raw/82abb9ad54f13c8e53d6272e0d0a999498ffa204/PKGBUILD`
4. Download xclip.patch with `wget https://gist.githubusercontent.com/msenol86/c0c7daad3de32a7922486e5d669f24c6/raw/82abb9ad54f13c8e53d6272e0d0a999498ffa204/xclip.patch`
5. If you never used makepkg, ensure you have required tools with `sudo pacman -Sy --needed base-devel`
6. Build package with `makepkg -si`
