#!/usr/bin/env node
/**
 * build-index.mjs — gera o índice de componentes/hooks/funções (§39) a partir
 * dos doc-comments obrigatórios (§6).
 *
 * Convenção lida: um doc-comment imediatamente acima da declaração com as linhas:
 *     O quê: <descrição>
 *     Onde:  <onde é montado / quem consome>
 *     Estado: <opcional — fonte de estado, props críticas, efeitos>
 * seguido da declaração do componente/hook/função. Emite tabela markdown por arquivo,
 * separando Componentes (PascalCase) de Hooks (use*) de funções comuns.
 *
 * Uso (o índice mora no archive, nunca no root — §28):
 *   node build-index.mjs <dir-de-origem> [> <projeto>_archive/index/INDEX_COMPONENTS.md]
 *
 * SCAFFOLD: cobre TS/TSX/JS/JSX por regex. A ideia é que o índice seja DERIVADO
 * do código comentado, não mantido à mão — o CI compara gerado vs. commitado e
 * trava se divergirem ou se houver declaração sem doc.
 */
import fs from "node:fs";
import path from "node:path";

const ROOT = process.argv[2] ?? "src";
const EXTS = new Set([".ts", ".tsx", ".js", ".jsx", ".mjs"]);

// Declarações: function X / const X = (...) => / const X = forwardRef / export default function X
const declRe =
  /(?:export\s+)?(?:default\s+)?(?:async\s+)?function\s+(\w+)|(?:export\s+)?const\s+(\w+)\s*(?::\s*[^=]+)?=\s*(?:async\s*)?(?:\(|forwardRef|memo|function|React\.)/;

function* walk(dir) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return;
  }
  for (const e of entries) {
    if (e.name === "node_modules" || e.name.startsWith(".")) continue;
    const p = path.join(dir, e.name);
    if (e.isDirectory()) yield* walk(p);
    else if (EXTS.has(path.extname(e.name)) && !/\.(test|spec|d)\./.test(e.name)) yield p;
  }
}

function field(block, label) {
  const m = block.match(new RegExp(`${label}\\s*:\\s*(.+)`, "i"));
  return m ? m[1].trim().replace(/\*\/\s*$/, "").trim() : "";
}

function kindOf(name) {
  if (/^use[A-Z]/.test(name)) return "hook";
  if (/^[A-Z]/.test(name)) return "component";
  return "fn";
}

const byFile = new Map();
let missing = 0;

for (const file of walk(ROOT)) {
  const lines = fs.readFileSync(file, "utf8").split("\n");
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(declRe);
    if (!m) continue;
    const name = m[1] || m[2];
    if (!name) continue;
    // Olha pra trás: existe doc-comment CONTÍGUO terminando logo acima?
    let j = i - 1;
    while (j >= 0 && lines[j].trim() === "") j--;
    let block = "";
    if (j >= 0 && /\*\//.test(lines[j])) {
      let k = j;
      while (k >= 0 && !/\/\*/.test(lines[k])) k--;
      if (k >= 0) block = lines.slice(k, j + 1).join("\n");
    } else if (j >= 0 && /^\s*\/\//.test(lines[j])) {
      let k = j;
      while (k >= 0 && /^\s*\/\//.test(lines[k])) k--;
      block = lines.slice(k + 1, j + 1).join("\n");
    }
    const what = field(block, "O quê") || field(block, "what");
    const where = field(block, "Onde") || field(block, "usedby");
    const st = field(block, "Estado") || field(block, "state");
    if (!what || !where) missing++;
    const rel = path.relative(process.cwd(), file);
    if (!byFile.has(rel)) byFile.set(rel, []);
    byFile.get(rel).push({
      name,
      kind: kindOf(name),
      what: what || "⚠ SEM DOC",
      where: where || "⚠ SEM DOC",
      st,
      line: i + 1,
    });
  }
}

const out = [];
out.push(`# Índice de Componentes / Hooks (gerado)`, "");
out.push(`> Gerado por build-index em ${new Date().toISOString()}. Não editar à mão.`, "");
out.push(`> Fonte da verdade DERIVADA dos doc-comments (§6/§39). CI compara gerado vs. commitado.`, "");
if (missing)
  out.push(
    "",
    `> ⚠ ${missing} declaração(ões) sem doc-comment de contexto completo (O quê + Onde) — §6. Corrija na origem.`,
    ""
  );

const labels = { component: "Componentes", hook: "Hooks", fn: "Funções" };
for (const [file, items] of [...byFile].sort()) {
  out.push("", `## ${file}`, "");
  for (const kind of ["component", "hook", "fn"]) {
    const rows = items.filter((x) => x.kind === kind);
    if (!rows.length) continue;
    out.push(`### ${labels[kind]}`, "");
    out.push(`| Nome | O quê | Onde é usado | Estado/efeitos | Linha |`, `|---|---|---|---|---|`);
    for (const f of rows) out.push(`| \`${f.name}\` | ${f.what} | ${f.where} | ${f.st} | ${f.line} |`);
    out.push("");
  }
}
process.stdout.write(out.join("\n") + "\n");
// exit 1 se houver declaração sem doc — pra travar em CI (§6, §39)
process.exit(missing > 0 ? 1 : 0);
