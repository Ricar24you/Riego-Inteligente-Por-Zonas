# Evidencias reales — codex/riego-otp

## Estado preparado para publicación — 10 de noviembre de 2026

Entrega preparada exclusivamente en `codex/riego-otp`, sin push, sin modificar `main` ni operar sobre el servidor activo. Este resumen prevalece sobre los pendientes históricos de abajo; los logs originales se conservan sin editar.

| Avance confirmado | Evidencia y alcance |
|---|---|
| **17 pruebas EUnit, 0 fallos** | [Log de la suite completa](evidence-v2/eunit.log), ejecución histórica cloud. No confundir con el intento ARM64 restringido que registra 15 aprobadas y dos errores de sockets. |
| **Integración HTTP/WebSocket aprobada** | [Log de integración y release cloud](evidence-v2/release.log): HTML, programas, lluvia, fuga, métricas, enclavamiento, reparación, horario local y estado WS; también recuperación de VM tras SIGKILL. |
| **Release ARM64 ensamblada** | [Compilación](evidence-stitch/compile.log), [ensamblado](evidence-stitch/release.log) y [entorno aarch64](evidence-pi/environment.log). El ensamblado no acredita ejecución HTTP/WS de esa release. |
| **Cinco pantallas funcionando desde Windows** | Confirmación manual del usuario comunicada para esta entrega: dashboard general, administración de zonas, programación de riego, detalle de zona e historial de eventos. No se adjuntaron capturas nuevas de Windows ni se atribuye esta comprobación a Playwright. |
| Integridad y comprobaciones de preparación | Verificados los 12 archivos del [manifiesto SHA-256](evidence-stitch/originals.sha256), IDs HTML únicos, recursos locales y sintaxis JavaScript con `scripts/check-ui.py`. No requieren arrancar ni modificar el servicio. |

La integración conserva el ZIP original, los cinco `code.html`, sus cinco `screen.png` y `agrotech_precision/DESIGN.md` bajo `design/stitch/`. La tabla de trazabilidad de la sección siguiente describe cómo se adaptó cada pantalla a las API reales. Las capturas originales son referencias de diseño; la confirmación de Windows corresponde a la interfaz integrada.

La preparación excluye `CODEX_TAREA.txt`, credenciales, `_build/`, volcados y `data/`. No regenera ni instala HTML en el servidor activo, no arranca pruebas contra sus datos y no instala o reinicia servicios. Permanecen pendientes las pruebas automatizadas de la nueva interfaz en navegador, la ejecución HTTP/WS de la release ARM64, systemd y la durabilidad ante corte eléctrico real.

## Integración Google Stitch — 10 de noviembre de 2026 (registro de implementación)

Esta sección actualiza los pendientes de interfaz y build de las revisiones anteriores, que se conservan abajo como evidencia histórica. Trabajo exclusivamente en `codex/riego-otp`, sin push. Se conservaron los cambios locales previos en este documento, `docs/RASPBERRY.md`, `scripts/timezone-checks.py`, `CODEX_TAREA.txt`, `docs/evidence-pi/` y la exportación original.

Se inspeccionaron los cinco `code.html` completos, los estilos embebidos, las referencias externas y las cinco `screen.png` de `design/stitch/stitch_riego_inteligente_iot_dashboard/`. No hay CSS o fuentes locales separados en la exportación: usa Tailwind CDN, Google Fonts e imágenes remotas. Los originales no se editaron; [manifest SHA-256](evidence-stitch/originals.sha256). Las capturas Stitch son referencias del diseño, no capturas del resultado integrado.

| Pantalla original | Integración entregada |
|---|---|
| Dashboard general | Marca AgroFlow, banner oscuro, cuatro KPI, matriz de 12 tarjetas, simulación y terminal de eventos |
| Administración de zonas | Filtros reales de regando/cola/atascos/cerradas; selección compartida de zona |
| Programación de riego | Tres slots activos, cola por prioridad/FIFO y formulario POST de trabajo único |
| Detalle de zona | Estado físico, orden, trabajo activo y pendiente de la zona seleccionada |
| Historial de eventos | Bitácora cronológica del backend, filtro por tipo y controles de reparación/reconocimiento |

Se mantienen los colores Stitch `#006948`, `#006398`, `#6b38d4`, `#213145`, `#f8f9ff`, tarjetas redondeadas y superficies azul pálido. La navegación por hash permite recargar y usar atrás/adelante; tiene estilos para móvil y tablet, foco visible y mensajes de estado. Las fuentes de sistema sustituyen las fuentes remotas cuando no están instaladas. El isotipo se representa con un símbolo local; no se descargan imágenes de perfil ni se inventa un usuario autenticado.

