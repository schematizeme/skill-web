#!/usr/bin/env node
/**
 * gen-sitemap.mjs — gera sitemap.xml SEMPRE de forma derivada (§46), nunca à mão.
 *
 * Dois modos (autodetecta ou force com --mode):
 *   estático  → varre o diretório de saída do build (ex.: out/, dist/, build/)
 *               por arquivos .html e deriva as URLs.
 *   dinâmico  → lê um inventário de rotas de um manifesto JSON (--routes file.json)
 *               ou de stdin. O manifesto é o "índice de páginas" que o app/API
 *               expõe (rotas estáticas + slugs dinâmicos resolvidos).
 *
 * i18n: se as rotas tiverem prefixo de locale (/pt-br, /en-us, ...), emite
 * <xhtml:link rel="alternate" hreflang="..."> recíproco + x-default (§47).
 * Acima de 50.000 URLs, particiona e emite um sitemap index.
 *
 * Uso:
 *   node gen-sitemap.mjs --base https://site.com --out out/ > public/sitemap.xml
 *   node gen-sitemap.mjs --base https://site.com --routes routes.json > public/sitemap.xml
 *   node gen-sitemap.mjs --base https://site.com --mode dynamic < routes.json
 *
 * routes.json: ["/", "/pt-br", "/pt-br/precos", "/en-us", "/en-us/pricing", ...]
 *   (ou objetos { "loc": "/pt-br/precos", "lastmod": "2026-06-20", "changefreq": "weekly", "priority": 0.8 })
 *
 * SCAFFOLD: ajuste OUT_CANDIDATES/locale matcher à sua stack. Para Next com saída
 * server, prefira o modo dinâmico lendo seu manifesto de rotas; para Astro/Next
 * `output: export`, o modo estático varrendo a pasta exportada já resolve.
 */
import fs from "node:fs";
import path from "node:path";

const args = process.argv.slice(2);
function arg(name, def) {
  const i = args.indexOf(name);
  return i >= 0 && args[i + 1] ? args[i + 1] : def;
}
const BASE = (arg("--base", process.env.SITE_BASE_URL || "https://example.com")).replace(/\/+$/, "");
const OUTDIR = arg("--out", null);
const ROUTES = arg("--routes", null);
let MODE = arg("--mode", null);

const OUT_CANDIDATES = ["out", "dist", "build", ".output/public"];
// locales no formato BCP-47 (pt-br) OU simplificado (br). Ajuste se necessário.
const LOCALE_RE = /^\/([a-z]{2}(?:-[a-z]{2})?)(?=\/|$)/i;

function readRoutesFromManifest() {
  let raw = "";
  if (ROUTES) raw = fs.readFileSync(ROUTES, "utf8");
  else raw = fs.readFileSync(0, "utf8"); // stdin
  const data = JSON.parse(raw);
  return data.map((r) => (typeof r === "string" ? { loc: r } : r));
}

function readRoutesFromBuild() {
  let dir = OUTDIR;
  if (!dir) dir = OUT_CANDIDATES.find((d) => fs.existsSync(d));
  if (!dir || !fs.existsSync(dir)) {
    console.error(`gen-sitemap: diretório de build não encontrado (tente --out). Procurei: ${OUT_CANDIDATES.join(", ")}`);
    process.exit(2);
  }
  const urls = [];
  (function walk(d) {
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) walk(p);
      else if (e.name.endsWith(".html") && !e.name.startsWith("404")) {
        let rel = path.relative(dir, p).replace(/\\/g, "/");
        rel = rel.replace(/index\.html$/, "").replace(/\.html$/, "");
        urls.push({ loc: "/" + rel.replace(/\/$/, "") });
      }
    }
  })(dir);
  return urls;
}

function localeOf(loc) {
  const m = loc.match(LOCALE_RE);
  return m ? m[1].toLowerCase() : null;
}
// chave de equivalência entre traduções: o caminho SEM o prefixo de locale
function groupKey(loc) {
  return loc.replace(LOCALE_RE, "") || "/";
}

if (!MODE) MODE = ROUTES ? "dynamic" : OUTDIR ? "static" : "static";
let routes = MODE === "dynamic" ? readRoutesFromManifest() : readRoutesFromBuild();

// normaliza
routes = routes
  .map((r) => ({ ...r, loc: ("/" + String(r.loc).replace(/^\/+/, "")).replace(/\/+$/, "") || "/" }))
  .filter((r, i, a) => a.findIndex((x) => x.loc === r.loc) === i)
  .sort((a, b) => a.loc.localeCompare(b.loc));

// agrupa traduções por groupKey para hreflang recíproco
const groups = new Map();
for (const r of routes) {
  const k = groupKey(r.loc);
  if (!groups.has(k)) groups.set(k, []);
  groups.get(k).push(r);
}

function abs(loc) {
  return BASE + (loc === "/" ? "/" : loc);
}
function esc(s) {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

function urlNode(r) {
  const alts = groups.get(groupKey(r.loc)) || [];
  const hasLocales = alts.some((x) => localeOf(x.loc));
  const lines = [`  <url>`, `    <loc>${esc(abs(r.loc))}</loc>`];
  if (r.lastmod) lines.push(`    <lastmod>${esc(r.lastmod)}</lastmod>`);
  if (r.changefreq) lines.push(`    <changefreq>${esc(r.changefreq)}</changefreq>`);
  if (r.priority != null) lines.push(`    <priority>${r.priority}</priority>`);
  if (hasLocales && alts.length > 1) {
    for (const a of alts) {
      const lang = localeOf(a.loc);
      if (lang) lines.push(`    <xhtml:link rel="alternate" hreflang="${lang}" href="${esc(abs(a.loc))}"/>`);
    }
    // x-default aponta pro primeiro com locale (ou raiz do grupo)
    const def = alts.find((a) => localeOf(a.loc)) || alts[0];
    lines.push(`    <xhtml:link rel="alternate" hreflang="x-default" href="${esc(abs(def.loc))}"/>`);
  }
  lines.push(`  </url>`);
  return lines.join("\n");
}

const HEAD =
  `<?xml version="1.0" encoding="UTF-8"?>\n` +
  `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">`;
const FOOT = `</urlset>`;

const LIMIT = 50000;
if (routes.length <= LIMIT) {
  process.stdout.write(HEAD + "\n" + routes.map(urlNode).join("\n") + "\n" + FOOT + "\n");
} else {
  // particiona + sitemap index (escreve arquivos sitemap-N.xml ao lado e emite o index no stdout)
  const parts = [];
  for (let i = 0; i < routes.length; i += LIMIT) parts.push(routes.slice(i, i + LIMIT));
  const dir = OUTDIR || "public";
  parts.forEach((p, idx) => {
    const xml = HEAD + "\n" + p.map(urlNode).join("\n") + "\n" + FOOT + "\n";
    fs.writeFileSync(path.join(dir, `sitemap-${idx + 1}.xml`), xml);
  });
  const idx =
    `<?xml version="1.0" encoding="UTF-8"?>\n` +
    `<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n` +
    parts.map((_, i) => `  <sitemap><loc>${esc(BASE)}/sitemap-${i + 1}.xml</loc></sitemap>`).join("\n") +
    `\n</sitemapindex>\n`;
  process.stdout.write(idx);
  console.error(`gen-sitemap: ${routes.length} URLs > ${LIMIT}; gerei ${parts.length} sitemaps + index.`);
}
