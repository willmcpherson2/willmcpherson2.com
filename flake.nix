{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    blog.url =
      "github:willmcpherson2/blog/d8d05289a84459fc7cb51ae58ad2578cfb4b7480";
    letscape.url =
      "github:willmcpherson2/letscape/73ef5d63e1eb89b7a8fd1df7ae1d4d616ab0b4e6";
    jmusic.url =
      "git+ssh://git@github.com/willmcpherson2/jmusic?rev=ab2c387976d46256d5547109657e69abda711706";
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
        runtimeInputs = [ pkgs.nginx pkgs.nodejs-18_x pkgs.jdk17 ];
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
          ./bin/static-web-server -p 8001 -g info -d ./static >> "$storage/server.log" 2>&1 &

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
