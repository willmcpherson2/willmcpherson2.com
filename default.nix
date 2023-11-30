{ pkgs ? import <nixpkgs> { } }:
let
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
  services = pkgs.symlinkJoin {
    name = "services";
    paths = [
      conf
      blog
      letscape
      jmusic
    ];
  };
in
pkgs.writeShellApplication {
  name = "willmcpherson2.com";
  runtimeInputs = [
    pkgs.nginx
    pkgs.nodejs-18_x
    pkgs.jdk17
  ];
  text = ''
    echo "starting services..."

    kill -- "-$(cat services.pid)" || true
    echo $PPID > services.pid

    mkdir -p storage
    storage=$(readlink -f storage)

    rm -rf services
    cp -r ${services} services
    chmod -R +w services
    services=$(readlink -f services)

    cd "$services"
    PORT=8001 ./bin/server ./static >> "$storage/server.log" 2>&1 &

    cd "$services/letscape"
    PORT=8002 LETSCAPE_DB="$storage/letscape.json" npm start >> "$storage/letscape.log" 2>&1 &

    cd "$services/jmusic"
    java -Dnogui=true -jar JMusicBot.jar >> "$storage/jmusic.log" 2>&1 &

    cd "$services"
    mkdir -p /var/cache/nginx/
    mkdir -p /var/log/nginx/
    ln -s /var/log/nginx/access.log "$storage/nginx-access.log" || true
    ln -s /var/log/nginx/error.log "$storage/nginx-error.log" || true
    nginx -c "$services/nginx.conf" >> "$storage/nginx.log" 2>&1 &

    echo "services started."
  '';
}
