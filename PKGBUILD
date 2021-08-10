# Maintainer: Phoney Badger <badgerphoney@gmail.com>
pkgname=pokemon-colorscripts
pkgver=1
pkgrel=1
pkgdesc="CLI utility that prints unicode sprites of pokemon to the terminal"
arch=('x86_64')
url="https://gitlab.com/phoneybadger/pokemon-colorscripts.git"
license=('MIT')
depends=()
makedepends=('git')
source=("$pkgname::git+$url")
md5sums=('SKIP')

pkgver(){
    cd "$pkgname"
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
	cd "$pkgname"
    # Creating necessary directories and copying files
    rm -rf "$pkgdir/usr/local/opt/$pkgname"
    mkdir -p "$pkgdir/usr/local/opt/$pkgname/colorscripts"
    mkdir -p "$pkgdir/usr/local/bin"
    install -Dm644 colorscripts/* -t "$pkgdir/usr/local/opt/$pkgname/colorscripts"
    install -Dm644 nameslist.txt "$pkgdir/usr/local/opt/$pkgname/nameslist.txt"
    install -Dm755 pokemon-colorscripts.sh "$pkgdir/usr/local/opt/$pkgname/pokemon-colorscripts.sh"
    install -Dm644 LICENSE.txt "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
    # creating symlink in usr/local/bin
    ln -sf "/usr/local/opt/$pkgname/pokemon-colorscripts.sh" "$pkgdir/usr/local/bin/pokemon-colorscripts"
}
