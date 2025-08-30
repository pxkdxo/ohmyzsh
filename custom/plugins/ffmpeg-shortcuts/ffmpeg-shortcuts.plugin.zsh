function ffmpeg-video2png()
{
  if ! (( $# ))
  then
    printf >&2 'usage: %s source [destination [template]]\n' "$0"
    exit 2
  fi
  ffmpeg -i "$1" "${2:-frame}${3:-%04d}.png"
}
