{ pkgs ? import <nixpkgs> { } }:
let
  cmd = pkgs.writeShellScriptBin "cmd" ''
    useradd -r nobody
    groupadd nogroup
    mkdir -p /var/cache/nginx/
    mkdir -p /var/log/nginx/

    PORT=8001 server /static &
    PORT=8002 LETSCAPE_DB=/letscape/db.json npm start --prefix letscape &
    nginx -c /nginx.conf -e /error.log
  '';
  conf = pkgs.writeTextDir "nginx.conf" (builtins.readFile ./nginx.conf);
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
in
pkgs.dockerTools.buildImage {
  name = "asia-east1-docker.pkg.dev/willmcpherson2/willmcpherson2/willmcpherson2";
  tag = "latest";
  copyToRoot = pkgs.buildEnv {
    name = "root";
    paths = [
      pkgs.bashInteractive
      pkgs.coreutils
      pkgs.shadow
      pkgs.nginx
      pkgs.nodejs-18_x
      cmd
      conf
      blog
      letscape
    ];
  };
  config = {
    Cmd = [ "cmd" ];
  };
}
