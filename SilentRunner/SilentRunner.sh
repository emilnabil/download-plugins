#!/bin/sh
# SilentRunner Online Installer (POSIX, no Python; curl + wget only)
# - Single download entrypoint: download_file URL DEST
# - Priority: curl -> wget
# - Range fallback in 1MiB chunks
# - Atomic writes (.part -> rename)
# - SHA256 verification against packaging/checksums.json
# - Logging to /tmp/SilentRunner-install.log

set -eu

BASE="https://raw.githubusercontent.com/tigrousad/enigma2-plugin-silentrunner/main/SilentRunner"
PLUGIN="/usr/lib/enigma2/python/Plugins/Extensions/SilentRunner"
TMP="/tmp/SilentRunner"
LOG="/tmp/SilentRunner-install.log"
CHECKSUMS_FILE="${PWD}/SilentRunner/packaging/checksums.json"

# tunables
CHUNK_SIZE=1048576    # 1 MiB
CURL_CONNECT_TIMEOUT=10
CURL_MAX_TIME=180
CURL_RETRIES=5
CURL_RETRY_DELAY=2
WGET_TRIES=5
WGET_TIMEOUT=20

log() {
  now=$(date -u '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date '+%s')
  printf '%s %s\n' "$now" "$*" >> "$LOG"
}

sha256_of_file() {
  f=$1
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" | awk '{print $1}'
    return 0
  fi
  if command -v openssl >/dev/null 2>&1; then
    # openssl output: SHA256(filename)= <hash>
    openssl dgst -sha256 "$f" 2>/dev/null | awk '{print $NF}'
    return 0
  fi
  # no tool
  return 1
}

expected_sha_for_path() {
  path="$1"
  if [ ! -f "$CHECKSUMS_FILE" ]; then
    echo ""
    return 0
  fi
  # exact key match: "SilentRunner/...": "hash",
  # use awk to find line and extract the hex string
  awk -v key='"'"$path"'"' '
    $0 ~ key {
      if (match($0, /"[^"]*"[[:space:]]*:[[:space:]]*"([0-9a-f]{64})"/, m)) {
        print m[1]; exit
      }
    }
  ' "$CHECKSUMS_FILE" || true
}

atomic_move() {
  src=$1; dst=$2
  mv -f "$src" "$dst"
}

curl_supported_retry_all_errors() {
  if curl --help 2>&1 | grep -q -- '--retry-all-errors'; then
    return 0
  fi
  return 1
}

curl_download() {
  url="$1"; out="$2"
  log "curl_download start $url -> $out"
  RETOPT=""
  if curl_supported_retry_all_errors; then
    RETOPT="--retry-all-errors"
  fi
  CLOG="/tmp/sr_curl_$$.log"
  # run curl; capture stderr to CLOG for diagnostics
  curl -f --silent --show-error --location --http1.1 \
    --connect-timeout "$CURL_CONNECT_TIMEOUT" --max-time "$CURL_MAX_TIME" \
    --retry "$CURL_RETRIES" --retry-delay "$CURL_RETRY_DELAY" $RETOPT \
    -H "Connection: close" -H "Accept-Encoding: identity" -o "$out" "$url" 2>>"$CLOG"
  rc=$?
  if [ -f "$CLOG" ]; then
    tail -n 200 "$CLOG" >> "$LOG" || true
    rm -f "$CLOG" || true
  fi
  log "curl_download rc=$rc for $url"
  return $rc
}

wget_download() {
  url="$1"; out="$2"
  log "wget_download start $url -> $out"
  WLOG="/tmp/sr_wget_$$.log"
  # BusyBox and GNU wget use --tries and --timeout
  wget -q --tries="$WGET_TRIES" --timeout="$WGET_TIMEOUT" -O "$out" "$url" 2>>"$WLOG"
  rc=$?
  if [ -f "$WLOG" ]; then
    tail -n 200 "$WLOG" >> "$LOG" || true
    rm -f "$WLOG" || true
  fi
  log "wget_download rc=$rc for $url"
  return $rc
}

# Range chunked downloader; uses curl when available, falls back to wget with Range header
download_in_ranges() {
  url="$1"; tmp_out="$2"; chunk="$3"
  log "range_download start $url -> $tmp_out (chunk=$chunk)"
  pos=0
  rm -f "$tmp_out"
  while :; do
    end=$((pos + chunk - 1))
    log "range: ${pos}-${end}"
    ch_tmp="${tmp_out}.chunk"
    if command -v curl >/dev/null 2>&1; then
      curl -f --silent --show-error --location --http1.1 \
        --connect-timeout 10 --max-time 120 \
        -H "Connection: close" -H "Accept-Encoding: identity" \
        --range "${pos}-${end}" -o "$ch_tmp" "$url" 2>>"$LOG" || rc=$?
      rc=${rc:-0}
    else
      # try wget with header
      if wget --help 2>/dev/null | grep -q '\--header'; then
        wget -q --header="Range: bytes=${pos}-${end}" -O "$ch_tmp" "$url" 2>>"$LOG" || rc=$?
        rc=${rc:-0}
      else
        rc=1
      fi
    fi

    if [ -n "${rc:-}" ] && [ "$rc" -ne 0 ]; then
      log "chunk download failed at ${pos} (rc=${rc}), retrying up to 3 times"
      tries=0; success=0
      while [ "$tries" -lt 3 ]; do
        tries=$((tries + 1))
        log "chunk retry ${tries} at ${pos}"
        if command -v curl >/dev/null 2>&1; then
          curl -f --silent --show-error --location --http1.1 \
            --connect-timeout 10 --max-time 120 \
            -H "Connection: close" -H "Accept-Encoding: identity" \
            --range "${pos}-${end}" -o "$ch_tmp" "$url" 2>>"$LOG" || rc=$?
          rc=${rc:-0}
        else
          if wget --help 2>/dev/null | grep -q '\--header'; then
            wget -q --header="Range: bytes=${pos}-${end}" -O "$ch_tmp" "$url" 2>>"$LOG" || rc=$?
            rc=${rc:-0}
          else
            rc=1
          fi
        fi
        if [ -f "$ch_tmp" ] && [ -s "$ch_tmp" ]; then
          success=1
          break
        fi
      done
      if [ "$success" -ne 1 ]; then
        log "chunked download giving up at pos=${pos}"
        rm -f "$ch_tmp"
        return 1
      fi
    fi

    if [ -f "$ch_tmp" ]; then
      cat "$ch_tmp" >> "$tmp_out"
      csize=$(wc -c < "$ch_tmp" 2>/dev/null || echo 0)
      rm -f "$ch_tmp"
    else
      csize=0
    fi

    if [ -z "$csize" ] || [ "$csize" -lt "$chunk" ] || [ "$csize" -eq 0 ]; then
      break
    fi
    pos=$((pos + csize))
  done
  log "range_download finished"
  return 0
}

# Single entry point
download_file() {
  url="$1"; dest="$2"; tmp="${dest}.part"
  rm -f "$tmp"
  log "download_file START url=$url dest=$dest"

  # try curl first
  if command -v curl >/dev/null 2>&1; then
    curl_download "$url" "$tmp" || c_rc=$?
    c_rc=${c_rc:-0}
    if [ "$c_rc" -eq 0 ] && [ -s "$tmp" ]; then
      log "download_file curl succeeded for $url"
      atomic_move "$tmp" "$dest"
      return 0
    else
      log "download_file curl failed rc=${c_rc}"
      rm -f "$tmp"
    fi
  else
    log "curl not found, skipping curl stage"
  fi

  # try wget
  if command -v wget >/dev/null 2>&1; then
    wget_download "$url" "$tmp" || w_rc=$?
    w_rc=${w_rc:-0}
    if [ "$w_rc" -eq 0 ] && [ -s "$tmp" ]; then
      log "download_file wget succeeded for $url"
      atomic_move "$tmp" "$dest"
      return 0
    else
      log "download_file wget failed rc=${w_rc}"
      rm -f "$tmp"
    fi
  else
    log "wget not found, skipping wget stage"
  fi

  # ranged fallback
  log "download_file: falling back to ranged chunk download for $url"
  download_in_ranges "$url" "$tmp" "$CHUNK_SIZE" || range_rc=$?
  range_rc=${range_rc:-1}
  if [ "$range_rc" -eq 0 ] && [ -s "$tmp" ]; then
    log "download_file range succeeded for $url"
    atomic_move "$tmp" "$dest"
    return 0
  fi

  log "download_file ALL FAILED for $url"
  return 1
}

verify_checksum() {
  dest="$1"
  # derive key relative to SilentRunner/ so checksums.json keys match
  # if dest is under $TMP (e.g., /tmp/SilentRunner/...), strip the prefix and prepend SilentRunner/
  key=""
  case "$dest" in
    "$TMP"/*)
      rel="${dest#$TMP/}"
      key="SilentRunner/$rel"
      ;;
    */SilentRunner/*)
      # handle other patterns containing SilentRunner
      rel="${dest##*/SilentRunner/}"
      key="SilentRunner/$rel"
      ;;
    *)
      # fallback to basename
      key="$(basename "$dest")"
      ;;
  esac

  exp=$(expected_sha_for_path "$key")
  if [ -z "$exp" ]; then
    log "verify_checksum: no expected sha for $key (skipping)"
    return 0
  fi
  if [ ! -f "$dest" ]; then
    log "verify_checksum: file missing $dest"
    return 2
  fi
  got=$(sha256_of_file "$dest" ) || { log "verify_checksum: no sha tool"; return 3; }
  log "verify_checksum: $key expected=$exp got=$got"
  if [ "$got" = "$exp" ]; then
    return 0
  fi
  return 1
}

