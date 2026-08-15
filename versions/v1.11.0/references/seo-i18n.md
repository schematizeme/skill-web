# SEO, Dados Estruturados, Sitemap, i18n e Layout de Referência

> Parte da skill **schematize-web**. O alvo do skill é **site rápido em SEO e velocidade** — esta seção cobre o lado de descoberta (SEO/estruturados/sitemap), a internacionalização (i18n com URL própria por idioma) e a disciplina de layout. Performance, que também é SEO, está no §45. **Descoberta por IA (AIO/LLMO/GEO) e markup legível por máquina/IA** estão em `references/aio-llmo-geo.md` — leia as duas juntas: o structured data daqui é a base que a IA também consome.

## Índice
- 46. SEO técnico e dados estruturados
  - 46.1 Metadados por página
  - 46.2 Dados estruturados (schema.org / JSON-LD)
  - 46.3 Sitemap.xml autogerado (estático e dinâmico)
  - 46.4 robots, canonical e indexação
- 47. i18n — internacionalização com URL por idioma
- 48b. Layout de referência (disciplina visual)

---

## 46. SEO técnico e dados estruturados

### 46.1 Metadados por página

**MUST**
- **Toda página tem metadados próprios**, não herda um genérico do layout: `<title>` único e descritivo, `<meta name="description">`, **Open Graph** (`og:title`, `og:description`, `og:image`, `og:url`, `og:type`) e Twitter Card. Use a API de metadata do framework (Next `generateMetadata`, Astro head por página).
- **URL semântica e estável** (slug legível, sem id solto quando evitável). Mudança de URL exige redirect 301.
- HTML renderizado no servidor (SSR/SSG) pro crawler ver conteúdo sem depender de JS.
- Heading e conteúdo refletem a intenção da página (liga com a11y §44.1 — a mesma hierarquia serve humano e crawler).
- **Checklist de metadados (toda página):** `<title>` único, `description`, `canonical`, `og:title/description/image/url/type`, `twitter:card`, `<html lang>` correto, `robots` quando precisar de `noindex` (§46.4), e `hreflang` quando multilíngue (§47).

**SHOULD**
- **`og:image` dinâmica por página** (gerada do título/conteúdo — ex.: `next/og`/Satori, ou endpoint de imagem no Astro), com dimensão declarada (1200×630). Pré-visualização forte melhora clique em buscador, social e cartões de IA.

### 46.2 Dados estruturados (schema.org / JSON-LD)

**MUST**
- **Marcar o conteúdo com schema.org via JSON-LD** quando o tipo se aplica: `Organization`/`WebSite` (com `SearchAction` se houver busca) no site; `Article`/`BlogPosting` em conteúdo (com `author`, `datePublished`, `dateModified`); `Product` + `Offer` em produto; `BreadcrumbList` na navegação; `FAQPage`, `HowTo`, `Event`, `LocalBusiness` quando couber.
- JSON-LD **reflete o conteúdo real da página** (marcar o que não está visível é spam e arrisca penalização). Um bloco `<script type="application/ld+json">` por tipo, no `<head>` ou no fim do `<body>`.
- Validar contra o Rich Results Test / schema validator no fluxo de revisão.

**SHOULD**
- Breadcrumbs estruturados + visuais; imagem com dimensão declarada no schema quando aplicável.

### 46.3 Sitemap.xml autogerado (estático e dinâmico)

**MUST — o sitemap NUNCA é mantido à mão.** Ele é **gerado**, toda vez, da fonte da verdade das rotas:
- **Site estático (SSG):** após o build, **varrer a saída** (as páginas/rotas geradas) e emitir o `sitemap.xml` com cada URL canônica, `lastmod`, e — em site multilíngue — as alternâncias `hreflang` por entrada.
- **Site dinâmico / via API:** obter o **inventário de páginas** de forma programática — manifesto de rotas do framework, ou um **índice de conteúdo da API/CMS** (lista de slugs publicados) — e gerar o sitemap a partir desse inventário. Conteúdo novo publicado entra no sitemap na próxima geração, sem edição manual.
- **Sitemap index** quando passar de 50.000 URLs ou 50 MB (quebrar em vários e referenciar por um índice).
- Registrar o sitemap no `robots.txt` e (idealmente) no Search Console.

> Use `scripts/gen-sitemap.mjs` como scaffold: ele cobre os dois modos — varredura do diretório de build (estático) e leitura de um inventário de rotas/slugs (dinâmico). Conecte a fonte do seu projeto e rode no build/no deploy.

**MUST — i18n no sitemap**
- Em site multilíngue, cada URL lista suas **alternativas por idioma** com `xhtml:link rel="alternate" hreflang="..."`, recíprocas, incluindo `x-default` (§47).

### 46.4 robots, canonical e indexação

**MUST**
- `robots.txt` declarando o que pode ser rastreado e o link do sitemap. `<meta name="robots">`/header `X-Robots-Tag` pra `noindex` em páginas que não devem indexar (busca interna, áreas privadas, paginação duplicada).
- **`<link rel="canonical">`** em toda página, apontando pra URL canônica (evita conteúdo duplicado por query/variação).
- Paginação e filtros com canonical/`noindex` coerentes pra não diluir indexação.

---

## 47. i18n — internacionalização com URL por idioma

### 47.0 i18n-ready por padrão (mesmo em site de um idioma só)

> i18n **não** é "feature de site multilíngue" — é **arquitetura desde o início**.
> Todo site segue isto, inclusive o monolíngue, por dois motivos: (1) **SEO correto
> no idioma local** (o buscador e a IA precisam saber o idioma certo) e (2) **ligar
> outro idioma depois vira trivial** — só adicionar um catálogo, sem caçar string no
> JSX nem migrar rota.

