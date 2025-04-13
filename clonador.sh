#!/bin/bash

# Colores
VERDE="\e[32m"
ROJO="\e[31m"
AMARILLO="\e[33m"
AZUL="\e[34m"
NEUTRO="\e[0m"

# Fichero de log
LOGFILE="$HOME/clonado_git.log"

log() {
  echo -e "$1"
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${1//\\e\[[0-9;]*m/}" >> "$LOGFILE"
}

echo "--------------------------------------------------"
log "${AZUL}Este script va a:${NEUTRO}
1. Verificar Git y SSH.
2. Generar clave SSH si no existe.
3. Comprobar conexión SSH con GitHub.
4. Pedir URL SSH del repositorio y ruta destino.
5. Clonar el repositorio.
6. Detectar si es proyecto Python o Node.js y preparar el entorno.
7. Copiar .env.example a .env si procede."
echo "--------------------------------------------------"
read -p "¿Quieres continuar? (s/n): " confirmacion

if [[ "$confirmacion" != "s" ]]; then
  log "${AMARILLO}Proceso cancelado por el usuario.${NEUTRO}"
  exit 0
fi

# Verificación de herramientas base
command -v git >/dev/null || { log "${ROJO}Falta Git. Usa 'sudo apt install git'.${NEUTRO}"; exit 1; }
command -v ssh >/dev/null || { log "${ROJO}Falta SSH. Usa 'sudo apt install openssh-client'.${NEUTRO}"; exit 1; }

# Clave SSH personalizada
read -p "¿Qué nombre quieres dar al archivo de clave SSH? (ENTER para 'id_ed25519'): " ssh_key_name
ssh_key_name=${ssh_key_name:-id_ed25519}
ssh_key_path="$HOME/.ssh/$ssh_key_name"

if [ ! -f "$ssh_key_path" ]; then
  log "${AMARILLO}No se encontró clave SSH '$ssh_key_name'. Generando nueva...${NEUTRO}"
  read -p "Introduce el correo para la clave SSH (ENTER para 'servidor@antoniovarela.es'): " dir_correo
  dir_correo=${dir_correo:-servidor@antoniovarela.es}
  ssh-keygen -t ed25519 -f "$ssh_key_path" -C "$dir_correo"
  log "${VERDE}Clave SSH generada. Añádela a GitHub: https://github.com/settings/keys${NEUTRO}"
  cat "$ssh_key_path.pub"
  read -p "Pulsa ENTER cuando la hayas añadido..."
fi


# Comprobar conexión SSH con GitHub
log "${AZUL}Probando conexión SSH con GitHub...${NEUTRO}"
ssh -T git@github.com
if [ $? -ne 1 ] && [ $? -ne 255 ]; then
  log "${ROJO}Conexión SSH fallida. Revisa tu clave o GitHub.${NEUTRO}"
  exit 1
fi

# Preguntar por URL del repositorio y carpeta destino
read -p "Introduce la URL SSH del repositorio (ej: git@github.com:usuario/repositorio.git): " repo_url
read -p "Introduce la ruta donde clonar el repositorio: " destino

# Comprobar y preparar carpeta
if [ -d "$destino" ]; then
  if [ "$(ls -A "$destino")" ]; then
    log "${AMARILLO}La carpeta '$destino' ya tiene contenido.${NEUTRO}"
    read -p "¿Quieres continuar? (s/n): " continuar
    [[ "$continuar" != "s" ]] && { log "${AMARILLO}Cancelado.${NEUTRO}"; exit 1; }
  fi
else
  mkdir -p "$destino" && log "${VERDE}Carpeta '$destino' creada.${NEUTRO}"
fi

# Clonación
cd "$destino"
log "${AZUL}Clonando repositorio...${NEUTRO}"
git clone "$repo_url" .

if [ $? -ne 0 ]; then
  log "${ROJO}Error al clonar el repositorio. No se continuará con el entorno.${NEUTRO}"
  exit 1
fi

log "${VERDE}Repositorio clonado correctamente.${NEUTRO}"

# Detectar tipo de proyecto
if [ -f "requirements.txt" ]; then
  log "${AZUL}Proyecto Python detectado. Preparando entorno virtual...${NEUTRO}"

  command -v python3 >/dev/null || { log "${ROJO}Python no está instalado.${NEUTRO}"; exit 1; }

  if ! command -v pip >/dev/null; then
    log "${AMARILLO}Pip no está instalado.${NEUTRO}"
    read -p "¿Quieres instalar pip automáticamente? (s/n): " instalar_pip
    if [[ "$instalar_pip" == "s" ]]; then
      sudo apt update && sudo apt install -y python3-pip
    else
      log "${ROJO}No se puede continuar sin pip.${NEUTRO}"
      exit 1
    fi
  fi

  python3 -m venv venv
  source venv/bin/activate
  pip install --upgrade pip
  pip install -r requirements.txt
  log "${VERDE}Entorno Python creado y dependencias instaladas.${NEUTRO}"

elif [ -f "package.json" ]; then
  log "${AZUL}Proyecto Node.js detectado. Instalando dependencias...${NEUTRO}"

  if ! command -v node >/dev/null; then
    log "${AMARILLO}Node.js no está instalado.${NEUTRO}"
    read -p "¿Quieres instalar Node.js automáticamente? (s/n): " instalar_node
    if [[ "$instalar_node" == "s" ]]; then
      sudo apt update && sudo apt install -y nodejs
    else
      log "${ROJO}No se puede continuar sin Node.js.${NEUTRO}"
      exit 1
    fi
  fi

  if ! command -v npm >/dev/null; then
    log "${AMARILLO}NPM no está instalado.${NEUTRO}"
    read -p "¿Quieres instalar NPM automáticamente? (s/n): " instalar_npm
    if [[ "$instalar_npm" == "s" ]]; then
      sudo apt update && sudo apt install -y npm
    else
      log "${ROJO}No se puede continuar sin NPM.${NEUTRO}"
      exit 1
    fi
  fi

  npm install
  log "${VERDE}Dependencias de Node.js instaladas.${NEUTRO}"
else
  log "${AMARILLO}No se detectaron ni requirements.txt ni package.json. No se ha configurado entorno.${NEUTRO}"
fi

# Copiar .env si procede
if [ -f ".env.example" ]; then
  if [ ! -f ".env" ]; then
    cp .env.example .env
    log "${VERDE}Archivo .env creado a partir de .env.example.${NEUTRO}"
  else
    log "${AMARILLO}El archivo .env ya existe. No se ha sobrescrito.${NEUTRO}"
  fi
fi

log "${VERDE}Proceso completado con éxito.${NEUTRO}"
