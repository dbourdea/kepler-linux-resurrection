import http from 'http';
import { chromium } from 'playwright';

let activeScrapes = 0;
const MAX_CONCURRENT_SCRAPES = 1;
const TARGET_URL = process.env.SCRAPE_TARGET_URL || 'https://eulerapp.com/starlink';
const PORT = process.env.PORT || 3000;

async function scrape(req, res) {
  if (activeScrapes >= MAX_CONCURRENT_SCRAPES) {
    res.writeHead(429, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: 'Server busy.' }));
  }

  activeScrapes++;
  let browser;
  try {
    browser = await chromium.launch({ args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'] });
    const page = await browser.newPage();
    
    // Resource blocking
    await page.route('**/*.{png,jpg,jpeg,gif,svg,css,woff,woff2,otf,ttf,ico}', r => r.abort());
    
    await page.goto(TARGET_URL, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await page.waitForTimeout(5000); // Allow Bubble to hydrate

    const vendors = await page.evaluate(() => {
      const items = Array.from(document.querySelectorAll('.group-item, [class*="card"]'));
      return items.map(el => ({
        companyName: el.innerText.split('\n')[0].trim(),
        website: el.querySelector('a')?.href || null
      })).filter(v => v.companyName.length > 2);
    });

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ count: vendors.length, vendors }));

  } catch (err) {
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: err.message }));
  } finally {
    activeScrapes--;
    if (browser) {
      // PRO: Force kill browser if close() hangs to prevent zombie processes
      const killTimer = setTimeout(() => {
        console.error('Browser close hang detected. Forcing process exit inside container.');
        process.exit(1); 
      }, 5000);
      
      await browser.close().catch(e => console.error('Close error:', e.message));
      clearTimeout(killTimer);
    }
  }
}

const server = http.createServer((req, res) => {
  if (req.url === '/scrape') return scrape(req, res);
  if (req.url === '/health') return res.end('OK');
  res.writeHead(404).end();
});

server.listen(PORT, '0.0.0.0', () => console.log('Final Scraper V3.0 online'));
