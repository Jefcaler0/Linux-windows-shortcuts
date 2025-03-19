#!/bin/bash

# Script para replicar accesos directos de Windows en diversas distribuciones de Linux
# Soporta Debian, Ubuntu, Fedora, Arch, OpenSUSE y más
# Soporta GNOME, KDE Plasma, XFCE, Cinnamon y MATE
# Autor: [jcano]
# Repositorio: []

DRY_RUN=${DRY_RUN:-false}
if [ "$DRY_RUN" = "true" ]; then
    gsettings() { echo "gsettings $*" ; }
    kwriteconfig5() { echo "kwriteconfig5 $*" ; }
    qdbus() { echo "qdbus $*" ; }
    xfconf-query() { echo "xfconf-query $*" ; }
    pacman() { echo "pacman $*" ; }
    dnf() { echo "dnf $*" ; }
    apt-get() { echo "apt-get $*" ; }
    zypper() { echo "zypper $*" ; }
fi

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sin color

# Directorio para respaldos
BACKUP_DIR="$HOME/.config/shortcuts_backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Función para manejar errores
handle_error() {
    local exit_code=$1
    local message=$2
    echo -e "${RED}Error: $message${NC}" >&2
    exit "$exit_code"
}

# Verificar si se está ejecutando como root
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}Advertencia: No se recomienda ejecutar este script como root.${NC}"
    sleep 2
fi

# Crear directorio de respaldo si no existe
create_backup_dir() {
    if [ "$DRY_RUN" = "false" ]; then
        mkdir -p "$BACKUP_DIR" || handle_error 1 "No se pudo crear el directorio de respaldo $BACKUP_DIR"
    fi
}

# Detectar la distribución
detect_distro() {
    if [ -f /etc/os-release ]; then
        DISTRO=$(grep -oP '^ID=\K.*' /etc/os-release | tr -d '"' | tr '[:upper:]' '[:lower:]')
        case $DISTRO in
            "linuxmint") DISTRO="ubuntu" ;;
            "endeavouros"|"manjaro") DISTRO="arch" ;;
            "opensuse-tumbleweed") DISTRO="opensuse" ;;
        esac
    else
        handle_error 1 "No se pudo detectar la distribución"
    fi

    case $DISTRO in
        "ubuntu"|"debian"|"fedora"|"arch"|"opensuse") ;;
        *) handle_error 1 "Distribución no soportada: $DISTRO" ;;
    esac
}

# Instalar dependencias según distribución
install_dependencies() {
    case $DISTRO in
        "arch")
            echo -e "${YELLOW}Verificando dependencias para Arch Linux...${NC}"
            pacman -Sy --needed --noconfirm gsettings-desktop-schemas dconf || handle_error 1 "Fallo al instalar dependencias"
            ;;
        "fedora")
            echo -e "${YELLOW}Verificando dependencias para Fedora...${NC}"
            dnf install -y dconf || handle_error 1 "Fallo al instalar dependencias"
            ;;
        "debian"|"ubuntu")
            echo -e "${YELLOW}Verificando dependencias para Debian/Ubuntu...${NC}"
            if ! apt-get update; then
                handle_error 1 "Fallo al actualizar paquetes"
            fi
            if ! apt-get install -y dconf-cli; then
                handle_error 1 "Fallo al instalar dependencias"
            fi
            ;;
        "opensuse")
            echo -e "${YELLOW}Verificando dependencias para openSUSE...${NC}"
            zypper install -y dconf || handle_error 1 "Fallo al instalar dependencias"
            ;;
    esac
}

# Detectar entorno de escritorio
detect_desktop_environment() {
    IFS=':' read -ra DE_ARRAY <<< "${XDG_CURRENT_DESKTOP:-Unknown}"
    for de in "${DE_ARRAY[@]}"; do
        case $(echo "$de" | tr '[:upper:]' '[:lower:]') in
            *gnome*)    DE="gnome"; break ;;
            *kde*)      DE="kde"; break ;;
            *xfce*)     DE="xfce"; break ;;
            *cinnamon*) DE="cinnamon"; break ;;
            *mate*)     DE="mate"; break ;;
            *)          DE="unknown" ;;
        esac
    done

    if [ "$DE" = "unknown" ]; then
        handle_error 1 "Entorno de escritorio no detectado o no soportado"
    fi
}

