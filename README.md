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

`bash scripts/integration.sh` arranca una instancia en puerto disponible y directorio temporal, ejecuta pruebas HTTP/WebSocket y la detiene al terminar. `RIEGO_RELEASE_TEST=1 bash scripts/integration.sh` verifica la release; `RIEGO_BROWSER_TEST=1` agrega pruebas de navegador si están Playwright/Chromium. `python3 scripts/timezone-checks.py` verifica UTC, Tijuana y horario de verano en VMs nuevas. No ejecutar `smoke.py` o `browser.cjs` directamente sobre datos del usuario. CI ejecuta EUnit, horarios, build y HTTP/WebSocket. La [verificación ARM64](docs/RASPBERRY.md) aún requiere acceso a la Pi.

Ver [arquitectura](docs/ARQUITECTURA.md), [manual](docs/MANUAL.md), [Raspberry Pi](docs/RASPBERRY.md), [demostración](docs/DEMO.md) y [evidencia y pendientes](docs/EVIDENCIA.md). La UI actual es un prototipo funcional; **no se declara creada en Stitch ni se afirma 40/40**.
