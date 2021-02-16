thissrc="${BASH_SOURCE[0]}"
while [ -h "$thissrc" ]; do # resolve $thissrc until the file is no longer a symlink
    thisdir="$( cd -P "$( dirname "$thissrc" )" >/dev/null && pwd )"
    thissrc="$(readlink "$thissrc")"

    # if $thissrc was a relative symlink, we need to resolve it relative
    # to the path where the symlink file was located
    [[ $thissrc != /* ]] && thissrc="$thisdir/$thissrc"
done
thisdir="$( cd -P "$( dirname "$thissrc" )" >/dev/null && pwd )"

pkgver=6.0
use_mkpkgp=$(which makepkg)
declare thisbinfile
function build ()
{
    if [[ ! -z $use_mkpkgp ]]
    then
        makepkg -f .
        [[ ! "$?" -eq 0 ]] && exit
        thisbinfile="${thisdir}/src/unzip${pkgver/./}/unzip"
    else
        bash "$thisdir"/nature-make.sh
        [[ ! "$?" -eq 0 ]] && exit
        thisbinfile="${thisdir}/unzip${pkgver/./}/unzip"
    fi
}

echo -e "\e[32mInstalling as 'unzip-iconv' to home local ...\e[0m"
if [[ -e ~/".local/bin/unzip-iconv" ]] || [[ -h ~/".local/bin/unzip-iconv" ]]
then
    rm ~/.local/bin/unzip-iconv
fi
[[ ! "$?" -eq 0 ]] && exit
build
ln -s "${thisbinfile}" ~/.local/bin/unzip-iconv
[[ ! "$?" -eq 0 ]] && exit

echo -e "\e[32mEverything is OK!\e[0m"