Todos los valores dinámicos proceden de `/api/state` o `/ws`. Se usan los POST existentes para programas y señales. No se alteró ningún archivo Erlang ni lógica OTP. `index.html` incluye CSS y JS para funcionar con la ruta `/` actual sin reiniciar Cowboy; fuentes en `shell.html`, `app.css` y `app.js`, regeneración con `scripts/package-ui.py`. Incluye `wss` bajo HTTPS, reconexión, respaldo HTTP y bloqueo de comandos ante estado antiguo. No reintenta automáticamente órdenes cuyo resultado no pudo confirmarse.

No se conservan como si fueran reales los sensores, cultivos, PID, presión, telemetría LoRa, ahorros, tickets, disponibilidad ni gráficos de ejemplo del diseño. La API no los ofrece. No se implementa programación recurrente, modificación de ventana, pausa/cierre individual ni calibración: la API actual no tiene esas órdenes. La fuga se inyecta como `flow=10`; solo dispara protección si no hay trabajos activos, según el modelo existente. Reparar no reconoce el fallo. La bitácora no permite atribuir eventos a zonas porque el backend solo entrega tipo y fecha.

| Verificación ejecutada en esta revisión ARM64 | Resultado real |
|---|---|
| `rebar3 compile` | **Aprobado**, dependencias ya disponibles localmente. [Log](evidence-stitch/compile.log). |
| `rebar3 release` | **Release ARM64 ensamblada**, sin arrancarla contra datos persistentes. [Log](evidence-stitch/release.log). No equivale a validación de su ejecución HTTP. |
| `TZ=America/Tijuana rebar3 eunit` | **17 pruebas: 15 pasan y 2 fallan** al arrancar Cowboy por `listen_error,eperm` en puerto temporal 0. [Log](evidence-stitch/eunit.log). No se reporta suite completa aprobada. |
| EUnit solo modelo y seguridad | **15 pruebas, 0 fallos**. [Log](evidence-stitch/core-eunit.log). |
| `python3 scripts/timezone-checks.py` | **21 comprobaciones aprobadas**. [Log](evidence-stitch/timezones.log). |
| `python3 scripts/check-ui.py` | IDs HTML únicos, recursos fuente presentes y sintaxis de `app.js`/`browser.cjs` aprobada mediante JavaScriptCore del sistema. [Log](evidence-stitch/ui-static.log). No ejecuta DOM ni renderiza. |
| `python3 scripts/package-ui.py` | Página autocontenida generada en `priv/www/index.html` y `_build/ui/index.html`. [Log](evidence-stitch/package.log). |
| `bash scripts/integration.sh` | **Bloqueada** por `PermissionError: EPERM` al crear socket para seleccionar un puerto; no llegó a arrancar servidor ni enviar HTTP/WS. [Log](evidence-stitch/http-websocket.log). |
| Navegador / visualización móvil | **No ejecutados**: no hay Node, Chromium, Playwright ni Selenium disponibles. [Diagnóstico](evidence-stitch/browser-environment.log). No se generaron capturas nuevas ni se afirma ausencia de overflow comprobada en navegador. |

Se actualizaron las pruebas preparadas HTTP para verificar la página AgroFlow y recursos embebidos. La prueba Playwright recorre las cinco vistas a 390 y 768 px, verifica 12 zonas, formulario/error busy, atasco/reparación/reconocimiento, lluvia, desconexión/reconexión y controles bloqueados; guarda futuras capturas en `docs/evidence-stitch/` sin sobrescribir `docs/dashboard.png`, `docs/mobile.png` ni originales Stitch. Solo se permite ejecutarla con el entorno temporal del script de integración.

No se detuvo ni reinició el servidor activo, no se enviaron señales contra él y no se alteraron sus datos persistentes. Las pruebas EUnit usan otra VM y directorios temporales. No se ejecutaron comandos systemd ni se instaló la página en una release activa. El [procedimiento de despliegue y reversión solo de HTML](DESPLIEGUE_UI.md) permite entregar la interfaz sin reiniciar OTP; su comprobación en navegador queda pendiente en una terminal sin estas restricciones.

---

Las secciones siguientes registran resultados anteriores; sus pendientes de Stitch y descarga/release se sustituyen por la revisión actual de arriba.



## Validación nativa Raspberry Pi — 10 de noviembre de 2026

Ejecutada en `/home/pi4/Riego-Inteligente-Por-Zonas`, rama `codex/riego-otp`, commit base `1d8c23574505b8b5ace77ea2a9d39cbd62c53f2b` con los cambios de esta revisión sin commit. Hardware reportado por device tree: Raspberry Pi 4 Model B Rev 1.4; Debian 13.5 aarch64. Git 2.47.3, Erlang/OTP 27 (ERTS 15.2.7), rebar3 3.24.0. [Entorno](evidence-pi/environment.log).

