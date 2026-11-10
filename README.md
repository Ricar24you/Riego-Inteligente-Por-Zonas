# Riego Inteligente por Zonas

Simulador académico Erlang/OTP basado en el [enunciado del profesor](https://github.com/tectijuana/erlang-proyectos/tree/main/proyectos/03-riego-por-zonas). No controla GPIO ni una instalación hidráulica real.

## Ejecutar

Requiere Erlang/OTP 27 y rebar3 3.24. En Debian 13 / Raspberry Pi ARM64: `sudo apt-get install erlang rebar3`.

```sh
rebar3 compile
rebar3 eunit
TZ=America/Tijuana rebar3 shell
```

En este entorno cloud: `export PATH=/workspace/tooling/bin:$PATH REBAR_CACHE_DIR=/workspace/tooling/cache` antes de esos comandos. El servidor escucha exclusivamente en loopback, puerto 8080. En una máquina local abre el navegador en ese puerto. Desde la Pi utiliza un túnel SSH `ssh -L 8080:127.0.0.1:8080 pi4@100.93.156.85`.

## Capacidades

12 procesos `gen_statem`, controlador `gen_server`, supervisor `rest_for_one`, máximo tres trabajos activos, prioridad 0–9 y FIFO entre iguales. Ventana nocturna configurable: inicio **22:00 local**, duración **8 horas reales**. `TZ=America/Tijuana` selecciona la zona IANA al arrancar (o se usa la zona del sistema). Configuración OTP `schedule`: `#{timezone => local, start_hour => 22, duration_hours => 8}`; `timezone => utc` conserva el modo UTC. La UI muestra la zona efectiva. En cambios de horario el cierre local puede ser 05:00 o 07:00 para conservar ocho horas reales; ver [horarios](docs/HORARIOS.md). Duración en segundos, hasta ocho horas, un trabajo pendiente por zona. Los trabajos que no caben se difieren sin eliminarlos; los que sí caben pueden adelantarlos. No existe garantía contra inanición bajo envíos continuos de alta prioridad.

Lluvia pausa los trabajos. Una válvula atorada permanece físicamente abierta en el simulador aunque reciba orden de cierre; su zona queda persistida y la bomba se inhibe. Primero se requiere `repair` de cada zona y después `reset`; reconocer no repara. El caudal sin trabajo activo también bloquea el riego simulado. Se conserva la duración restante y se vuelve a cola tras reinicio. Saltos mayores de cinco segundos respecto del reloj monotónico bloquean el riego. La API rechaza entradas fuera de rango.

## API

| Método | Ruta | Contenido |
|---|---|---|
| GET | `/api/state`, `/api/programas`, `/api/valvulas` | Estado agregado (los alias devuelven el mismo esquema) |
| POST | `/api/programas` | `{"zone":1,"duration":60,"priority":0}` |
| POST | `/api/signal` | `{"kind":"rain","value":true}`; `stuck` y `repair`: zona 1–12; `flow`: litros/segundo; `reset`: true |
| GET | `/metrics` | Activos, completados, litros simulados, fallo, válvulas atoradas, bomba |
| WS | `/ws` | Estado JSON cada segundo |

POST requiere `Content-Type: application/json`. No exponer esta API de simulación a Internet sin autenticación/TLS. No hay integración física: caudal nominal simulado de 0.1 L/s por zona, lluvia y fallos se inyectan con controles.

## Validación y entrega

`bash scripts/integration.sh` arranca una instancia en puerto disponible y directorio temporal, ejecuta pruebas HTTP/WebSocket y la detiene al terminar. `RIEGO_RELEASE_TEST=1 bash scripts/integration.sh` verifica la release; `RIEGO_BROWSER_TEST=1` agrega pruebas de navegador si están Playwright/Chromium. `python3 scripts/timezone-checks.py` verifica UTC, Tijuana y horario de verano en VMs nuevas. No ejecutar `smoke.py` o `browser.cjs` directamente sobre datos del usuario. CI ejecuta EUnit, horarios, build y HTTP/WebSocket. La release ARM64 está ensamblada; ver [resultados nativos](docs/RASPBERRY.md) y el alcance de cada validación en [EVIDENCIA](docs/EVIDENCIA.md).

Ver [arquitectura](docs/ARQUITECTURA.md), [manual](docs/MANUAL.md), [Raspberry Pi](docs/RASPBERRY.md), [demostración](docs/DEMO.md) y [evidencia y pendientes](docs/EVIDENCIA.md). La interfaz AgroFlow adapta las cinco pantallas originales de Google Stitch conservadas en `design/stitch/stitch_riego_inteligente_iot_dashboard/`. Ver la trazabilidad y las limitaciones de verificación en [EVIDENCIA](docs/EVIDENCIA.md).


## Interfaz AgroFlow / Stitch

Navegación por enlaces: dashboard, administración de las 12 zonas, programación, detalle y bitácora. Responsive a móvil/tablet, con filtros de estado y eventos, selección de zona compartida y estados de conexión. Usa `GET /api/state`, los dos POST existentes y `/ws`; bajo HTTPS selecciona `wss`. HTTP sirve como respaldo cada tres segundos y los controles se bloquean tras seis segundos sin estado reciente. Los errores de API se muestran sin simular un éxito ni repetir automáticamente un POST.

Se conservan la marca, paleta, paneles, matriz y jerarquía del diseño exportado. CSS y JavaScript se sirven localmente, sin Tailwind CDN, imágenes remotas ni descargas obligatorias de fuentes. Las familias de Stitch están declaradas con fuentes de sistema como respaldo. No se muestran sensores, cultivos, PID, presión, ahorros ni gráficos ficticios. Litros y caudal son los valores simulados del backend; los litros son acumulados persistidos, no diarios. Programar agrega un trabajo único (1–28800 segundos, prioridad 0–9), no un horario recurrente. La lluvia es global; reparar y reconocer son acciones independientes. La bitácora solo contiene fecha y tipo porque ese es el esquema real.

Validación sin tocar el servicio activo:

```bash
python3 scripts/check-ui.py
rebar3 compile
TZ=America/Tijuana rebar3 eunit
RIEGO_BROWSER_TEST=1 bash scripts/integration.sh
```

El navegador necesita Node, Playwright y Chromium (`CHROMIUM_PATH` opcional). Sus capturas se guardan en `docs/evidence-stitch/`, preservando los originales Stitch y las capturas históricas. La evidencia conservada registra **17 pruebas EUnit aprobadas**, integración HTTP/WebSocket y recuperación tras SIGKILL en cloud; la compilación y el ensamblado de la release **ARM64** también pasaron. El usuario confirmó funcionando desde **Windows las cinco pantallas**: dashboard, zonas, programación, detalle e historial. Esta confirmación manual no sustituye una prueba automatizada móvil ni demuestra la ejecución HTTP de la release ARM64. Los intentos restringidos y sus logs se conservan en [EVIDENCIA](docs/EVIDENCIA.md).

La página `priv/www/index.html` es autocontenida. Tras editar `priv/www/shell.html`, `app.css` o `app.js`, regenerarla con `python3 scripts/package-ui.py`; también produce `_build/ui/index.html`. Esta usa exclusivamente la ruta estática `/` que ya existe y las API/WS actuales. Consultar el [procedimiento seguro](docs/DESPLIEGUE_UI.md) antes de reemplazar el archivo servido. No se realizó despliegue, reinicio ni push.
