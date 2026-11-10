const {chromium}=require('playwright');
if (!process.env.RIEGO_BASE_URL || !process.env.RIEGO_TEST_DATA_DIR?.startsWith('/tmp/riego-integration.')) throw Error('Run only via RIEGO_BROWSER_TEST=1 bash scripts/integration.sh with temporary data');
(async()=>{
 const fs=require('fs');fs.mkdirSync('docs/evidence-stitch',{recursive:true});
 const b=await chromium.launch({executablePath:process.env.CHROMIUM_PATH||'/usr/bin/chromium',headless:true,args:['--no-sandbox','--disable-dev-shm-usage']});
 try {
  const p=await b.newPage({viewport:{width:1365,height:1000}}), errors=[];
  p.on('pageerror',e=>errors.push(e.message));
  await p.goto(process.env.RIEGO_BASE_URL);await p.getByText('En línea',{exact:true}).waitFor();
  await p.waitForFunction(()=>document.querySelectorAll('.zone').length===12);
  await p.locator('nav a[href="#programacion"]').click();
  await p.selectOption('#zone','3');await p.locator('#duration').fill('120');
  await p.getByRole('button',{name:'Agregar a cola',exact:true}).click();await p.getByText('Solicitud aceptada',{exact:true}).waitFor();
  await p.waitForFunction(()=>document.getElementById('queue').textContent.includes('Zona Z-03'));
  await p.getByRole('button',{name:'Agregar a cola',exact:true}).click();await p.getByText('La zona ya tiene un trabajo',{exact:false}).waitFor();
  await p.locator('nav a[href="#detalle"]').click();await p.locator('#stuck').click();
  await p.getByRole('heading',{name:'Zona Z-03 · ATORADA ABIERTA',exact:true}).waitFor();
  await p.locator('#reset').click();await p.getByText('repair_required',{exact:false}).waitFor();
  await p.locator('nav a[href="#dashboard"]').click();
  if(await p.locator('.zone').count()!==12)throw Error('Expected 12 zones');
  await p.screenshot({path:'docs/evidence-stitch/desktop.png',fullPage:true});
  for(const width of [390,768]) {
   await p.setViewportSize({width,height:844});
   for(const view of ['dashboard','zonas','programacion','detalle','historial']) {
    await p.locator(`nav a[href="#${view}"]`).click();
    await p.getByRole('heading',{name:{dashboard:'Dashboard General',zonas:'Administración de Zonas',programacion:'Programación de Riego',detalle:'Detalle de Zona',historial:'Historial de Eventos'}[view],level:1}).waitFor();
    if(await p.evaluate(()=>document.documentElement.scrollWidth>innerWidth)) throw Error(`Overflow ${view} at ${width}`);
    if(width===390) await p.screenshot({path:`docs/evidence-stitch/mobile-${view}.png`,fullPage:true});
   }
  }
  await p.locator('#repair').click();await p.waitForFunction(()=>!document.getElementById('zones').textContent.includes('ATORADA ABIERTA'));
  await p.locator('#reset').click();await p.getByText('Solicitud aceptada',{exact:true}).waitFor();
  await p.locator('#rain').click();await p.getByRole('button',{name:'Desactivar lluvia',exact:true}).waitFor();
  await p.context().setOffline(true);await p.waitForTimeout(7500);
  if(!await p.locator('#stuck').isDisabled()) throw Error('Stale controls must be disabled');
  await p.context().setOffline(false);await p.waitForFunction(()=>!document.getElementById('stuck').disabled,{},{timeout:15000});
  if(errors.length)throw Error(errors.join('\n'));
  console.log('PASS: five routes, real API form/busy error, 12 zones, stuck/repair/reset, rain, desktop/mobile/tablet without overflow, stale controls, reconnect, no JS errors');
 } finally {await b.close();}
})().catch(e=>{console.error(e);process.exit(1)});
