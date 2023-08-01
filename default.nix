{ pkgs ? import <nixpkgs> { } }:
let
  blog =
    import
      (builtins.fetchTarball
        "https://github.com/willmcpherson2/blog/archive/c84b2b2314d72a2f360babb12ac8929670c790cf.tar.gz")
      { };
  letscape =
    import
      (builtins.fetchTarball
        "https://github.com/willmcpherson2/letscape/archive/b512df5c13132362ba5fa4444b9c869dbce94964.tar.gz")
      { };
  cmd = pkgs.writeShellScriptBin "cmd" ''
    PORT=8001 server /static &
    PORT=8002 LETSCAPE_DB=/letscape/db.json npm start --prefix letscape
  '';
in
pkgs.dockerTools.buildImage {
  name = "willmcpherson2.com";
  tag = "latest";
  copyToRoot = pkgs.buildEnv {
    name = "root";
    paths = [
      pkgs.nodejs-18_x
      pkgs.bashInteractive
      pkgs.coreutils
      blog
      letscape
      cmd
    ];
  };
  config = {
    Cmd = [ "cmd" ];
  };
}
