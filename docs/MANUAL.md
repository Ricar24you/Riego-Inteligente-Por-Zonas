# Manual de usuario — Riego Inteligente por Zonas

## Inicio y programación

Arrancar con `rebar3 shell` desde el repositorio. Abrir el puerto local 8080 en el navegador; si está en Raspberry Pi, usar el túnel SSH descrito en README. Se muestran 12 zonas, capacidad y bitácora en tiempo real. La etiqueta superior identifica simulación.

Elegir zona, duración en segundos y prioridad: 0 es la más alta. Pulsar Agregar a cola. Una zona no puede tener dos trabajos pendientes. La cola se procesa desde las 22:00 de la zona local configurada durante ocho horas reales. Arrancar con `TZ=America/Tijuana rebar3 shell` o configurar TZ en el servicio. La cabecera muestra inicio, duración y zona efectiva. Normalmente cierra a las 06:00; durante el cambio de horario puede cerrar a las 05:00 o 07:00 para conservar ocho horas. Los horarios se configuran en `schedule` al arrancar, no desde el formulario. Los trabajos que no caben esperan otra ventana. El cuadro de cola muestra duración restante y prioridad.

## Alertas

Activar lluvia suspende todo; desactivarla permite reanudar dentro de ventana. Seleccionar una zona y pulsar Simular válvula atorada hace que permanezca ABIERTA aunque el controlador ordene cierre. La tarjeta lo muestra en rojo y la bomba se detiene. El estado persiste tras reinicios. Pulsar Restablecer antes de reparar devuelve `repair_required`. Seleccionar cada zona atorada y pulsar Reparar válvula elegida; esto cierra la válvula simulada pero conserva la alarma. Después pulsar Restablecer para permitir el riego. Simular fuga solo dispara si no hay trabajos activos; primero activar lluvia para demostrar caudal sin riego. Antes de restablecer, inspeccionar la causa; el botón reconoce el fallo simulado, no repara equipo. La lluvia permanece independiente del reconocimiento.

El indicador de conexión cambia cuando se pierde WebSocket y vuelve a conectar automáticamente. Si hay fallo de reloj, corregir sincronización del sistema antes de reconocer el fallo. La reparación es una acción del simulador; no ordena una reparación física real.

## Reinicio y datos

Los trabajos activos regresan a cola al reiniciar. No borrar `data/state.term` para resolver errores: conservar una copia y revisar el log. Detener el proceso antes de respaldar el directorio `data`.

## Alcance

Esta versión es un simulador, sin sensores GPIO ni actuadores físicos. Los litros son estimaciones a 0.1 L/s por zona. Nunca conectar directamente este software a una bomba real sin ingeniería adicional de seguridad.

## Publicación del manual

Destino autorizado: https://gist.github.com/Ricar24you/9740fa1b1d2fc8c5bb5ef4c49f09ca7e

Si existe acceso autorizado, ejecutar desde el repositorio:
`gh gist edit 9740fa1b1d2fc8c5bb5ef4c49f09ca7e -f MANUAL.md docs/MANUAL.md`

Primero comprobar el nombre existente con `gh gist view 9740fa1b1d2fc8c5bb5ef4c49f09ca7e --files` y sustituir MANUAL.md por el archivo destino si es distinto. No crear otro Gist. Alternativa: copiar íntegramente este Markdown al editor web del Gist existente.
