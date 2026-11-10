# Manual de usuario — Riego Inteligente por Zonas

## Inicio y programación

Arrancar con `rebar3 shell` desde el repositorio. Abrir el puerto local 8080 en el navegador; si está en Raspberry Pi, usar el túnel SSH descrito en README. Se muestran 12 zonas, capacidad y bitácora en tiempo real. La etiqueta superior identifica simulación.

Elegir zona, duración en segundos y prioridad: 0 es la más alta. Pulsar Agregar a cola. Una zona no puede tener dos trabajos pendientes. La cola se procesa de 22:00 a 06:00 UTC. Los trabajos que no caben esperan otra ventana. El cuadro de cola muestra duración restante y prioridad.

## Alertas

Activar lluvia suspende todo; desactivarla permite reanudar dentro de ventana. Simular válvula atorada activa fallo global. Simular fuga solo dispara si no hay trabajos activos; primero activar lluvia para demostrar caudal sin riego. Antes de restablecer, inspeccionar la causa; el botón reconoce el fallo simulado, no repara equipo. La lluvia permanece independiente del reconocimiento.

El indicador de conexión cambia cuando se pierde WebSocket y vuelve a conectar automáticamente. Si hay fallo de reloj, corregir sincronización del sistema antes de reconocer el fallo.

## Reinicio y datos

Los trabajos activos regresan a cola al reiniciar. No borrar `data/state.term` para resolver errores: conservar una copia y revisar el log. Detener el proceso antes de respaldar el directorio `data`.

## Alcance

Esta versión es un simulador, sin sensores GPIO ni actuadores físicos. Los litros son estimaciones a 0.1 L/s por zona. Nunca conectar directamente este software a una bomba real sin ingeniería adicional de seguridad.

## Publicación del manual

Destino autorizado: https://gist.github.com/Ricar24you/9740fa1b1d2fc8c5bb5ef4c49f09ca7e

Si existe acceso autorizado, ejecutar desde el repositorio:
`gh gist edit 9740fa1b1d2fc8c5bb5ef4c49f09ca7e -f MANUAL.md docs/MANUAL.md`

Primero comprobar el nombre existente con `gh gist view 9740fa1b1d2fc8c5bb5ef4c49f09ca7e --files` y sustituir MANUAL.md por el archivo destino si es distinto. No crear otro Gist. Alternativa: copiar íntegramente este Markdown al editor web del Gist existente.
