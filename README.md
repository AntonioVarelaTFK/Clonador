# Clonador de Repositorios Privados

Este script automatiza la clonación de repositorios privados de GitHub en servidores Ubuntu o Debian, con detección automática del entorno (Python o Node.js) e instalación de dependencias.

## 🚀 Instalación

### Opción 1: Instalación manual

1. Descarga el archivo `.deb` desde la sección de [Releases](https://github.com/antoniovarelaTFK/clonador/releases).
2. Instálalo con: sudo dpkg -i clonador.deb

### Opción 2: Instalación rápida por terminal

curl -L -o clonador.deb https://github.com/antoniovarelaTFK/clonador/releases/download/v1.0/clonador.deb && sudo dpkg -i clonador.deb

## ✅ Uso
Tras instalarlo, ejecuta: clonador

### El script te guiará paso a paso para:

1. Verificar herramientas (git, ssh).
2. Generar una clave SSH si no existe (puedes personalizar el nombre y el correo).
3. Comprobar conexión con GitHub.
4. Introducir la URL SSH del repositorio y la ruta destino.
5. Clonar el repositorio.
6. Detectar si es un proyecto Python o Node.js.
7. Instalar dependencias y crear .env si procede.

## 📝 Requisitos

1. Ubuntu/Debian con bash
2. Git y SSH instalados (o posibilidad de instalarlos con el script)
3. Acceso a repositorios privados por SSH

## 🛠 Autor
Antonio Varela
https://antoniovarela.es