**MUST — vale para QUALQUER site, monolíngue inclusive**
- **`<html lang>` correto** com o idioma real do conteúdo (ex.: `pt-BR`), e `og:locale` + `inLanguage` (JSON-LD) coerentes. Idioma ausente/errado prejudica ranking e leitor de tela.
- **Zero string hardcoded na UI.** Todo texto visível — incl. `alt`, `aria-label`, mensagens de erro, placeholders, e-mails — vem de um **catálogo de mensagens por locale** desde o primeiro dia, **mesmo que só exista um locale**. É isto que torna o multilíngue um "adicionar um arquivo", não um "refatorar tudo".
- **Formatação por locale via `Intl`** (data, número, moeda, plural) — nunca formato fixo "na mão". Já nasce localizável.
- **Roteamento pronto pra locale.** A estrutura de rotas permite **adicionar um segmento de idioma sem quebrar links**: já usar `/[locale]/...` com um único locale, **ou** ter o roteamento abstraído pra introduzir o prefixo depois com redirect 301. A escolha (com ou sem prefixo no site de 1 idioma) é registrada em ADR — mas a arquitetura é i18n-ready de qualquer forma.
- **Canonical no idioma local** correto (§46.4).

**SHOULD**
- Mesmo monolíngue, deixar `hreflang` auto-referente + `x-default` preparado (ou trivial de ligar) pra quando entrar o 2º idioma.
- Definir cedo o esquema de URL (§47.1) pra não migrar depois.

**VETADO**
- String de UI cravada no JSX "porque o site é só em português". É exatamente o que trava a tradução futura e some do controle de qualidade de texto.

### 47.1 Multilíngue — quando há 2+ idiomas

**MUST**
- **Cada idioma tem URL própria.** Locale no caminho (subpath), ex.: `/pt-br/...`, `/en-us/...`. Nada de trocar idioma só no cliente sem mudar a URL (o crawler precisa de uma URL por idioma, e o usuário precisa poder compartilhar/voltar).
- **Esquema de URL definido por projeto.** Há dois padrões; **pergunte ao usuário qual usar** no início (o comando/handoff registra a escolha):
  - **ISO/BCP-47** — `/pt-br`, `/pt-pt`, `/en-us`, `/es-419` (idioma+região). **Default recomendado**: é o mais preciso pra `hreflang` e desambigua variantes regionais (pt-BR ≠ pt-PT).
  - **País/idioma simplificado** — `/br`, `/pt`, `/us`, `/en`. Mais curto, mas ambíguo quando há variantes; só quando o produto não precisa distinguir região.
- **`hreflang` recíproco** entre todas as versões de cada página, **incluindo `x-default`** (fallback). Links de alternância recíprocos (A aponta pra B e B aponta pra A) — `hreflang` quebrado é erro de SEO comum.
- **Metadados próprios por idioma:** `<title>`, `description`, OG, JSON-LD e até a imagem social podem diferir por locale — não traduza só o corpo e deixe o `<title>` em inglês.
- **Todo conteúdo é traduzido.** Nada de string hardcoded no JSX que escapa do sistema de i18n. Texto vem de mensagens por locale (catálogo), inclusive `alt`, `aria-label`, mensagens de erro e placeholders. Datas/números/moeda formatados por locale (`Intl`).
- **`<html lang>` correto por página** e atributo `dir` (RTL para árabe/hebraico).

**SHOULD**
- Detecção de idioma sugere, **não força** (deixe trocar e respeite a escolha; nunca redirecione cegamente por IP de forma que prenda o usuário).
- Fallback de tradução explícito (string faltando cai pro `x-default` com aviso em dev, não quebra a tela).
- Pluralização e gênero via ICU MessageFormat (ou equivalente), não concatenação de string.

**VETADO**
- Página "traduzida" que serve o mesmo HTML em outra URL sem traduzir o conteúdo (conteúdo duplicado + experiência quebrada).
- `hreflang` apontando pra URL que retorna `noindex`/404.

---

## 48b. Layout de referência (disciplina visual)

> O layout da casa toma a **disciplina visual do apple.com como referência** — não como cópia de marca, asset ou cópia de texto (isso seria violação de IP), mas como **princípios** de composição que servem ao alvo de clareza e velocidade.

**Princípios (SHOULD, salvo onde o brief manda outra coisa):**
- **Hierarquia tipográfica forte e poucos tamanhos.** Um display grande e confiante pro herói; corpo legível; escala de tipo intencional. A tipografia carrega a personalidade.
- **Respiro generoso.** Espaço em branco abundante, grid preciso, alinhamento rigoroso. Densidade baixa, foco no produto/conteúdo.
- **Herói de produto/conteúdo.** Abre com a coisa mais característica (imagem/título/demo), não com um banner genérico.
- **Motion contido e com propósito** — revelar no scroll, microinterações sutis — **sempre respeitando `prefers-reduced-motion`** (§44.4). Animação que não serve o conteúdo é ruído.
- **Imagem impecável** (nítida, otimizada — §45.6) e **paleta sóbria** com um acento. Contraste AA mantido (§44.3).
- **Responsivo de verdade**, do desktop ao celular, com a mesma calma de composição.

**MUST**
- O caprichado visual **não** custa acessibilidade nem performance: o herói lindo respeita LCP/CLS (§45) e o motion respeita reduced-motion e foco (§44). Estética que reprova CWV ou a11y **não passa** (§35).
- Não reproduzir marca, logotipo, fotografia ou texto da Apple (ou de qualquer terceiro). Referência é o **vocabulário de composição**, não o conteúdo.

> A elegância está em executar bem uma direção escolhida — respiro, tipografia e detalhe — sem quebrar o piso de acessibilidade e de velocidade. Bonito que é lento ou inacessível é só bonito na captura de tela.
