# Maintainer: Felix Yan <felixonmars@archlinux.org>
# Contributor: Josip Ponjavic <josipponjavic at gmail dot com>
# Contributor: Xu Fasheng <fasheng.xu[AT]gmail.com>
# Contributor: Mucahit Senol <mucahitsenol86 at gmail dot com>

pkgname=deepin-screenshot
pkgver=5.0.0
pkgrel=1
pkgdesc="Easy-to-use screenshot tool for linuxdeepin desktop environment"
arch=('x86_64')
url="https://github.com/linuxdeepin/deepin-screenshot"
license=('GPL3')
depends=('deepin-qt5integration' 'dtkwm' 'deepin-turbo' 'xclip')
makedepends=('cmake' 'qt5-tools')
groups=('deepin-extra')
source=("$pkgname-$pkgver.tar.gz::https://github.com/linuxdeepin/deepin-screenshot/archive/$pkgver.tar.gz"
	"xclip.patch")
sha512sums=('6385eb067399ce60e629ad26e4bbcdf2bff58611c13d65fb699ed16de3e78cdcda73510cefff61b9d00d383c235492072444b13e3eb1aa5b4f7d578bd101cf1c'
'74eadb86232153f0b652c71411aaa258f800b97066d3d9c6d9b971c4f6d55d3bb0c129b08b0c4e1448ec4db89cd1970be5733323a671b4852591ca20a2baeea8')

build() {
  cd deepin-screenshot-$pkgver
  patch src/mainwindow.cpp < $srcdir/xclip.patch
  cmake . -DCMAKE_INSTALL_PREFIX=/usr
  make
}

package() {
  cd deepin-screenshot-$pkgver
  make DESTDIR="$pkgdir" install
} 
