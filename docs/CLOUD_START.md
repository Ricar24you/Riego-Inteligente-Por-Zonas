# Arranque cloud reutilizable

Usar checkout existente `/workspace/Riego-Inteligente-Por-Zonas`. Cada tarea ya está aislada; no crear worktree salvo petición explícita. No sobrescribir cambios del usuario.

Instalación: `bash scripts/cloud-install.sh` desde el checkout. Activa herramientas en cada terminal:

```sh
export PATH=/workspace/tooling/bin:$PATH
export REBAR_CACHE_DIR=/workspace/tooling/cache
cd /workspace/Riego-Inteligente-Por-Zonas
rebar3 compile
rebar3 eunit
rebar3 shell
```

Comprobar `/api/state` y `/metrics` con curl al puerto loopback 8080. Los procesos vivos no se conservan en snapshots. Para pruebas de integración arrancar con directorio nuevo desechable (sustituir UNIQUE cada vez):

```sh
erl -pa _build/default/lib/*/ebin -noshell -eval 'application:load(riego),application:set_env(riego,data_dir,"/tmp/riego-smoke-UNIQUE"),{ok,_}=application:ensure_all_started(riego),timer:sleep(infinity).'
```

En otra terminal ejecutar `python3 scripts/smoke.py` y opcionalmente `node scripts/browser.cjs` si están Playwright/Chromium. No ejecutar sobre datos del usuario. Detener únicamente los procesos iniciados para estas pruebas. La Pi requiere compilación ARM64, red y SSH aparte. Stitch y publicación Gist están pendientes.

Para ejecutar la release sin distribución Erlang ni cookies: `TZ=America/Tijuana bash scripts/run-release.sh` después de `rebar3 release`. El script obtiene la versión ERTS/release de start_erl.data y usa el runtime empaquetado. `RIEGO_SYS_CONFIG` permite un archivo sys.config externo; no guardar credenciales en él.

Validación aislada recomendada: `TZ=America/Tijuana bash scripts/integration.sh`; agregar `RIEGO_RELEASE_TEST=1` para probar la release y `RIEGO_BROWSER_TEST=1` para navegador con Playwright/Chromium. Selecciona un puerto disponible y limpia únicamente datos temporales. Las instrucciones anteriores que arrancan un servidor manual siguen disponibles, pero no son necesarias para estas pruebas.