install_files() {
  srcdir="$1"; destdir="$2"
  log "install_files: copying $srcdir -> $destdir"
  rm -rf "$destdir"
  mkdir -p "$(dirname "$destdir")"
  cp -a "$srcdir" "$destdir"
  if command -v python3 >/dev/null 2>&1; then
    python3 -m compileall "$destdir" >/dev/null 2>&1 || true
  fi
}

cleanup() {
  log "cleanup: removing $TMP and temporary logs"
  rm -rf "$TMP"
  rm -f /tmp/sr_curl_* /tmp/sr_wget_* 2>/dev/null || true
}

# start
mkdir -p "$(dirname "$LOG")"
: > "$LOG"
log "Installer START"

rm -rf "$TMP"
mkdir -p "$TMP/icons" "$TMP/locale"

FILES="__init__.py plugin.py main.py runner.py explorer.py widgets.py skin.py utils.py version.py plugin.png"
ICONS="blue.png failed.png finished.png folder.png green.png plugin.png py.png red.png running.png sh.png stopped.png yellow.png"

# try fetch checksums.json from local path or from repo
if [ -f "$CHECKSUMS_FILE" ]; then
  log "Using local checksums file $CHECKSUMS_FILE"
else
  CHECKS_URL="${BASE}/packaging/checksums.json"
  if download_file "$CHECKS_URL" "$TMP/checksums.json"; then
    log "downloaded remote checksums.json"
    CHECKSUMS_FILE="$TMP/checksums.json"
  else
    log "checksums.json missing and remote fetch failed; aborting"
    echo "ERROR: checksums.json not available; cannot verify files" >&2
    cleanup
    exit 1
  fi
