# Utilities for shell applications

log () {
    if [ -z "${SHELLUTILS_LOG+x}" ]; then
        return 0
    fi
    local logfile="${SHELLUTILS_LOGFILE:-/dev/stdout}"
    printf "$1\n" >>"$logfile"
}