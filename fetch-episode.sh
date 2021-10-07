#!/usr/bin/env bash

if [[ -n "$2" ]]; then
  mkdir -p "$2"
  cd "$2" || exit
fi

url="$1"
episode="${PWD##*/}"

filter='
/^Title: .*/c\
Title: [Butter] Puraore! Pride of Orange - '"$episode"'
/^PlayResX: .*/c\
PlayResX: 1920
/^PlayResY: .*/c\
PlayResY: 1080\
YCbCr Matrix: TV.709
'
filter_dialogue='
/^Style: .*/c\
Style: Default,Tiresias Infofont,72,&H00FFFFFF,&H000019FF,&H00000000,&H96000000,0,0,0,0,100,100,0,0,1,3.8,0.8,2,240,240,81,1\
Style: Alternate,Tiresias Infofont,72,&H00FFFFFF,&H000019FF,&H00663300,&H96000000,0,0,0,0,100,100,0,0,1,3.8,0.8,2,240,240,81,1
/^\[Events]/,/^Format/ {
/^Format/a\
Comment: 0,0:00:00.00,0:00:00.00,Default,,0,0,0,,== Dialogue ============================
}
/^Dialogue:/ { /{[^}]*\\an8[^}]*}/d }
'
filter_signs='
/^Style: .*/c\
Style: Signs,Tiresias Infofont,72,&H00FFFFFF,&H000019FF,&H00000000,&H96000000,0,0,0,0,100,100,0,0,1,3.8,0.8,2,240,240,81,1
/^\[Events]/,/^Format/ {
/^Format/a\
Comment: 0,0:00:00.00,0:00:00.00,Signs,,0,0,0,,== Signs ===============================
}
/^Dialogue:/ {
  /{[^}]*\\an8[^}]*}/!d
  s/,Default,/,Signs,/
  s/{\\an8}//
}
'

dialogue="[Butter] Puraore - ${episode} (Dialogue).ass"
signs="[Butter] Puraore - ${episode} (Signs).ass"

curl -L "$url" | xz --decompress --stdout | sed "$filter" | tee >(sed "$filter_dialogue" >"$dialogue") >(sed "$filter_signs" | tee "$signs" "${signs%.ass}.raw.ass" >/dev/null) >/dev/null
