# Descoberta por IA — AIO, LLMO, GEO e markup legível por máquina

> Parte da skill **schematize-web**. SEO clássico (`seo-i18n.md`) faz o site ser
> achado por **buscadores**; esta reference faz o conteúdo ser **lido, entendido e
> citado por IAs** — assistentes (ChatGPT/Claude/Gemini), respostas generativas
> (AI Overviews/Perplexity) e qualquer agente que consome a web. Siglas:
> **AIO** (AI Optimization), **LLMO** (LLM Optimization), **GEO/GIO** (Generative
> Engine/Information Optimization). Base comum: HTML semântico (§44.1), conteúdo
> renderizado no servidor (§46) e structured data (§46.2).

## Índice
- 62. Princípios (o que muda vs SEO)
- 63. Conteúdo extraível e citável
- 64. Markup legível por máquina
- 65. `llms.txt` e superfícies para IA
- 66. Política de crawler de IA (robots)
- 67. E-E-A-T, proveniência e licença
- 68. Como provar

---

## 62. Princípios — o que muda vs SEO

O buscador rankeia **páginas**; a IA extrai e cita **afirmações**. Otimizar pra IA
é tornar cada fato **inequívoco, atribuível e fácil de recortar**.

**MUST**
- **Conteúdo no HTML servido** (SSR/SSG): IA crawler que não executa JS só vê o que
  veio no HTML. Conteúdo que só aparece após hidratação é invisível pra boa parte
  delas (§46.1).
- **Uma intenção por página/seção**, com resposta direta no topo (não enterrada
  depois de 800 palavras de introdução).
- **Fatos auto-contidos:** datas absolutas (não "ano passado"), unidades, nomes
  completos na primeira menção — a IA recorta um parágrafo sem o resto da página.

**SHOULD**
- Texto estável e datado (`dateModified`) — IA prefere fonte fresca e versionada.

---

## 63. Conteúdo extraível e citável

**MUST**
- **Hierarquia de headings real** (§44.1): um `<h1>`, `<h2>/<h3>` que são perguntas
  ou tópicos claros. A IA usa a árvore de headings pra segmentar.
- **Padrão pergunta→resposta** onde couber: a pergunta como heading, a resposta
  objetiva no primeiro parágrafo, detalhe depois. Casa com `FAQPage` (§64).
- **Listas e tabelas pra dado estruturado** (passos, comparações, specs): IA
  extrai lista/tabela muito melhor que prosa densa.
- **Resumo no topo** (TL;DR) em conteúdo longo — vira o trecho citado.

**SHOULD**
- Glossário/definições explícitas ("X é ..."); termos definidos viram respostas.
- Âncoras por seção (`id` em headings) — permite citar/“deep link” a afirmação.

**VETADO**
- Texto-isca pra IA escondido (oculto por CSS, branco no branco, `aria-hidden`
  cheio de keyword): é cloaking/spam, arrisca penalização e é desonesto. O que a IA
  lê é o que o usuário vê (§44.5).

---

## 64. Markup legível por máquina

Dar à máquina a versão estruturada do que o humano lê. Tudo reflete o conteúdo
visível (marcar o que não está na página é spam — §46.2).

**MUST**
- **JSON-LD schema.org** por tipo aplicável (a forma preferida pelo Google e
  consumível por LLM): `Organization`/`WebSite` (+`SearchAction`), `Article`/
  `BlogPosting` (com `author`, `datePublished`, `dateModified`), `Product`+`Offer`,
  `BreadcrumbList`, `FAQPage`, `HowTo`, `Event`, `LocalBusiness` quando couber.
  Validar no Rich Results Test.
- **Metadados completos** (delega a `seo-i18n.md` §46.1): `<title>`, description,
  canonical, Open Graph e Twitter Card — são o que pré-visualização e muitos
  agentes leem primeiro.
- **Semântica HTML5** (`<article>`, `<time datetime>`, `<nav>`, `<main>`): dá
  significado de máquina sem custo. `<time>` com data absoluta para fatos datados.

