#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to check if a command exists
command_exists () {
    command -v "$1" >/dev/null 2>&1
}

# Install paru if it's not already installed
if ! command_exists paru; then
    echo "paru not found. Installing paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
    rm -rf /tmp/paru
    echo "paru installed successfully."
else
    echo "paru is already installed."
fi

echo "Starting dependency installation..."

# List of official repository packages
OFFICIAL_PACKAGES=(
    "archlinux-keyring"
    "bluez"
    "bluez-libs"
    "bluez-utils"
    "brightnessctl"
    "fastfetch"
    "gvfs"
    "gvfs-mtp"
    "hypridle"
    "jdk-openjdk"
    "keyutils"
    "kio"
    "kio-admin"
    "kio-extras"
    "kio5"
    "network-manager-applet"
    "networkmanager"
    "nm-connection-editor"
    "ntfs-3g"
    "os-prober"
    "polkit"
    "qt5ct"
    "sddm"
    "swaync"
    "unrar"
    "unzip"
    "wlogout"
    "xdg-desktop-portal"
    "xdg-desktop-portal-gtk"
    "neovim"
    "kitty"
    "dolphin"
    "waybar"
    "rofi"
    "fish"
    "eza"
    "pacman-contrib" # for checkupdates
    "grub" # For GRUB installation
)

# List of AUR packages
AUR_PACKAGES=(
    "archlinux-xdg-menu"
    "hyprcursor"
    "hyprgraphics"
    "hyprland"
    "hyprland-qt-support"
    "hyprland-qtutils"
    "hyprlang"
    "hyprlock"
    "hyprpaper"
    "hyprpicker"
    "hyprshot"
    "hyprsunset"
    "hyprutils"
    "hyprwayland-scanner"
    "kando-bin"
    "kde-cli-tools"
    "mission-center"
    "otf-codenewroman-nerd"
    "otf-space-grotesk"
    "polkit-qt5"
    "polkit-qt6"
    "python-pywal"
    "python-pywalfox"
    "starship"
    "swww"
    "ttf-jetbrains-mono-nerd"
    "xdg-desktop-portal-hyprland"
)

# List of optional packages (non-config required or non-system related)
OPTIONAL_PACKAGES=(
    "eog"
    "gnome-disk-utility"
    "gnome-text-editor"
    "mission-center"
    "wine"
    "spotify-launcher"
)

# Install official packages
echo "Installing official repository packages..."
paru -S --needed --noconfirm "${OFFICIAL_PACKAGES[@]}"

# Install AUR packages
echo "Installing AUR packages..."
paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# Ask about optional packages
read -p "Do you want to install optional packages (e.g., EOG, Wine, Spotify)? (y/N): " install_optional
if [[ "$install_optional" =~ ^[Yy]$ ]]; then
    echo "Installing optional packages..."
    paru -S --needed --noconfirm "${OPTIONAL_PACKAGES[@]}"
else
    echo "Skipping optional package installation."
fi

# Enable and start services
echo "Enabling and starting services..."
sudo systemctl enable --now hypridle.service || echo "Failed to enable hypridle.service. It might not be a systemd service or already running."
sudo systemctl enable --now sddm.service || echo "Failed to enable sddm.service. It might not be a systemd service or already running."
sudo systemctl enable --now NetworkManager.service || echo "Failed to enable NetworkManager.service. It might not be a systemd service or already running."
sudo systemctl enable --now xdg-desktop-portal.service || echo "Failed to enable xdg-desktop-portal.service."
sudo systemctl enable --now xdg-desktop-portal-hyprland.service || echo "Failed to enable xdg-desktop-portal-hyprland.service."

# Configure SDDM Theme
echo "Configuring SDDM theme..."
read -p "Do you want to install the 'Silent' SDDM theme? (y/N): " confirm_sddm_theme
if [[ "$confirm_sddm_theme" =~ ^[Yy]$ ]]; then
    echo "Cloning and installing Silent SDDM theme..."
    # Clone to a temporary directory first to avoid issues with cd into a non-existent dir
    mkdir -p /tmp/SilentSDDM
    sudo git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM /tmp/SilentSDDM || echo "Failed to clone Silent SDDM theme."
    if [ -d "/tmp/SilentSDDM" ]; then
        (cd /tmp/SilentSDDM && sudo ./install.sh) || echo "Failed to run Silent SDDM theme install script."
        rm -rf /tmp/SilentSDDM
        echo "Silent SDDM theme installed and configured."
    else
        echo "Silent SDDM theme repository not found after cloning. Manual intervention may be required."
    fi
