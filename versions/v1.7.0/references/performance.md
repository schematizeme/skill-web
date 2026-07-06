# Performance — Core Web Vitals, Budgets e Otimização

> Parte da skill **schematize-web**. O alvo declarado do skill é **site rápido em SEO e velocidade** — esta seção é o coração disso. Os thresholds concretos (que o Google atualiza) ficam em `references/stack-versoes.md`; aqui ficam as regras de como atingi-los e como **travar regressão no CI**.

## Índice
- 45. Performance
  - 45.1 Core Web Vitals como contrato
  - 45.2 Budgets (métrica e bundle)
  - 45.3 LCP — carregar o conteúdo principal rápido
  - 45.4 INP — responder à interação rápido
  - 45.5 CLS — não pular layout
  - 45.6 Imagem e fonte
  - 45.7 JavaScript: code splitting e lazy
  - 45.8 Medição no CI

---

## 45. Performance

### 45.1 Core Web Vitals como contrato

**MUST**
- As três métricas de campo são tratadas como **contrato**, medidas no **p75 de usuários reais (CrUX), com mobile como referência primária**:
  - **LCP** (Largest Contentful Paint) — velocidade de carregamento do maior elemento.
  - **INP** (Interaction to Next Paint) — responsividade a toda interação (substituiu o FID em mar/2024).
  - **CLS** (Cumulative Layout Shift) — estabilidade visual.
- Os valores-alvo do "bom" estão em `references/stack-versoes.md` (Anexo A). **Uma página só é "boa" se as três passam** ao mesmo tempo.
- **Mobile é o caso de teste, não o desktop.** Otimize pro celular mediano em rede ruim — é ele que define o ranking.

### 45.2 Budgets (métrica e bundle)

**MUST**
- Cada rota tem **budget de métrica** (LCP/INP/CLS) e **budget de bundle** (KB de JS/CSS no caminho crítico). Definidos no projeto, versionados, e **verificados no CI** (§45.8).
- **Alertar antes de estourar:** configure alerta em ~80% do threshold (ver `references/stack-versoes.md` pros números), não só quando já reprovou.
- Estourar budget **bloqueia o merge** — é regressão, não detalhe. Baixar o budget pra "passar" é VETADO (§37), igual baixar threshold de teste.

### 45.3 LCP — carregar o conteúdo principal rápido

**MUST**
- **Renderizar no servidor** (SSR/SSG) o conteúdo acima da dobra; não depender de JS no cliente pra pintar o herói.
- **Pré-carregar o recurso de LCP** (`<link rel="preload">` pra a imagem/fonte do herói; `fetchpriority="high"` na imagem principal). Sem lazy-load no que está acima da dobra.
- **CSS crítico inline / sem render-blocking desnecessário.** Reduzir cadeia de requisições antes da primeira pintura.
- `preconnect` pros domínios críticos (fontes, CDN de imagem).

### 45.4 INP — responder à interação rápido

**MUST**
- **Não bloquear a main thread.** Tarefas longas de JS são quebradas (yield à main thread); trabalho não urgente é diferido (`scheduler.postTask`/`requestIdleCallback`).
- **Menos JS no cliente** (liga com §40: servidor por padrão). Cada KB de JS é parse + execução na main thread.
- Hidratação seletiva / ilhas (Astro) ou Server Components (Next) pra não hidratar a página inteira.
- DOM enxuto (árvores gigantes encarecem cada interação).

### 45.5 CLS — não pular layout

**MUST**
- **Dimensões reservadas para tudo que carrega depois:** `width`/`height` (ou `aspect-ratio`) em **toda** imagem, vídeo, iframe e slot de anúncio/embed. Espaço reservado pra conteúdo assíncrono.
- **Fonte sem "salto":** `font-display: swap` + `size-adjust`/fallback métrico pra minimizar reflow na troca de fonte.
- Não inserir conteúdo acima do que o usuário já está lendo (banner que empurra a página).
- **Zero layout shift é a meta**, não um bônus.

### 45.6 Imagem e fonte

**MUST**
- **Imagem otimizada:** formato moderno (AVIF/WebP), `srcset`/`sizes` responsivos, dimensão correta pro container, `loading="lazy"` **abaixo** da dobra (nunca no LCP). Use o otimizador do framework (next/image, `<Image>`/assets do Astro) quando houver.
- **Fonte otimizada:** subset, `woff2`, self-host quando viável, `preload` da fonte do herói, `font-display: swap`. Evitar FOIT (texto invisível) e minimizar FOUT.

### 45.7 JavaScript: code splitting e lazy

**MUST**
- **Code splitting por rota** (default dos frameworks) e **lazy de componentes pesados** abaixo da dobra ou atrás de interação (modal, editor, gráfico).
- Importar só o que usa (tree-shaking real; evitar import de lib inteira por uma função).
- Terceiro (analytics, chat, tag manager) carregado de forma diferida e, quando possível, isolado — e dentro do budget (§45.2) e da CSP (§43.3).

**SHOULD**
- Auditar o bundle (analyzer) e cortar dependência grande por alternativa leve ou implementação própria pequena.

### 45.8 Medição no CI

**MUST**
- **Lighthouse CI** (ou equivalente) roda no PR contra orçamentos de métrica e de recurso; **falha o build** quando estoura. Ver `assets/ci/github-actions-ci.yml`.
- **Lab + campo:** o Lighthouse (lab) pega regressão cedo; o RUM/Web Vitals de produção (§49) confirma o p75 real. Lab verde com campo vermelho = ainda reprova.
- Budget de bundle verificado no build (tamanho por rota) — não só a métrica.

> Performance não é um *pass* final, é uma restrição de projeto. Mede no CI, trava regressão como trava teste, e otimiza pro celular mediano — porque é ele que o Google mede e o usuário usa.
