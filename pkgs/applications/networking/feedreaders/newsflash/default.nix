{ lib
, rustPlatform
, fetchFromGitLab
, meson
, ninja
, pkg-config
, wrapGAppsHook
, gdk-pixbuf
, glib
, gtk3
, libhandy
, openssl
, sqlite
, webkitgtk
, glib-networking
, librsvg
, gst_all_1
}:

rustPlatform.buildRustPackage rec {
  pname = "newsflash";
  version = "1.0.4";

  src = fetchFromGitLab {
    owner = "news-flash";
    repo = "news_flash_gtk";
    rev = version;
    sha256 = "0x0ws3mhkvf1a8986c8mh2navvvmkkiwymn0smrybffsgqdd2jh1";
  };

  cargoSha256 = "0rv2zrbarkkg56yg1w75lpdazgbik36yb70bzc6zqz1rmxinhqb0";

  patches = [
    ./no-post-install.patch
  ];

  postPatch = ''
    chmod +x build-aux/cargo.sh
    patchShebangs .
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook

    # Provides setup hook to fix "Unrecognized image file format"
    gdk-pixbuf

    # Provides glib-compile-resources to compile gresources
    glib
  ];

  buildInputs = [
    gtk3
    libhandy
    openssl
    sqlite
    webkitgtk

    # TLS support for loading external content in webkitgtk WebView
    glib-networking

    # SVG support for gdk-pixbuf
    librsvg
  ] ++ (with gst_all_1; [
    # Audio & video support for webkitgtk WebView
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

  # Unset default rust phases to use meson & ninja instead
  configurePhase = null;
  buildPhase = null;
  checkPhase = null;
  installPhase = null;
  installCheckPhase = null;

  meta = with lib; {
    description = "A modern feed reader designed for the GNOME desktop";
    homepage = "https://gitlab.com/news-flash/news_flash_gtk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.all;
  };
}
