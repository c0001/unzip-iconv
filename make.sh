thissrc="${BASH_SOURCE[0]}"
while [ -h "$thissrc" ]; do # resolve $thissrc until the file is no longer a symlink
    thisdir="$( cd -P "$( dirname "$thissrc" )" >/dev/null && pwd )"
    thissrc="$(readlink "$thissrc")"

    # if $thissrc was a relative symlink, we need to resolve it relative
    # to the path where the symlink file was located
    [[ $thissrc != /* ]] && thissrc="$thisdir/$thissrc"
done
thisdir="$( cd -P "$( dirname "$thissrc" )" >/dev/null && pwd )"

makepkg -f .
[[ ! "$?" -eq 0 ]] && exit

echo -e "\e[32mInstalling as 'unzip-iconv' to home local ...\e[0m"
if [[ -f ~/".local/bin/unzip-iconv" ]]
then
    rm ~/.local/bin/unzip-iconv
fi
[[ ! "$?" -eq 0 ]] && exit
ln -s "${thisdir}/src/unzip60/unzip" ~/.local/bin/unzip-iconv
[[ ! "$?" -eq 0 ]] && exit

echo -e "\e[32mEverything is OK!\e[0m"
