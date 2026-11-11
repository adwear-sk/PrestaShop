// Screenshot storefront URLs at desktop + phone widths and report horizontal overflow.
// Usage (inside the Playwright container): node shot.mjs <outDir> <url> [url...]
import { chromium } from 'playwright';

const [outDir, ...urls] = process.argv.slice(2);
if (!outDir || urls.length === 0) {
  console.error('usage: node shot.mjs <outDir> <url> [url...]');
  process.exit(2);
}

// Headless UAs are treated as bots by the shop (no cart, no guest) — pose as desktop/mobile Chrome.
const viewports = [
  { name: '1440', width: 1440, height: 900, ua: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' },
  { name: '390', width: 390, height: 844, ua: 'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36', mobile: true },
];

const browser = await chromium.launch();
let failed = false;
for (const url of urls) {
  const slug = url.replace(/^https?:\/\//, '').replace(/[^a-z0-9]+/gi, '_').slice(0, 80);
  for (const vp of viewports) {
    const ctx = await browser.newContext({
      viewport: { width: vp.width, height: vp.height },
      userAgent: vp.ua,
      isMobile: !!vp.mobile,
      hasTouch: !!vp.mobile,
      ignoreHTTPSErrors: true,
    });
    const page = await ctx.newPage();
    const errors = [];
    page.on('pageerror', (e) => errors.push(e.message));
    const res = await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });
    const status = res ? res.status() : 0;
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
    const fatal = await page.evaluate(() => /Fatal error|SmartyException|Uncaught/i.test(document.body.innerText));
    const file = `${outDir}/${slug}_${vp.name}.png`;
    await page.screenshot({ path: file, fullPage: true });
    const bad = status >= 400 || overflow > 0 || fatal || errors.length > 0;
    failed ||= bad;
    console.log(`${bad ? 'FAIL' : 'ok  '} ${vp.name} ${status} overflow=${overflow}px fatal=${fatal} jsErrors=${errors.length} ${file.replace(outDir, process.env.HOST_OUT || outDir)}`);
    errors.slice(0, 3).forEach((e) => console.log(`       js: ${e.split('\n')[0]}`));
    await ctx.close();
  }
}
await browser.close();
process.exit(failed ? 1 : 0);