**SHOULD**
- **Feeds** quando há conteúdo serial (blog/notícias): RSS/Atom **ou JSON Feed** —
  canal estável e barato pra máquinas (e agentes) acompanharem novidades.
- `author`/`sameAs` ligando a perfis oficiais (sinal de proveniência — §67).
- Microdata/RDFa só se já houver legado; **JSON-LD é o padrão da casa** (não
  misture os três pro mesmo dado).

---

## 65. `llms.txt` e superfícies para IA

**SHOULD** — convenção emergente, barata e útil:
- **`/llms.txt`** na raiz: um Markdown curado que descreve o site e **aponta** pras
  páginas/curadorias mais importantes (visão geral + links com 1 linha cada).
  Funciona como um "índice pra LLM", análogo ao sitemap pra buscador. (Nesta
  própria casa, cada skill publica seu `llms.txt`.)
- **Versão limpa do conteúdo** quando viável: a mesma URL servindo Markdown/texto
  para agentes (via content negotiation ou `.md`), reduzindo ruído de layout.
- Manter `llms.txt` **gerado/curado junto com o conteúdo** (não à mão e
  desatualizado) — mesma disciplina do sitemap (§46.3).

**VETADO**
- `llms.txt` que promete conteúdo divergente do que a página entrega (é cloaking).

---

## 66. Política de crawler de IA (robots)

**MUST — decisão consciente e registrada (ADR), não default no susto.**
- **Saber quem você deixa entrar.** Bots de IA têm user-agents próprios
  (treinamento × indexação de resposta são coisas diferentes). Declare a política
  em `robots.txt` e/ou `X-Robots-Tag`, por bot, conforme a decisão do negócio:
  - permitir indexação de resposta (quer aparecer em respostas generativas) mas
    avaliar o opt-out de **treinamento** se essa for a política;
  - bloquear áreas privadas/duplicadas pra qualquer bot (igual SEO §46.4).
- **Confiar em `robots.txt` não é controle de acesso.** Conteúdo que **não pode**
  ser lido por terceiro é protegido por **auth no servidor** (§43.6), não por
  diretiva que o bot pode ignorar.

**SHOULD**
- Revisar a lista de user-agents periodicamente (mudam) e registrar a política no
  `RUNBOOK`/ADR — é decisão de produto/jurídico, não de implementação solta.

---

## 67. E-E-A-T, proveniência e licença

**MUST**
- **Autoria e data explícitas** em conteúdo informativo: `author` (com `sameAs`),
  `datePublished`/`dateModified` no JSON-LD e visíveis. IA e buscador ponderam
  experiência/autoridade/confiabilidade (E-E-A-T).
- **Fonte e proveniência:** citar fontes com link; afirmação factual rastreável. Em
  conteúdo gerado/assistido por IA, a casa exige archive da geração (§28) — a
  responsabilidade editorial é humana.

**SHOULD**
- **Licença/uso explícito** do conteúdo (termos, `License` no schema quando
  aplicável) — define como terceiros (incl. IA) podem reusar.
- Sinais de organização (contato, `Organization` com `sameAs`) reforçam confiança.

---

## 68. Como provar

- **Render sem JS:** `curl`/“ver código-fonte” mostra o conteúdo e o JSON-LD? Se só
  aparece após hidratar, a IA não vê (§46.1).
- **Structured data válido:** Rich Results Test / validador schema.org no PR.
- **Metadados e OG:** checados no smoke pós-deploy (§48.6) — `<title>`, canonical,
  JSON-LD presentes.
- **`sitemap.xml`, `robots.txt`, `llms.txt` e feed** existem, são gerados e batem
  com o conteúdo (sem promessa divergente).

> Regra de bolso: **escreva pro humano, marque pra máquina, não minta pra
> nenhum dos dois.** Conteúdo claro, no HTML servido, com fatos auto-contidos e
> structured data fiel é o que buscador rankeia, IA cita e usuário entende — os
> três ao mesmo tempo. Truque escondido pra robô é o anti-padrão.
