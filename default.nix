{ pkgs ? import <nixpkgs> { } }:
let
  cmd = pkgs.writeShellScriptBin "cmd" ''
    useradd -r nobody
    groupadd nogroup
    mkdir -p /var/cache/nginx/
    mkdir -p /var/log/nginx/

    PORT=8001 server /static &

    cd letscape
    PORT=8002 LETSCAPE_DB=./db.json npm start &
    cd ..

    cd jmusic
    java -Dnogui=true -jar JMusicBot.jar &
    cd ..

    nginx -c /nginx.conf -e /error.log
  '';
  conf = pkgs.writeTextDir "nginx.conf" (builtins.readFile ./nginx.conf);
  blog =
    import
      (builtins.fetchTarball
        "https://github.com/willmcpherson2/blog/archive/4bc78b51a8092d7fcd49e4d3c688ca5b67d37492.tar.gz")
      { };
  letscape =
    import
      (builtins.fetchTarball
        "https://github.com/willmcpherson2/letscape/archive/666f7e6d4ddef0174420195e7ce8d6743f595cdd.tar.gz")
      { };
  jmusic = import
    (builtins.fetchGit {
      url = "git@github.com:willmcpherson2/jmusic.git";
      rev = "137fcea51dac95386a8afbfeec08b6d7f028fcf8";
    })
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
      pkgs.jdk17
      cmd
      conf
      blog
      letscape
      jmusic
    ];
  };
  config = {
    Cmd = [ "cmd" ];
  };
}
