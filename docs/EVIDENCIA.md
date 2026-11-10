# Evidencias reales y límites

Validación local, 10 de noviembre de 2026. `docs/validation.log` contiene instalación local, compilación, EUnit y construcción de release. Avisos de fuentes OTP ausentes corresponden a paquetes binarios sin fuentes, no a errores de compilación. Las dependencias Cowboy/jsx/cowlib/ranch se obtuvieron de repositorios oficiales vía HTTPS con validación Git/TLS y commits fijados en rebar.lock. Hex falló por confianza CA; no se desactivó verificación y se eligieron fuentes Git oficiales.

- `rebar3 compile`: aprobado.
- `rebar3 eunit`: 11 pruebas, 0 fallos. Modelo: capacidad/prioridad, lluvia, completado, ventana, exceso, fallo/fuga, reloj, recuperación, validación y evolución temporal. OTP: reinicio de controlador y válvula, conservación de trabajo y fallo por fuga.
- `rebar3 release`: release x86_64 ensamblada. No constituye validación ARM64.
- `scripts/smoke.py`: HTML, alta de programa, lluvia, fuga, métricas y trama WebSocket reales aprobados en servidor con datos desechables. Repetir requiere directorio vacío porque crea un programa único por zona.
- `scripts/browser.cjs`: Chromium/Playwright real, formulario aceptado, 12 zonas, WebSocket conectado, vista móvil sin desbordamiento, sin errores JS. Capturas: `dashboard.png` y `mobile.png`. Requiere Playwright y Chromium; en cloud ya disponibles. Ejecutar con datos desechables, después de smoke.
- La prueba OTP mata procesos con trabajos en cola. Recuperación de activos se verifica en el modelo; **no se ha demostrado un corte físico de corriente ni caos con válvulas físicamente abiertas**.

| Criterio | Estado demostrado / pendiente |
|---|---|
| Erlang funcional | Núcleo y APIs verificados localmente; simulación, no GPIO |
| Entorno autorizado | Pi pendiente: VPN no configurada; SSH devuelve conexión rechazada |
| Demostración | Guion preparado; falta grabación/ejecución final en Pi |
| Google Stitch | Pendiente exportación original e integración; prototipo no cuenta como evidencia |
| Manual Gist | Markdown listo; API del Gist devuelve Forbidden; no publicado |
| Calidad | Pruebas y CI preparados; ejecución alojada de Actions todavía no confirmada |
| Integración | Navegador/API/WebSocket locales verificados; falta Pi/Stitch |
| Presentación | Arquitectura, supuestos y guion documentados; exposición pendiente |

No se asigna calificación ni se declara cumplimiento 40/40. La simulación de válvula atorada produce alarma y bloqueo de riego; no reproduce persistencia mecánica de una válvula física abierta. La bitácora es acotada y las métricas son estimadas. No hay programación recurrente ni modelo de presión.

## Configuración cloud

Instalación local repetida con éxito mediante `scripts/cloud-install.sh` (sin privilegios). Herramientas retenidas en `/workspace/tooling`. El backend rechazó dos lecturas del borrador y el guardado de install_script/start_skill con INVALID_ARGUMENT: **persistencia del borrador no confirmada**. No se afirma que el entorno esté publicado ni que una tarea nueva restaure la configuración. Las instrucciones completas quedan versionadas y en `docs/CLOUD_START.md`; guardar/publicar en ajustes cuando se resuelva el borrador.

Arranque final de release: verificado con VMARGS_PATH local privado para evitar la ruta home de solo lectura; sobre esa release `scripts/smoke.py` pasó HTTP y WebSocket. Quitar el nombre de nodo no es compatible con el script relx; se mantuvo y se aplicó el override de runtime. EUnit final repetido: 11 pruebas, 0 fallos.

Rama publicada en GitHub: `codex/riego-otp`. La rama main no se modificó. La ejecución de GitHub Actions alojada no se ha consultado con éxito.