# Función para configurar atajos en GNOME
configure_gnome() {
    echo -e "${GREEN}Configurando atajos de Windows en GNOME...${NC}"
    command -v gsettings >/dev/null || handle_error 1 "gsettings no está instalado"

    if [ "$DRY_RUN" = "false" ]; then
        echo -e "${YELLOW}Creando respaldo de configuraciones GNOME...${NC}"
        dconf dump /org/gnome/ > "$BACKUP_DIR/gnome_backup_$TIMESTAMP.conf" || handle_error 1 "Fallo al crear respaldo de GNOME"
    fi

    gsettings set org.gnome.settings-daemon.plugins.media-keys home '<Super>e' || handle_error 1 "Error al configurar Win+E"
    gsettings set org.gnome.settings-daemon.plugins.media-keys terminal '<Control><Shift>t' || handle_error 1 "Error al configurar Ctrl+Shift+T"
    gsettings set org.gnome.desktop.wm.keybindings toggle-show-desktop "['<Super>d']" || handle_error 1 "Error al configurar Win+D"
    gsettings set org.gnome.settings-daemon.plugins.media-keys screenlock '<Super>l' || handle_error 1 "Error al configurar Win+L"
    gsettings set org.gnome.shell.keybindings switch-applications "['<Super>Tab']" || handle_error 1 "Error al configurar Win+Tab"

    local CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    local CURRENT_LIST
    CURRENT_LIST=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings) || handle_error 1 "Error al obtener keybindings actuales"
    
    if [[ ! "$CURRENT_LIST" == *"$CUSTOM_PATH"* ]]; then
        if [ "$CURRENT_LIST" = "@as []" ] || [ -z "$CURRENT_LIST" ]; then
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$CUSTOM_PATH']" || handle_error 1 "Error al configurar keybindings personalizados"
        else
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${CURRENT_LIST%]}, '$CUSTOM_PATH']" || handle_error 1 "Error al configurar keybindings personalizados"
        fi
    fi

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding "$CUSTOM_PATH" name 'Abrir Configuración' || handle_error 1 "Error al configurar nombre"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding "$CUSTOM_PATH" command 'gnome-control-center' || handle_error 1 "Error al configurar comando"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding "$CUSTOM_PATH" binding '<Super>i' || handle_error 1 "Error al configurar Win+I"
}

# Función para configurar atajos en KDE Plasma
configure_kde() {
    echo -e "${GREEN}Configurando atajos de Windows en KDE Plasma...${NC}"
    command -v kwriteconfig5 >/dev/null || handle_error 1 "kwriteconfig5 no está instalado"

    if [ "$DRY_RUN" = "false" ]; then
        echo -e "${YELLOW}Creando respaldo de configuraciones KDE...${NC}"
        cp "$HOME/.config/kwinrc" "$BACKUP_DIR/kwinrc_backup_$TIMESTAMP" 2>/dev/null || echo -e "${YELLOW}No se encontró kwinrc para respaldar${NC}"
        cp "$HOME/.config/kglobalshortcutsrc" "$BACKUP_DIR/kglobalshortcutsrc_backup_$TIMESTAMP" 2>/dev/null || echo -e "${YELLOW}No se encontró kglobalshortcutsrc para respaldar${NC}"
    fi

    kwriteconfig5 --file kglobalshortcutsrc --group "dolphin.desktop" --key "_launch" "<Super>e" || handle_error 1 "Error al configurar Win+E"
    kwriteconfig5 --file kwinrc --group Windows --key "ShowDesktop" "<Super>d" || handle_error 1 "Error al configurar Win+D"
    kwriteconfig5 --file kwinrc --group ModifierOnlyShortcuts --key "Meta" "org.kde.krunner" || handle_error 1 "Error al configurar Meta key"
    qdbus org.kde.KWin /KWin reconfigure || handle_error 1 "Error al recargar configuración de KWin"
}

