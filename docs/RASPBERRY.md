# Raspberry Pi 4 — Debian 13 ARM64

## Estado vigente para publicación

La compilación y el ensamblado de la release ARM64 se completaron después de los intentos restringidos descritos abajo. El usuario confirmó las cinco pantallas AgroFlow desde Windows. Las 17 pruebas EUnit y la integración HTTP/WebSocket aprobadas tienen logs cloud conservados; no se atribuyen a la ejecución nativa de la release. Ver [resumen y evidencias](EVIDENCIA.md). Esta preparación no altera el servidor activo.

## Registro inicial al 10 de noviembre de 2026

Trabajo realizado en el checkout `/home/pi4/Riego-Inteligente-Por-Zonas`, rama `codex/riego-otp`. Hardware: Raspberry Pi 4 Model B Rev 1.4; Debian 13.5 aarch64, Git 2.47.3, OTP 27 / ERTS 15.2.7, rebar3 3.24.0. No se instalaron paquetes, no se modificó main ni otros proyectos y no se hizo push.

Se ejecutó `bash scripts/pi-build.sh` dos veces: ambos intentos se detuvieron al descargar Cowboy por imposibilidad de resolver github.com. `rebar3 release` quedó bloqueado por lo mismo. Este entorno también deniega crear sockets de loopback (EPERM) y la verificación de systemd (SO_PASSCRED). No se declara HTTP, WebSocket, release ni systemd aprobados en la Pi.

Sí se compiló todo `src/*.erl` con `erlc -Werror`, se aprobaron 15 pruebas EUnit del modelo/seguridad, 21 límites horarios y recuperación del controlador y 12 válvulas tras SIGKILL entre dos VMs ARM64. No son las 17 pruebas de aplicación completa ni una prueba de corte eléctrico. [Resultados y logs](EVIDENCIA.md).

## Completar desde una terminal normal de la Pi

Las herramientas ya existen; no hace falta instalar paquetes. Usar una terminal con red disponible y permisos de sockets, sin cambiar firewall, SSH ni VPN:

```bash
cd /home/pi4/Riego-Inteligente-Por-Zonas
git status --short --branch
# Confirmar codex/riego-otp antes de continuar.
bash scripts/pi-build.sh
```

El script rechaza otra arquitectura o rama, construye nativamente, ejecuta EUnit y horarios, ensambla release y prueba HTTP/WebSocket y recuperación tras SIGKILL con datos temporales. No usa sudo ni reinicia servicios. La release x86_64 de cloud no sirve en ARM64. No usar reset --hard ni sobrescribir cambios locales. Si falla la descarga, resolver conectividad desde esa terminal antes de repetir; no alterar las versiones fijadas en rebar.lock.

Tras completar el script, arrancar manualmente para usar el dashboard:

```bash
TZ=America/Tijuana bash scripts/run-release.sh
```

Mantener esa terminal abierta; Ctrl+C detiene el proceso. El listener es `127.0.0.1:8080` y los datos se guardan en `data/`. America/Tijuana es la zona prevista por la configuración del proyecto; cambiar TZ antes de arrancar si se necesita otra zona IANA. Desde otra terminal de la Pi comprobar:

```bash
curl -fsS http://127.0.0.1:8080/api/state
curl -fsS http://127.0.0.1:8080/metrics
```

## Systemd preparado, sin instalar

La unidad existente es `deploy/riego.service`, con usuario pi4, rutas de este checkout, launcher de la release, reinicio ante fallo y TZ America/Tijuana. Conserva `ProtectSystem=strict`, `ProtectHome=read-only`, `NoNewPrivileges` y escritura limitada a `data/`. Se creó `data/` con permisos 0700. No se copió nada a `/etc/systemd/system` ni se ejecutó daemon-reload, enable, start o restart.

Desde la terminal normal, repetir la validación sin instalación:

```bash
systemd-analyze verify deploy/riego.service
```

**Los siguientes comandos son únicamente el procedimiento preparado para cuando autorices instalarlo. No se han ejecutado.** Antes, completar las pruebas nativas, detener el arranque manual y revisar cualquier unidad riego existente; no sobrescribirla sin revisión.

```bash
sudo install -m 644 deploy/riego.service /etc/systemd/system/riego.service
sudo systemctl daemon-reload
sudo systemctl enable --now riego
systemctl status riego --no-pager
journalctl -u riego -n 50 --no-pager
curl -fsS http://127.0.0.1:8080/api/state
```

El arranque y reinicio bajo systemd y la persistencia después de un corte eléctrico siguen pendientes. Respaldar data antes de actualizar y verificar reloj/zona con timedatectl.

## Abrir el dashboard desde Windows

Primero completar build y arrancar manualmente (o usar systemd una vez autorizado e instalado). En PowerShell, con el cliente OpenSSH y la autenticación SSH habitual:

```powershell
ssh -N -L 8080:127.0.0.1:8080 pi4@raspberrypi.local
```

Mantener PowerShell abierto y visitar **http://localhost:8080** en el navegador de Windows. Si raspberrypi.local no resuelve, sustituirlo por la IP real de la Pi, consultada con `hostname -I` en una terminal normal de la Pi. El destino Tailscale previamente documentado era `pi4@100.93.156.85`; usarlo solo si sigue correspondiendo a esta Pi y Windows ya está en el tailnet autorizado. No se verificó esa dirección desde esta sesión.

Si Windows tiene ocupado el puerto 8080, usar `ssh -N -L 18080:127.0.0.1:8080 pi4@raspberrypi.local` y abrir http://localhost:18080. El servidor permanece en loopback; el acceso se realiza por el túnel SSH sin exponerlo a LAN o Internet.
