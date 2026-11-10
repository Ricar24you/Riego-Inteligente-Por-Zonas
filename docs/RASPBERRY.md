# Raspberry Pi 4 — Debian 13 ARM64

Despliegue preparado, todavía no ejecutado en la Pi. Habilitar primero conectividad Tailscale del entorno y SSH autorizado; nunca copiar claves al repositorio. Comprobar `ssh pi4@100.93.156.85 'uname -a; command -v erl rebar3'` con claves de host verificadas.

En la Pi, instalar `erlang rebar3` mediante APT firmado. Clonar el repositorio en `/home/pi4/Riego-Inteligente-Por-Zonas`; ejecutar `rebar3 compile`, `rebar3 eunit`, `rebar3 release`. **Compilar en ARM64**, no copiar la release x86_64 cloud. Crear directorio `data` propiedad de pi4.

Revisar rutas de `deploy/riego.service`, copiar esa unidad únicamente a `/etc/systemd/system/riego.service`, ejecutar `sudo systemctl daemon-reload` y `sudo systemctl enable --now riego`. No modificar servicios ajenos. Verificar `systemctl status riego`, `journalctl -u riego`, petición local `/api/state` y reinicio controlado del servicio. Estos pasos requieren autorización administrativa local; no se han ejecutado en este trabajo.

No cambiar firewall, ACL de Tailscale ni configuración SSH sin autorización. Acceder por túnel local; el listener HTTP no escucha en la LAN. Comprobar `timedatectl` y UTC. Respaldar `data` antes de actualizar.
