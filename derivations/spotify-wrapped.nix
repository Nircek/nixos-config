# SRC: https://github.com/legendofmiracles/nix-config/blob/master/derivations/spotify-wrapped.nix
{ lib, writeShellScriptBin, spotify, spotify-adblock }:

writeShellScriptBin "spotify-wrapped" ''
  LD_PRELOAD=${spotify-adblock}/lib/spotify-adblock.so ${spotify}/bin/spotify "$@"
''