# Función para configurar atajos en XFCE
configure_xfce() {
    echo -e "${GREEN}Configurando atajos de Windows en XFCE...${NC}"
    command -v xfconf-query >/dev/null || handle_error 1 "xfconf-query no está instalado"

    if [ "$DRY_RUN" = "false" ]; then
        echo -e "${YELLOW}Creando respaldo de configuraciones XFCE...${NC}"
        xfconf-query -c xfce4-keyboard-shortcuts -l -v > "$BACKUP_DIR/xfce_shortcuts_backup_$TIMESTAMP.txt" || handle_error 1 "Fallo al crear respaldo de XFCE"
    fi

    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>e" -n -t string -s "thunar" || handle_error 1 "Error al configurar Win+E"
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>d" -n -t string -s "xfdesktop --toggle-desktop" || handle_error 1 "Error al configurar Win+D"
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>l" -n -t string -s "xflock4" || handle_error 1 "Error al configurar Win+L"
}

# Función para configurar atajos en Cinnamon
configure_cinnamon() {
    echo -e "${GREEN}Configurando atajos de Windows en Cinnamon...${NC}"
    command -v gsettings >/dev/null || handle_error 1 "gsettings no está instalado"

    if [ "$DRY_RUN" = "false" ]; then
        echo -e "${YELLOW}Creando respaldo de configuraciones Cinnamon...${NC}"
        dconf dump /org/cinnamon/ > "$BACKUP_DIR/cinnamon_backup_$TIMESTAMP.conf" || handle_error 1 "Fallo al crear respaldo de Cinnamon"
    fi

    gsettings set org.cinnamon.desktop.keybindings.wm show-desktop "['<Super>d']" || handle_error 1 "Error al configurar Win+D"
    gsettings set org.cinnamon.desktop.keybindings.wm switch-windows "['<Super>Tab']" || handle_error 1 "Error al configurar Win+Tab"
    gsettings set org.cinnamon.desktop.keybindings.wm lock-screen "['<Super>l']" || handle_error 1 "Error al configurar Win+L"
}

# Función para configurar atajos en MATE
configure_mate() {
    echo -e "${GREEN}Configurando atajos de Windows en MATE...${NC}"
    command -v gsettings >/dev/null || handle_error 1 "gsettings no está instalado"

    if [ "$DRY_RUN" = "false" ]; then
        echo -e "${YELLOW}Creando respaldo de configuraciones MATE...${NC}"
        dconf dump /org/mate/ > "$BACKUP_DIR/mate_backup_$TIMESTAMP.conf" || handle_error 1 "Fallo al crear respaldo de MATE"
    fi

    gsettings set org.mate.Marco.global-keybindings show-desktop "['<Super>d']" || handle_error 1 "Error al configurar Win+D"
    gsettings set org.mate.Marco.global-keybindings switch-windows "['<Super>Tab']" || handle_error 1 "Error al configurar Win+Tab"
    gsettings set org.mate.Marco.global-keybindings lock-screen "['<Super>l']" || handle_error 1 "Error al configurar Win+L"
}

# Ejecución principal
main() {
    create_backup_dir
    detect_distro
    if [ "$DRY_RUN" = "false" ]; then
        install_dependencies
    else
        echo "Simulando instalación de dependencias para $DISTRO"
    fi
    detect_desktop_environment
    
    case $DE in
        "gnome")    configure_gnome ;;
        "kde")      configure_kde ;;
        "xfce")     configure_xfce ;;
        "cinnamon") configure_cinnamon ;;
        "mate")     configure_mate ;;
    esac

    echo -e "\n${GREEN}Configuración completada exitosamente!${NC}"
    echo -e "Distribución: ${YELLOW}$DISTRO${NC}"
    echo -e "Entorno de escritorio: ${YELLOW}$DE${NC}"
    if [ "$DRY_RUN" = "false" ]; then
        echo -e "${YELLOW}Respaldos guardados en: $BACKUP_DIR${NC}"
    fi
}

# Ejecutar script principal
main