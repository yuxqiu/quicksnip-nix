{
  description = "QuickSnip - Lightweight Wayland OCR & Google Lens utility for Quickshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    quicksnip-src = {
      url = "github:Ronin-CK/QuickSnip";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      quicksnip-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        quicksnip = pkgs.stdenvNoCC.mkDerivation {
          pname = "quicksnip";
          version = "unstable-${self.shortRev or "dirty"}";

          src = quicksnip-src;

          dontBuild = true;
          dontConfigure = true;

          nativeBuildInputs = [
            pkgs.makeWrapper
            pkgs.qt6.wrapQtAppsHook
            pkgs.qt6.qtbase
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/share/quickshell/QuickSnip
            cp -r . $out/share/quickshell/QuickSnip/

            mkdir -p $out/bin

            # Create the launcher
            makeWrapper ${pkgs.quickshell}/bin/quickshell $out/bin/quicksnip \
              --add-flags "-p $out/share/quickshell/QuickSnip" \
              --add-flags "-n" \
              --prefix PATH : "${
                pkgs.lib.makeBinPath [
                  pkgs.grim
                  pkgs.imagemagick
                  pkgs.tesseract
                  pkgs.wl-clipboard
                  pkgs.curl
                  pkgs.libnotify
                  pkgs.xdg-utils
                  pkgs.wlrctl
                  pkgs.wtype
                ]
              }" \
              --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.libsForQt5.qt5.qtgraphicaleffects}/lib/qt-5/qml" \
              --set QT_QPA_PLATFORM wayland

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "QuickSnip for Quickshell";
            homepage = "https://github.com/Ronin-CK/QuickSnip";
            license = licenses.mit;
            platforms = platforms.linux;
          };
        };

      in
      {
        packages = {
          default = quicksnip;
          quicksnip = quicksnip;
        };

        apps.default = {
          type = "app";
          program = "${quicksnip}/bin/quicksnip";
        };

        devShells.default = pkgs.mkShell {
          name = "quicksnip-dev";

          nativeBuildInputs = [ pkgs.qt6.wrapQtAppsHook ]; # This helps populate the env

          buildInputs = with pkgs; [
            quickshell
            qt6.qtbase
            grim
            imagemagick
            tesseract
            wl-clipboard
            curl
            libnotify
            xdg-utils
            wlrctl
            wtype
          ];

          shellHook = ''
            export QT_QPA_PLATFORM=wayland

            # Ensure QuickSnip's required imports are present
            export QML2_IMPORT_PATH="${
              pkgs.lib.makeSearchPath "lib/qt-6/qml" [ pkgs.qt6.qt5compat ]
            }:${pkgs.libsForQt5.qt5.qtgraphicaleffects}/lib/qt-5/qml''${QML2_IMPORT_PATH:+:}$QML2_IMPORT_PATH"

            echo "✅ QuickSnip dev shell ready"
            echo "   Try: quickshell -p ${./.} -n"
          '';
        };
      }
    );
}
