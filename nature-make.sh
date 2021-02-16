This_Source="${BASH_SOURCE[0]}"
while [ -h "$This_Source" ]; do # resolve $This_Source until the file is no longer a symlink
  This_ScriptDIR="$( cd -P "$( This_ScriptDIRname "$This_Source" )" >/dev/null && pwd )"
  This_Source="$(readlink "$This_Source")"

  # if $This_Source was a relative symlink, we need to resolve it relative
  # to the path where the symlink file was located
  [[ $This_Source != /* ]] && This_Source="$This_ScriptDIR/$This_Source"
done
This_ScriptDIR="$( cd -P "$(dirname "$This_Source" )" >/dev/null && pwd )"

This_USER="$USER"

This_PWD="$(pwd)"


pkgver=6.0
srcarchive="${This_ScriptDIR}"/unzip${pkgver/./}.tar.gz
srcextdir="${This_ScriptDIR}"/unzip${pkgver/./}

function nonzero_warn_exit ()
{
    if [[ "$?" -ne 0  ]]
    then
        local _time="$(date -u +"%Y%m%d%H%M%S")"
        if [[ -z "$1" ]]
        then
            local _string="Operation with error, Aborting!"
            echo -e "\e[31m[${_time}]:Error --- ${_string}\e[0m"
        else
            local _s1="Operation with error for "
            local _s3=" Aborting!"
            echo -e "\e[31m[${_time}]:Error --- ${_s1}\e[0m\e[33m[$1]\e[0m ,\e[31m${_s3}\e[0m"
        fi
        exit 1
    fi
}

function this_patch ()
{
    echo "------> patching of $@ ..."
    patch "$@" 1>/dev/null
    nonzero_warn_exit
}

function this_extract ()
{
    echo "--> extracting archive ..."
    cd "$This_ScriptDIR"
    tar -zx -f "$srcarchive"
    nonzero_warn_exit
    cd "$This_PWD"
}

function this_prepare() {
    echo "--> patching with diff pachers ..."
    cd "$srcextdir"
    this_patch -Np1 -i ../CVE-2014-8139.patch                              # FS#43300
    this_patch -Np0 -i ../CVE-2014-8140.patch                              # FS#43391
    this_patch -Np0 -i ../CVE-2014-8141.patch                              # FS#43300
    this_patch -Np1 -i ../CVE-2014-9636_pt1.patch                          # FS#44171
    this_patch -Np1 -i ../CVE-2014-9636_pt2.patch                          # FS#44171
    this_patch -Np1 -i ../iconv-utf8+CVE-2015-1315.patch                   # iconv patch + CEV 2015-1315 fix http://seclists.org/oss-sec/2015/q1/579
    this_patch -Np1 -i ../CVE-2015-7696+CVE-2015-7697_pt1.patch            # FS#46955
    this_patch -Np1 -i ../CVE-2015-7696+CVE-2015-7697_pt2.patch            # FS#46955
}

function this_build() {
    echo "--> building unzip-iconv ..."
    cd "$srcextdir"

    # set CFLAGS -- from Debian
    DEFINES='-DACORN_FTYPE_NFS -DWILD_STOP_AT_DIR -DLARGE_FILE_SUPPORT \
           -DUNICODE_SUPPORT -DUNICODE_WCHAR -DUTF8_MAYBE_NATIVE -DNO_LCHMOD \
           -DDATE_FORMAT=DF_YMD -DUSE_BZIP2 -DNOMEMCPY -DNO_WORKING_ISPRINT'

    # make -- from Debian
    make -f unix/Makefile prefix=/usr \
         D_USE_BZ2=-DUSE_BZIP2 L_BZ2=-lbz2 \
         LF2="${LDFLAGS}" CF="${CFLAGS} ${CPPFLAGS} -I. ${DEFINES}" \
         unzips 1>/dev/null
    nonzero_warn_exit
}

this_extract
this_prepare
this_build
