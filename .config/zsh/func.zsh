# bk: backup file to file.backup
bk() {
  if [[ $# -eq 0 ]]; then
    echo "usage: bk <filename>" >&2
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "wrong: file '$1' is not exists or is not a regular file" >&2
    return 1
  fi
  cp -v -- "$1" "$1.backup"
}
