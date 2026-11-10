# Raspberry Pi 4 — Debian 13 ARM64

El despliegue se prepara sobre la rama `codex/riego-otp`, nunca main. **Ejecución ARM64 pendiente:** el entorno cloud observado no tiene Tailscale configurado ni concesiones TCP. No se atribuye a la Pi una respuesta obtenida desde una ruta sin VPN. No se han modificado su SSH, firewall o servicios.

## Verificación desde el tailnet autorizado

Desde un equipo ya conectado a Tailscale y con la clave de host verificada, ejecutar `bash scripts/pi-ssh-check.sh`. Es solo lectura, utiliza BatchMode, StrictHostKeyChecking y la autenticación SSH existente. Verifica aarch64, Debian, Erlang, rebar3, Python, curl, tzdata y checkout. Se puede pasar otro destino autorizado como primer argumento. Para este cloud, habilitar primero la integración Tailscale del entorno; no instalar otro cliente VPN dentro del contenedor ni desactivar claves de host. El transporte cloud raw TCP usa el CONNECT de la plataforma; una vez configurado, establecer la ruta según la skill runtime antes de ejecutar SSH.

## Preparación nativa

En la Pi, instalar solo si faltan paquetes: `sudo apt-get update` y `sudo apt-get install erlang rebar3 python3 curl tzdata`. Son operaciones administrativas por ejecutar localmente; no han sido ejecutadas por este trabajo.

Usar el checkout existente `/home/pi4/Riego-Inteligente-Por-Zonas` y la rama `codex/riego-otp`. Conservar modificaciones locales antes de cambiar de rama; no usar reset --hard ni sobrescribir proyectos. Con acceso disponible, traer los commits mediante Git autorizado. `bash scripts/pi-build.sh` rehúsa ejecutarse fuera de ARM64 o de esa rama, compila nativamente, ejecuta EUnit y los 21 checks horarios, construye release y verifica HTTP/WebSocket en una instancia aislada. No necesita sudo, no reinicia servicios y limpia únicamente su directorio temporal.

**No copiar la release x86_64 de cloud a ARM64.** Conservar salida de `uname -m`, `git rev-parse HEAD` y pruebas como evidencia real cuando se ejecute el script.

## Servicio systemd

Revisar rutas de `deploy/riego.service`. Crear `data` propiedad de pi4 con permisos privados. El servicio usa `scripts/run-release.sh`: arranca la release empaquetada sin distribución Erlang y sin cookies, con systemd encargado del ciclo de vida. Conserva `ProtectSystem=strict`, `ProtectHome=read-only` y únicamente `data` escribible. `Environment=TZ=America/Tijuana` selecciona la zona; revisar la configuración según HORARIOS.md.

Una vez confirmadas las pruebas nativas, copiar solo la unidad de este proyecto a `/etc/systemd/system/riego.service`, ejecutar `sudo systemctl daemon-reload` y `sudo systemctl enable --now riego`. No reemplazar una unidad existente sin revisarla ni tocar servicios ajenos. Confirmar `systemctl status riego`, `journalctl -u riego`, GET local `/api/state`, métricas y reinicio controlado. Verificar `timedatectl` y respaldar `data` antes de actualizar.

Acceder por túnel: `ssh -L 8080:127.0.0.1:8080 pi4@100.93.156.85`. El listener permanece en loopback, sin abrir LAN o Internet. En cloud no publicar enlaces de preview localhost.

Pendiente: preflight SSH en tailnet, ejecución nativa ARM64, instalación/arranque/reinicio real systemd y evidencia de la demostración en Pi. La comprobación systemd-analyze local no pudo completarse porque `/run/systemd` es de solo lectura; no se declara validada la unidad por ese comando.