fi

# download main files
for f in $FILES; do
  url="${BASE}/${f}"
  dest="$TMP/$f"
  log "begin file $f"
  if download_file "$url" "$dest"; then
    if verify_checksum "$dest"; then
      log "file ok $f"
    else
      log "SHA mismatch after download $f; aborting"
      echo "SHA mismatch for $f; aborting" >&2
      cleanup
      exit 1
    fi
  else
    log "download failed for $f; aborting"
    echo "Download failed for $f" >&2
    cleanup
    exit 1
  fi
done

# icons
for f in $ICONS; do
  url="${BASE}/icons/${f}"
  dest="$TMP/icons/$f"
  log "begin icon $f"
  if download_file "$url" "$dest"; then
    if verify_checksum "$dest"; then
      log "icon ok $f"
    else
      log "SHA mismatch after download icon $f; aborting"
      echo "SHA mismatch for icon $f; aborting" >&2
      cleanup
      exit 1
    fi
  else
    log "download failed for icon $f; aborting"
    echo "Download failed for icon $f" >&2
    cleanup
    exit 1
  fi
done

# locale
if download_file "${BASE}/locale/readme.txt" "$TMP/locale/readme.txt"; then
  if verify_checksum "$TMP/locale/readme.txt"; then
    log "locale OK"
  else
    log "SHA mismatch locale; aborting"
    echo "SHA mismatch for locale" >&2
    cleanup
    exit 1
  fi
else
  log "locale download failed; aborting"
  echo "Download failed for locale" >&2
  cleanup
  exit 1
fi

# install
log "All files downloaded and verified. Installing..."
install_files "$TMP" "$PLUGIN"
log "Install complete"

cleanup
log "Installer FINISH success"

echo ""
echo "[SilentRunner] Installation completed successfully."
echo ""
echo "Restart Enigma2:" 
echo "killall -HUP enigma2"
echo "or"
echo "init 6"