| Comprobación real | Resultado |
|---|---|
| `bash scripts/pi-build.sh`, dos intentos | Bloqueado al descargar Cowboy: DNS de github.com no disponible. [Inicial](evidence-pi/pi-build-initial.log), [repetición](evidence-pi/pi-build-retry.log). No completó compile/EUnit/release/integración. |
| Compilación directa `erlc -Werror +debug_info -o _build/default/lib/riego/ebin src/*.erl` | Todos los módulos de la aplicación compilan en ARM64, sin avisos. No sustituye compilación de dependencias con rebar3. [Salida vacía, éxito](evidence-pi/erlc.log). |
| EUnit directo, módulos `riego_model_tests` y `riego_safety_tests` | **15 pruebas, 0 fallos**. Compilados con erlc y ejecutados mediante `eunit:test/2`, TZ America/Tijuana. Las dos pruebas de `riego_otp_tests` requieren la aplicación con Cowboy y no se ejecutaron aquí. [Salida](evidence-pi/core-eunit.log). |
| `python3 scripts/timezone-checks.py` | **21 límites horarios aprobados** en VMs ARM64. Se reemplazó la codificación JSX por `io:format("~w",[R])` para imprimir la lista de enteros sin dependencia externa. [Salida](evidence-pi/timezones.log). |
| Recuperación del núcleo entre dos VMs tras SIGKILL | Aprobada: controlador y 12 procesos de válvula, checkpoint temporal, atasco zona 1, programa zona 2 en cola, bomba inhibida, reparación y reconocimiento. Excluye supervisor completo, servidor HTTP y release. [Salida](evidence-pi/core-recovery.log). |
| HTTP y WebSocket | **No verificados en Pi**. `socket.bind` a loopback devuelve EPERM y GET local también está bloqueado; no hay servidor arrancado por estas pruebas. [Diagnóstico](evidence-pi/network.log). |
| `rebar3 release` | Bloqueado por la misma descarga de dependencias. No existe release ARM64 validada. [Salida](evidence-pi/release.log). |
| `systemd-analyze verify deploy/riego.service` | No pudo validar: `SO_PASSCRED failed: Operation not permitted`. [Salida](evidence-pi/systemd-verify.log). |

`deploy/riego.service` y el launcher quedan preparados; se creó únicamente `data/` local con permisos 0700. No se instaló, activó ni reinició systemd. No se modificó main, otros proyectos ni CODEX_TAREA.txt; no se hizo push. Las restricciones del entorno impiden completar red y servicio desde esta sesión; los comandos para repetir desde una terminal de la Pi constan en [RASPBERRY.md](RASPBERRY.md).

## Evidencia histórica de cloud (no equivale a resultados de la Pi)

Validación local del 10 de noviembre de 2026, sobre el proyecto existente. La rama main no se modifica. No se asigna calificación ni se afirma cumplimiento 40/40.

## Comprobaciones de esta revisión

| Comprobación ejecutada | Resultado y archivo |
|---|---|
| `rebar3 compile` | Aprobado: [compile.log](evidence-v2/compile.log) |
| `TZ=America/Tijuana rebar3 eunit` | **17 pruebas, 0 fallos**: [eunit.log](evidence-v2/eunit.log) |
| `python3 scripts/timezone-checks.py` | **21 límites horarios aprobados**: [timezones.log](evidence-v2/timezones.log) |
| Integración aislada con navegador | HTML, programa, lluvia, fuga, métricas, WebSocket y formulario aprobados; 12 zonas, zona efectiva, reparación y reconocimiento, móvil sin overflow, sin errores JS: [browser.log](evidence-v2/browser.log) |
| `RIEGO_RELEASE_TEST=1 bash scripts/integration.sh` | Release x86_64 ensamblada y arrancada; pruebas HTTP/WebSocket aprobadas: [release.log](evidence-v2/release.log) |
| SIGKILL de VM completa y arranque de otra | Conserva atasco, cola, orden de cierre y bomba inhibida, tanto en desarrollo como en release: logs browser/release |
| `bash scripts/pi-build.sh` en cloud x86_64 | Rechazo esperado por arquitectura; no equivale a ejecución ARM64 |
| `systemd-analyze verify deploy/riego.service` | No completado: `/run/systemd` de solo lectura en cloud; no se declara validación de systemd |

Los avisos «Source code not found» al ensamblar la release corresponden a paquetes OTP binarios sin fuentes de biblioteca, no a errores de compilación de la aplicación. `validation.log` conserva la evidencia histórica de la primera iteración (11 pruebas), no sustituye los resultados actuales.

