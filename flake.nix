{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    blog.url =
      "github:willmcpherson2/blog/73fcac8b8985372040ae4350474533a2087af728";
    letscape.url =
      "github:willmcpherson2/letscape/96102b8a3f941e6eb29de407df6b7679a15746ea";
    jmusic.url =
      "git+ssh://git@github.com/willmcpherson2/jmusic?rev=542018c1c264df6b3ba012aeb7cea2ee22876745";
  };

  outputs = { self, nixpkgs, blog, letscape, jmusic }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      conf = pkgs.writeTextDir "nginx.conf" (builtins.readFile ./nginx.conf);
      services = pkgs.symlinkJoin {
        name = "services";
        paths = [
          conf
          blog.packages.x86_64-linux.default
          letscape.packages.x86_64-linux.default
          jmusic.packages.x86_64-linux.default
        ];
      };
    in {
      packages.x86_64-linux.default = pkgs.writeShellApplication {
        name = "willmcpherson2.com";
        runtimeInputs = [
          pkgs.nginx
          blog.packages.x86_64-linux.server
          letscape.packages.x86_64-linux.node
          jmusic.packages.x86_64-linux.jdk
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

          cd "$services/static"
          static-web-server -p 8001 -g info -d . >> "$storage/server.log" 2>&1 &

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
      };
    };
}
