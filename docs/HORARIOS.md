# Zona local y ventana nocturna

Seleccionar la zona **antes de arrancar la VM**: `TZ=America/Tijuana rebar3 shell` o `TZ=America/Tijuana bash scripts/run-release.sh`. Sin TZ se usa `/etc/localtime`; la API indica «Sistema local». Se requiere tzdata instalado. `TZ` acepta nombres IANA presentes en `/usr/share/zoneinfo`; un nombre inexistente impide el arranque para evitar una caída silenciosa a UTC. No se cambia TZ mientras se ejecuta la VM.

Configuración OTP (config/sys.config para release):

```erlang
{schedule, #{timezone => local, start_hour => 22, duration_hours => 8}}
```

`timezone` permite `local` o `utc`, inicio de 0 a 23 y duración entera de 1 a 8 horas. Para shell, usar `application:load(riego), application:set_env(riego,schedule,Config)` **antes** de `application:ensure_all_started(riego)` si se desea un horario distinto. `rebar3 shell` inicia la aplicación con los valores por defecto; config/sys.config corresponde a la release.

Se inicia una ventana diaria en la hora civil y se añaden horas reales. Esto conserva el límite hidráulico/energético de ocho horas incluso cuando cambia la zona de UTC-8 a UTC-7. Con inicio a las 22:00, una noche normal termina a las 06:00; el cambio de primavera termina a las 07:00 y el de otoño a las 05:00. En una hora de inicio repetida se toma la primera ocurrencia; si la hora de inicio no existe ese día, se omite esa ventana y se conservan los trabajos para la siguiente. No se inventa una hora sustituta.

Los trabajos cuyo tiempo restante excede el final se difieren. Un reinicio conserva cola y bloqueos, pero utiliza la configuración actual. La comprobación de discrepancias de reloj sigue comparando UTC civil contra tiempo monotónico; un cambio DST normal no es un salto de reloj UTC y no dispara esa alarma.

La UI muestra `schedule.start_hour`, `duration_hours` y `timezone_name` de `/api/state`. `remaining_seconds` indica tiempo hasta fin de la ventana activa, o cero fuera de ella. Las fechas de bitácora se conservan como epoch UTC y se muestran ISO para mantener trazabilidad.

Verificación reproducible: `python3 scripts/timezone-checks.py`. Inicia VMs con TZ=UTC y TZ=America/Tijuana y comprueba 21 límites: invierno/verano, medianoche, las dos transiciones DST de 2026 y horas repetidas/inexistentes.