Capturas reales renovadas: [escritorio](dashboard.png) y [móvil](mobile.png), con `America/Tijuana` y una válvula atorada ABIERTA. Son capturas del prototipo funcional; no evidencias de origen Google Stitch.

## Qué cambió y qué demuestra

- `riego_schedule` usa la zona local del sistema o TZ IANA seleccionada antes del arranque. Inicio y duración son configurables. Conserva ocho horas reales al cruzar DST; pruebas para UTC, invierno/verano en Tijuana, medianoche, hora repetida e inexistente. Ver [HORARIOS.md](HORARIOS.md).
- La válvula conserva el estado `stuck_open` ante órdenes normales de cierre. `stuck` registra las zonas y bloquea `pump`. La API diferencia `commanded` de `physical`, informa `flow_lps` y expone métricas de atasco/bomba. `reset` rechaza con `repair_required` hasta ejecutar `repair` para cada zona. Reparar no reconoce la alarma automáticamente.
- La prueba OTP arranca un riego activo, inyecta atasco y mata controlador/actuador; también detiene y arranca la aplicación. Conserva el enclavamiento y solo reanuda después de reparación y reconocimiento.
- La prueba de integración mata la VM completa con SIGKILL y arranca otra usando el mismo checkpoint. Se cargan explícitamente los módulos que definen átomos persistidos antes de `binary_to_term(...,[safe])`, para que el arranque en VM nueva pueda decodificar el estado sin permitir átomos arbitrarios.
- El launcher `scripts/run-release.sh` usa el runtime empaquetado sin distribución Erlang ni cookie; systemd gestiona el proceso. `cloud-release.sh` conserva el comando anterior como alias. La release se probó localmente con datos temporales y puerto disponible.

Estos fallos de procesos **no son un corte físico de alimentación**. La escritura usa sync y rename pero no fsync del directorio; la durabilidad frente a pérdida eléctrica real sigue pendiente de verificación en Pi. El simulador asume bomba como única fuente de presión: una válvula atascada abierta no recibe caudal si la bomba está apagada. No modela gravedad, presión residual ni GPIO reales.

## Dependencias externas verificadas y pendientes

| Requisito | Observación actual y siguiente acción |
|---|---|
| Raspberry Pi ARM64 (histórico cloud; ver resultados nativos arriba) | Runtime cloud reporta `vpn_configured=false`, `automatic_tailscale_access=false`, sin concesiones TCP. No hay ruta Tailscale configurada; no se probó SSH a la Pi por un tailnet funcional. Habilitar la integración de red del entorno o ejecutar los scripts desde un equipo ya autorizado en Tailscale. [Preflight y despliegue](RASPBERRY.md) preparados. |
| Google Stitch | Revisados `design/` y adjuntos: solo prompt y petición original; no hay exportación HTML/CSS/recursos/DESIGN.md. No hay herramienta Stitch disponible. Incorporar la exportación original manteniendo identidad visual y repetir navegador/capturas; no se inventó evidencia. |
| Gist existente | `gh api gists/9740fa1b1d2fc8c5bb5ef4c49f09ca7e` devuelve Forbidden. Una conexión HTTPS nueva a `api.github.com` falla antes de acceder al servicio: proxy CONNECT 403. No demuestra por sí sola falta de permiso de edición en GitHub. Se necesita permitir `api.github.com` en la red del entorno y después comprobar autenticación/autorización existente. No se solicitó ni almacenó token. [Manual actualizado](MANUAL.md) listo para el Gist autorizado; no publicado. |
| GitHub Actions | Workflow actualizado con EUnit, horarios, release e integración aislada. Su ejecución alojada no está confirmada; acceso API bloqueado. |
| Publicación cloud | El guardado de configuración de la iteración previa falló con INVALID_ARGUMENT; no se afirma borrador persistido ni publicación/restauración. Instrucciones y scripts quedan versionados. |

El Git HTTPS nativo y los commits de la rama de trabajo no requieren pedir otro token. No se reescriben orígenes, no se altera main, no se modifican controles SSH, VPN o firewall de la Pi.

## Matriz de rúbrica

Erlang, concurrencia, persistencia, API/UI y pruebas se verificaron localmente. La ejecución nativa parcial se documenta arriba; La ejecución HTTP/WebSocket de la release en Pi, la publicación en Gist y la exposición final siguen pendientes. El origen Stitch ya se conserva y las cinco pantallas integradas fueron confirmadas por el usuario desde Windows; ver el resumen vigente al inicio. Manual, arquitectura, guion y procedimiento de despliegue están preparados. Las métricas de litros siguen siendo estimadas; no hay sensores físicos ni programación recurrente. Las limitaciones se declaran y no se cuentan como criterios aprobados.