else
    echo "Skipping SDDM theme installation and configuration."
fi

# Configure GRUB Theme
echo "Configuring GRUB theme..."
read -p "WARNING: GRUB installation can be risky and requires knowing your EFI partition. Do you want to install GRUB and configure the theme? (y/N): " confirm_grub
if [[ "$confirm_grub" =~ ^[Yy]$ ]]; then
    # Install GRUB (assuming EFI system, adjust --efi-directory and --bootloader-id if needed)
    echo "Installing GRUB... Please ensure your EFI partition is mounted at /boot/efi."
    sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB || echo "GRUB installation failed. Please check your boot setup and EFI partition."

    # Run GRUB theme install script from dotfiles
    # Determine the absolute path of the script's directory (which is assumed to be the My-Dotfiles root)
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    DOTFILES_SOURCE_DIR="$SCRIPT_DIR"
    GRUB_THEME_DIR="$DOTFILES_SOURCE_DIR/grub2"
    if [ -d "$GRUB_THEME_DIR" ]; then
        echo "Running GRUB theme install script from $GRUB_THEME_DIR..."
        sudo "$GRUB_THEME_DIR/install.sh" || echo "Failed to run GRUB theme install script."
    else
        echo "GRUB theme directory ($GRUB_THEME_DIR) not found. Skipping GRUB theme installation."
    fi

    # Ensure os-prober is enabled in /etc/default/grub
    if [ -f /etc/default/grub ]; then
        # Remove any existing GRUB_DISABLE_OS_PROBER line
        sudo sed -i '/^GRUB_DISABLE_OS_PROBER=/d' /etc/default/grub
        # Add GRUB_DISABLE_OS_PROBER=false to ensure os-prober runs
        echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub > /dev/null
        echo "Ensured os-prober is enabled in /etc/default/grub."
    else
        echo "/etc/default/grub not found. Cannot ensure os-prober is enabled."
    fi

    echo "Updating GRUB configuration..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg || echo "GRUB configuration update failed."
else
    echo "GRUB installation and theme configuration skipped."
fi

# Dolphin/XDG Portal Fixes
echo "Applying Dolphin/XDG Portal fixes..."
# Environment variables are now automatically added to hyprland.conf
# The script has already modified hyprland.conf to include these env vars.

# Dotfile Copying Logic
# Determine the absolute path of the script's directory (which is assumed to be the My-Dotfiles root)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTFILES_SOURCE_DIR="$SCRIPT_DIR"

echo "Copying dotfiles from $DOTFILES_SOURCE_DIR to ~/.config/..."
read -p "WARNING: This will copy files from $DOTFILES_SOURCE_DIR to ~/.config/, potentially overwriting existing configurations. Do you want to proceed? (y/N): " confirm_copy
if [[ ! "$confirm_copy" =~ ^[Yy]$ ]]; then
    echo "Dotfile copying skipped."
else
    mkdir -p "$HOME/.config"
    for item in "$DOTFILES_SOURCE_DIR"/*; do
        item_name=$(basename "$item")
        if [[ "$item_name" == "install_dependencies.sh" || "$item_name" == ".git" || "$item_name" == ".gitignore" || "$item_name" == "README.md" || "$item_name" == "LICENSE" || "$item_name" == "grub2" ]]; then
            echo "Skipping $item_name from copying."
            continue
        fi

        # Copy files and directories
        cp -r "$item" "$HOME/.config/"
        echo "Copied $item_name to ~/.config/"
    done
    echo "Dotfile copying complete."
fi

echo "Dependency installation and initial setup script complete."
echo "Please review the output for any failed installations or manual steps required."
echo "Remember to reboot or restart your Hyprland session after running this script."
