#!/usr/bin/env fish
# office-wine-installer.fish
# MIT Licence – do whatever you want.
#
# One-command installer for Microsoft Office 365 ProPlus / 2021 LTSC
# under an isolated Wine environment.
# Tested on Arch, Ubuntu, Debian, Fedora, openSUSE.
#
# Everything lives in ~/.local/share/office-wine
# Remove with:  rm -rf ~/.local/share/office-wine
# --------------------------------------------------------------------

set -g BASE_DIR "$HOME/.local/share/office-wine"
set -g WINE_DIR "$BASE_DIR/wine"
set -g OFFICE_BASE_URL "https://i.troplo.com/i"

# SHA-256 checksums  (replace if you host your own copies)
set -g WINE_SHA      "3512d274fa74"
set -g OFFICE365_SHA "b22de9957c24"
set -g LTSC_SHA      "721f0242a2c0"

set -g DESKTOP_DIR "$HOME/.local/share/applications"

# helper -----------------------------------------------------------
function die
    echo $argv >&2
    exit 1
end

function ask
    read -p "$argv [y/N] " -l answer
    test "$answer" = 'y' -o "$answer" = 'Y'
end

# detect package manager ------------------------------------------
function install_deps
    echo "Installing system dependencies ..."
    if type -q apt-get
        sudo apt-get update
        sudo apt-get install -y wget p7zip-full wine64 wine32
    else if type -q dnf
        sudo dnf install -y wget p7zip wine
    else if type -q zypper
        sudo zypper --non-interactive install wget p7zip wine
    else if type -q pacman
        if not type -q yay
            echo "Installing yay ..."
            git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
            and (cd /tmp/yay-bin; makepkg -si --noconfirm)
        end
        yay -S --needed \
          wine-staging p7zip wget \
          lib32-gcc-libs lib32-glibc lib32-alsa-lib lib32-freetype2 \
          lib32-libpng lib32-zlib lib32-lcms2 lib32-libgl lib32-libxcursor \
          lib32-libxrandr lib32-glu lib32-fontconfig lib32-libcups \
          lib32-libdbus lib32-libldap lib32-libpulse lib32-gnutls \
          lib32-libxcomposite lib32-libxinerama lib32-libxml2 lib32-libxslt \
          lib32-mpg123 lib32-openal lib32-openssl lib32-v4l-utils
    else
        die "Unknown distro – please install Wine, wget, p7zip-full manually"
    end
end

# download & verify -----------------------------------------------
function safe_download
    set url $argv[1]
    set file $argv[2]
    set sha $argv[3]
    if test -f "$file"
        echo "Using cached $(basename $file)"
    else
        echo "Downloading $(basename $url) ..."
        wget --progress=bar:force -O "$file" "$url"
    end
    echo "$sha  $file" | sha256sum -c - || die "Checksum failed for $file"
end

# wine --------------------------------------------------------------
function install_wine
    set tar "$BASE_DIR/temp/wine.tar.zst"
    safe_download "$OFFICE_BASE_URL/wine-9.7.tar.zst" $tar "$WINE_SHA"
    if not test -f "$WINE_DIR/bin/wine"
        echo "Extracting Wine ..."
        mkdir -p "$WINE_DIR"
        tar --use-compress-program=unzstd -xf "$tar" -C "$WINE_DIR"
    end
end

# office ----------------------------------------------------------
function install_office
    set flavour $argv[1]
    set prefix "$BASE_DIR/$flavour"
    set archive "$BASE_DIR/temp/office-$flavour.7z"
    set sha (test "$flavour" = "365"; and echo "$OFFICE365_SHA"; or echo "$LTSC_SHA")
    set url "$OFFICE_BASE_URL/Microsoft_Office_365-(test '$flavour' = '365'; and echo 4; or echo 3).7z"

    if test -d "$prefix"
        ask "$flavour already exists – reinstall?"; or return 0
        rm -rf "$prefix"
    end

    safe_download "$url" "$archive" "$sha"
    echo "Extracting $flavour ..."
    7z x "$archive" -o"$BASE_DIR/temp" >/dev/null
    mv "$BASE_DIR/temp/Microsoft_Office_365-"* "$prefix"
    make_desktop $flavour $prefix
end

# desktop files -----------------------------------------------------
function make_desktop
    set flavour $argv[1]
    set prefix $argv[2]
    set -l bins WINWORD EXCEL POWERPNT OUTLOOK MSACCESS MSPUB
    set -l names Word Excel PowerPoint Outlook Access Publisher
    for i in (seq (count $bins))
        set bin $bins[$i]
        set name $names[$i]
        set desktop "$DESKTOP_DIR/${bin:l}-${flavour}.desktop"
        cat > "$desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$name ($flavour)
Exec=env WINEPREFIX=$prefix $WINE_DIR/bin/wine "$prefix/drive_c/Program Files/Microsoft Office/root/Office16/$bin.EXE" %f
Icon=$prefix/drive_c/Program Files/Microsoft Office/root/Office16/$bin.EXE
Categories=Office;
EOF
    end
    if type -q update-desktop-database
        update-desktop-database "$DESKTOP_DIR"
    end
end

# main menu ---------------------------------------------------------
function main_menu
    while true
        echo
        echo "Office-on-Wine installer"
        echo "Everything will be placed in $BASE_DIR"
        echo
        echo "1) Install Office 365 ProPlus"
        echo "2) Install Office 2021 LTSC"
        echo "3) Install both"
        echo "4) Re-install Wine runtime"
        echo "5) Re-install system packages"
        echo "6) Quit"
        echo
        read -p "Choose [1-6]: " -l choice
        switch "$choice"
            case 1
                install_office 365
            case 2
                install_office ltsc
            case 3
                install_office 365
                install_office ltsc
            case 4
                rm -rf "$WINE_DIR"
                install_wine
            case 5
                install_deps
            case 6
                exit 0
            case '*'
                echo "Invalid choice"
        end
    end
end

# -------------------------------------------------------------------
# run it
# -------------------------------------------------------------------
mkdir -p "$BASE_DIR/temp"
install_deps
install_wine
main_menu
