'use strict';
const el = id => document.getElementById(id);
const titles = {dashboard:'Dashboard General',zonas:'Administración de Zonas',programacion:'Programación de Riego',detalle:'Detalle de Zona',historial:'Historial de Eventos'};
let state = null, received = 0, pending = false, socket, reconnectTimer, pollPending = false;
const zoneName = z => `Zona Z-${String(z).padStart(2,'0')}`;
for (const id of ['zone','detail-zone','signal-zone']) {
  for (let z=1; z<=12; z++) el(id).add(new Option(zoneName(z), z));
}
function selectZone(z) { for (const id of ['zone','detail-zone','signal-zone']) el(id).value = String(z); if(state) renderDetail(); }
for (const id of ['zone','detail-zone','signal-zone']) el(id).addEventListener('change', () => selectZone(el(id).value));
function navigate() {
  const view = location.hash.slice(1) || 'dashboard';
  const current = Object.hasOwn(titles,view) ? view : 'dashboard';
  document.querySelectorAll('[data-views]').forEach(node => { node.hidden = !node.dataset.views.split(' ').includes(current); });
  document.querySelectorAll('nav a').forEach(a => { if(a.hash === '#'+current) a.setAttribute('aria-current','page'); else a.removeAttribute('aria-current'); });
  el('title').textContent = titles[current];
  document.title = `${titles[current]} · AgroFlow IoT`;
}
addEventListener('hashchange',navigate); navigate();
function controls() {
  const fresh = state && Date.now()-received < 6000;
  document.querySelectorAll('[data-command]').forEach(b => { b.disabled = !fresh || pending; });
  el('notice').textContent = !fresh ? 'Sin estado reciente. Los controles están deshabilitados; los últimos valores pueden estar desactualizados.' : socket?.readyState === WebSocket.OPEN ? 'Estado en vivo · WebSocket cada segundo · simulación académica sin GPIO.' : 'WebSocket desconectado. Consulta HTTP de respaldo cada 3 segundos.';
}
function accept(s) {
  if (!s || !Array.isArray(s.valves) || s.valves.length !== 12 || !Array.isArray(s.active) || !Array.isArray(s.queue) || !Array.isArray(s.events) || !s.schedule || !Array.isArray(s.stuck)) throw Error('Estado incompatible con la API');
  state = s; received = Date.now();
  el('connection').textContent = socket?.readyState === WebSocket.OPEN ? 'En línea' : 'En línea por HTTP';
  render(); controls();
}
async function refresh() {
  if(pollPending) return;
  pollPending = true;
  const abort = new AbortController(), timeout = setTimeout(()=>abort.abort(),4000);
  try {const r = await fetch('/api/state',{cache:'no-store',signal:abort.signal}); if(!r.ok) throw Error(`HTTP ${r.status}`); accept(await r.json());}
  catch(e) {el('connection').textContent = 'Sin conexión HTTP';}
  finally {clearTimeout(timeout);pollPending = false;controls();}
}
const errors = {busy:'La zona ya tiene un trabajo pendiente o activo (busy).',invalid_program:'Programa fuera de rango (invalid_program).',repair_required:'Repara todas las válvulas atoradas antes de restablecer (repair_required).',invalid_signal:'Señal no válida (invalid_signal).'};
async function post(path, body) {
  if(pending || !state || Date.now()-received>=6000) return;
  pending = true; controls(); el('message').textContent = 'Enviando solicitud…';
  const abort = new AbortController(), timeout = setTimeout(()=>abort.abort(),8000);
  try {
    const r = await fetch(path,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(body),signal:abort.signal});
    const j = await r.json();
    el('message').textContent = r.ok ? 'Solicitud aceptada' : errors[j.error] || `Solicitud rechazada: ${j.error || r.status}`;
    await refresh();
  } catch(e) {el('message').textContent = 'No se pudo confirmar la solicitud. Consulta el estado antes de repetirla.';}
  finally {clearTimeout(timeout);pending = false;controls();}
}
el('program').addEventListener('submit',e=>{e.preventDefault();if(el('program').reportValidity()) post('/api/programas',{zone:Number(el('zone').value),duration:Number(el('duration').value),priority:Number(el('priority').value)});});
const signal = (kind,value) => post('/api/signal',{kind,value});
el('rain').onclick = ()=>signal('rain',!state.rain);
el('stuck').onclick = ()=>signal('stuck',Number(el('signal-zone').value));
el('repair').onclick = ()=>signal('repair',Number(el('signal-zone').value));
el('reset').onclick = ()=>signal('reset',true);
el('leak').onclick = ()=>signal('flow',10);
function zoneInfo(z) {
  const valve = state.valves.find(v=>v.zone===z), active = state.active.find(j=>j.zone===z), queued = state.queue.find(j=>j.zone===z);
  const status = valve.physical === 'stuck_open' ? 'stuck' : active ? 'active' : queued ? 'queued' : 'closed';
  return {valve,active,queued,status,label:{stuck:'ATORADA ABIERTA',active:'REGANDO',queued:'EN COLA',closed:'CERRADA'}[status]};
}
function renderZones() {
  const nodes = [];
  for(let z=1;z<=12;z++) {
    const {valve,active,queued,status,label} = zoneInfo(z);
    if(el('zone-filter').value !== 'all' && el('zone-filter').value !== status) continue;
    const card = document.createElement('article'); card.className = `card zone ${status}`;
    // Only numeric zone identifiers and fixed backend enum mappings enter this template.
    card.innerHTML = `<div class="zone-head"><small>ZONA ${String(z).padStart(2,'0')}</small><span class="pill">${label}</span></div><h3>${zoneName(z)}</h3><div class="telemetry"></div><a href="#detalle">Inspeccionar zona →</a>`;
    card.querySelector('.telemetry').textContent = `Orden: ${valve.commanded} · Físico: ${valve.physical}${active ? ` · ${active.remaining} s restantes` : queued ? ` · ${queued.remaining} s pendientes · Prioridad ${queued.priority}` : ' · Sin trabajo pendiente'}`;
    card.querySelector('a').onclick = ()=>selectZone(z); nodes.push(card);
  }
  el('zones').replaceChildren(...nodes);
  if(!nodes.length) el('zones').textContent = 'Sin zonas en este estado.';
}
function renderDetail() {
  const z = Number(el('detail-zone').value), info = zoneInfo(z);
  const h = document.createElement('h3'); h.textContent = `${zoneName(z)} · ${info.label}`;
  const pre = document.createElement('pre'); pre.textContent = JSON.stringify({valve:info.valve,active:info.active || null,queued:info.queued || null},null,2);
  el('detail').replaceChildren(h,pre);
}
function renderEvents() {
  const filtered = state.events.filter(e=>el('event-filter').value==='all' || e.event===el('event-filter').value);
  el('events').replaceChildren(...filtered.map(e=>{const d=document.createElement('div');d.className='event';d.textContent=`${new Date(e.at*1000).toLocaleString()} · ${e.event}`;return d;}));
  if(!filtered.length) el('events').textContent = 'Sin eventos para este filtro.';
}
function render() {
  const s = state;
  el('updated').textContent = 'Recibido '+new Date(received).toLocaleTimeString();
  el('schedule').textContent = `Inicio ${String(s.schedule.start_hour).padStart(2,'0')}:00 · ${s.schedule.duration_hours} h reales · ${s.schedule.timezone_name}`;
  el('summary').textContent = s.schedule.remaining_seconds > 0 ? `Ventana activa · ${s.schedule.remaining_seconds} s disponibles` : 'Fuera de ventana · trabajos en espera';
  el('capacity').value=s.active.length;
  el('pump').textContent = s.pump ? 'ENCENDIDA' : 'DETENIDA';
  el('flow').textContent = `Caudal nominal simulado: ${s.flow_lps.toFixed(2)} L/s`;
  el('concurrency').textContent = `${s.active.length} / 3`;
  el('pending').textContent = `${s.queue.length} en cola · ${s.deferred} diferidos`;
  el('liters').textContent = `${s.liters.toFixed(1)} L`;
  el('completed').textContent = `${s.completed} trabajos completados · acumulado persistido, no total diario`;
  el('safety').textContent = [s.fault ? 'FALLO enclavado: bomba inhibida.' : 'Sin fallo enclavado.',s.rain ? 'Lluvia: riego suspendido.' : 'Sin lluvia simulada.',s.stuck.length ? `Atascos: ${s.stuck.map(zoneName).join(', ')}. Reparar y después reconocer.` : 'Sin válvulas atoradas.'].join(' ');
  el('safety').className = s.fault ? 'fault' : '';
  el('rain').textContent = s.rain ? 'Desactivar lluvia' : 'Activar lluvia';
  el('slots').replaceChildren(...Array.from({length:3},(_,i)=>{const d=document.createElement('span'), j=s.active[i];d.textContent=`Slot ${i+1}: ${j ? `${zoneName(j.zone)} · ${j.remaining} s` : 'Disponible'}`;return d;}));
  el('queue').replaceChildren(...[...s.queue].sort((a,b)=>a.priority-b.priority || a.id-b.id).map(j=>{const tr=document.createElement('tr');for(const v of [j.id,zoneName(j.zone),j.remaining+' s',j.priority]){const td=document.createElement('td');td.textContent=v;tr.append(td);}return tr;}));
  if(!s.queue.length) {const tr=document.createElement('tr'),td=document.createElement('td');td.colSpan=4;td.textContent='Sin trabajos en cola';tr.append(td);el('queue').append(tr);}
  renderZones();renderDetail();renderEvents();
}
el('zone-filter').onchange = ()=>{if(state) renderZones();};
el('event-filter').onchange = ()=>{if(state) renderEvents();};
function connect() {
  clearTimeout(reconnectTimer);
  socket = new WebSocket(`${location.protocol==='https:'?'wss:':'ws:'}//${location.host}/ws`);
  socket.onopen=()=>{el('connection').textContent='En línea';controls();};
  socket.onmessage=e=>{try{accept(JSON.parse(e.data));}catch(error){el('connection').textContent='Estado WebSocket no válido';}};
  socket.onerror=()=>socket.close();
  socket.onclose=()=>{el('connection').textContent='WebSocket desconectado';controls();reconnectTimer=setTimeout(connect,2000);};
}
refresh();connect();
setInterval(()=>{controls();if(socket?.readyState!==WebSocket.OPEN || Date.now()-received>=6000) refresh();},3000);
