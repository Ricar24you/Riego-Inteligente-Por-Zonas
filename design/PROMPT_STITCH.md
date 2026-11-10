# Exportación Google Stitch pendiente

No se dispone de integración autorizada de Stitch en este entorno. Abrir Google Stitch con la cuenta del usuario y usar este prompt:

> Diseña en español una aplicación responsive Riego Inteligente por Zonas para agricultura. Dashboard de 12 zonas con máximo 3 activas, bomba, consumo y cola priorizada; pantalla detalle de zona con tiempo restante y prioridad; historial de eventos y alertas de lluvia, fuga y válvula atascada. Ventana 22:00–06:00 UTC. Colores accesibles verde/ámbar/rojo, estados de conexión, móvil y escritorio. Identificar modo simulación. Exportar HTML, CSS, recursos y DESIGN.md.

Guardar exportación original y capturas de Stitch en `design/stitch/`, sin inventar DESIGN.md. Adaptar `priv/www/index.html` conservando identidad visual, con los contratos `/api/state`, POST `/api/programas`, POST `/api/signal` y `/ws`. Servir recursos locales adicionales con rutas cowboy_static restringidas al directorio exportado. Verificar formularios, alertas, detalle, reconexión y móvil; guardar capturas reales y procedencia de la exportación. El prototipo actual no sustituye esta evidencia.
