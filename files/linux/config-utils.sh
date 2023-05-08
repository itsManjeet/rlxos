has() {
  state="$(scripts/config --keep-case -s "${1}")"
  case "${state}" in
    undef|n)
      return 1
    ;;
    y|m)
      return 0
    ;;
    *)
      echo "Wrong status for ${1}: ${state}" 1>&2
      exit 1
    ;;
  esac
}
remove() {
  scripts/config --keep-case -d "${1}"
}
module() {
  echo "${1}" >>expected-configs
  has "${1}" || scripts/config --keep-case -m "${1}"
}
must_module() {
  echo "${1}" >>expected-configs
  has "${1}" && remove ${1}
  scripts/config --keep-case -m "${1}"
}
enable() {
  echo "${1}" >>expected-configs
  scripts/config --keep-case -e "${1}"
}
value_str() {
  scripts/config --keep-case --set-str "${1}" "${2}"
}
value() {
  scripts/config --keep-case --set-val "${1}" "${2}"
}
