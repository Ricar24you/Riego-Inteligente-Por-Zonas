# Desplegar AgroFlow en la Raspberry Pi sin reiniciar OTP

El servicio actual no se ha detenido ni reiniciado. No se han enviado programas ni señales a esa instancia. No hay cambios Erlang: API, rutas, modelo, controlador, supervisor y válvulas permanecen intactos.

## Validar primero

Desde una terminal de la Pi que permita sockets, en `codex/riego-otp`, conservar los cambios locales y repetir:

```bash
rebar3 compile
TZ=America/Tijuana rebar3 eunit
RIEGO_BROWSER_TEST=1 bash scripts/integration.sh
RIEGO_RELEASE_TEST=1 bash scripts/integration.sh
python3 scripts/package-ui.py
```

La integración usa puerto libre y datos temporales, nunca `data/`. No ejecutar `smoke.py`, `restart-check.py` o `browser.cjs` apuntando al servidor activo. No arrancar otra instancia con el mismo directorio persistente. El estado vigente incluye 17 pruebas aprobadas e integración HTTP/WS en cloud, ensamblado ARM64 y confirmación manual de las cinco pantallas desde Windows. Las pruebas automatizadas de navegador de la nueva UI y HTTP/WS de la release ARM64 siguen pendientes; ver EVIDENCIA.md. Estos comandos son para una validación futura, sin operar sobre el servidor activo.

## Actualización solo de la interfaz

El empaquetador genera `priv/www/index.html` y `_build/ui/index.html` con CSS y JS incluidos, sin peticiones `/assets`. Las fuentes editables son `priv/www/shell.html`, `app.css` y `app.js`; regenerar después de editarlas. Se puede entregar mediante la ruta `/` del Cowboy ya arrancado, sin cargar código Erlang ni reiniciar. La API y el WebSocket siguen en el mismo origen.

1. Identificar el **directorio priv/www que realmente sirve el proceso actual**. En desarrollo suele corresponder a `priv/www`; en release es `lib/riego-0.1.0/priv/www` dentro de la release en ejecución. Verificar el WorkingDirectory/ExecStart y enlaces de esa instalación; no asumir que usa el checkout actual. No reconstruir encima de una release en ejecución.
2. Guardar una copia del `index.html` servido en un directorio de respaldos fuera del árbol público. Registrar ruta y hash. No copiar ni editar `data/state.term`; la actualización solo afecta HTML.
3. Copiar el nuevo HTML a un temporal **en el mismo directorio destino**, comprobar hash/permisos de lectura y renombrarlo a `index.html` de forma atómica. El proceso Cowboy lee el archivo estático en las siguientes peticiones. No tocar `.beam`, configuración, listeners ni systemd.
4. Abrir mediante el túnel SSH habitual y recargar sin caché. Consultar solo GET `/api/state` y `/metrics`; verificar 12 tarjetas, conexión, navegación y móvil. Los botones de simulación modifican el estado: probarlos solo en la instancia temporal.
5. Ante un problema, restaurar atómicamente el HTML respaldado y recargar. No hace falta reiniciar OTP y no se modifica la persistencia.

Los pasos de copia se ejecutan únicamente cuando se elija desplegar; esta sesión dejó el artefacto preparado y no los ejecutó. La release también incluye la página autocontenida. No se necesita actualizar el backend para utilizar esta interfaz.

## Acceso

Mantener el listener en loopback y el acceso por SSH:

```bash
ssh -N -L 18080:127.0.0.1:8080 pi4@raspberrypi.local
```

Abrir `http://localhost:18080`. Usar el host real de la Pi si es distinto. La interfaz usa `ws` o `wss` según el protocolo de la página. Si ya hay un proxy HTTPS, preservar el origen compatible con la validación POST de Cowboy; no se ha comprobado aquí un proxy ni TLS. Este cambio no configura exposición pública, autenticación ni GPIO.
