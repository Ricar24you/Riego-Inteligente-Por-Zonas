# Evidencias reales y pendientes — continuación de codex/riego-otp

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
| Raspberry Pi ARM64 | Runtime cloud reporta `vpn_configured=false`, `automatic_tailscale_access=false`, sin concesiones TCP. No hay ruta Tailscale configurada; no se probó SSH a la Pi por un tailnet funcional. Habilitar la integración de red del entorno o ejecutar los scripts desde un equipo ya autorizado en Tailscale. [Preflight y despliegue](RASPBERRY.md) preparados. |
| Google Stitch | Revisados `design/` y adjuntos: solo prompt y petición original; no hay exportación HTML/CSS/recursos/DESIGN.md. No hay herramienta Stitch disponible. Incorporar la exportación original manteniendo identidad visual y repetir navegador/capturas; no se inventó evidencia. |
| Gist existente | `gh api gists/9740fa1b1d2fc8c5bb5ef4c49f09ca7e` devuelve Forbidden. Una conexión HTTPS nueva a `api.github.com` falla antes de acceder al servicio: proxy CONNECT 403. No demuestra por sí sola falta de permiso de edición en GitHub. Se necesita permitir `api.github.com` en la red del entorno y después comprobar autenticación/autorización existente. No se solicitó ni almacenó token. [Manual actualizado](MANUAL.md) listo para el Gist autorizado; no publicado. |
| GitHub Actions | Workflow actualizado con EUnit, horarios, release e integración aislada. Su ejecución alojada no está confirmada; acceso API bloqueado. |
| Publicación cloud | El guardado de configuración de la iteración previa falló con INVALID_ARGUMENT; no se afirma borrador persistido ni publicación/restauración. Instrucciones y scripts quedan versionados. |

El Git HTTPS nativo y los commits de la rama de trabajo no requieren pedir otro token. No se reescriben orígenes, no se altera main, no se modifican controles SSH, VPN o firewall de la Pi.

## Matriz de rúbrica

Erlang, concurrencia, persistencia, API/UI y pruebas se verificaron localmente. La ejecución en la Pi, el origen Stitch, la publicación en Gist y la exposición final siguen pendientes de evidencia externa. Manual, arquitectura, guion y procedimiento de despliegue están preparados. Las métricas de litros siguen siendo estimadas; no hay sensores físicos ni programación recurrente. Las limitaciones se declaran y no se cuentan como criterios aprobados.
