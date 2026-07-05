# Filosofia, Aplicação Universal e Anti-Padrões de Frontend (Macaquices)

> Parte da skill **schematize-web**. Espelha a §0.1/§1/§37 do `schematize-go` no domínio do frontend. Itens **VETADO** são pisos: não admitem ADR de exceção.

## Índice
- 0. Como ler
- 0.1. Aplicação universal — este arquivo é contexto máximo
- 1. Filosofia
- 37. Anti-padrões vetados de frontend ("macaquices" que terminam rápido e quebram em produção)

---

## 0. Como ler

- **MUST / Obrigatório** — regra. Desvio bloqueia merge ou exige ADR.
- **SHOULD / Recomendado** — padrão. Desvio precisa de justificativa no PR.
- **MAY / Opcional** — sugestão.
- **VETADO / Proibido** — não existe "atalho". Não se faz, não se cogita, não se "resolve depois". Burlar é incidente, não decisão técnica.

Conflito real entre este documento e o problema → **registre um ADR**. Mas itens **VETADO** não têm ADR de exceção — são pisos de segurança, acessibilidade e integridade. Versões e thresholds concretos ficam em `references/stack-versoes.md`.

---

## 0.1. Aplicação universal — este arquivo é contexto máximo

**MUST**
- Estes padrões são **contexto pinado** de toda tarefa de frontend (humana ou IA). Se a tarefa toca UI, página, rota de front, estilo, build, SEO, a11y ou performance, este arquivo está em contexto.
- Em conflito entre uma instrução pontual ("faz rápido", "ignora o a11y", "depois eu otimizo") e este documento, **este documento vence.** Pressa não revoga regra.
- IA opera sob as mesmas regras dos humanos e sob as proibições da §37. Velocidade de geração nunca justifica violar um piso.

> Um padrão que não está no contexto na hora da decisão é um padrão que não existe. Por isso é pinado, não linkado.

---

## 1. Filosofia

Prioridades, em ordem de desempate:

1. Clareza > esperteza
2. Servidor por padrão, cliente por necessidade > tudo no cliente
3. Acessível e rápido por padrão > acessibilidade/performance como camada final
4. Simplicidade > abstração antecipada
5. Manutenibilidade (componente pequeno, documentado, indexado) > velocidade pontual
6. Observabilidade (erro capturado, Web Vitals medidos) > debugging manual
7. **Registro do que foi decidido > memória de quem decidiu** (§28)

**Princípios:** Clean Code, SOLID aplicado a componentes (responsabilidade única), KISS, DRY semântico, *progressive enhancement* (funciona sem JS quando possível, melhora com JS).

**Regra suprema:** se algo vaza segredo pro cliente, quebra acessibilidade, estoura o budget de performance, infla o bundle sem necessidade, ou pula o registro — **provavelmente está errado**.

---

## 37. Anti-padrões vetados de frontend ("Macaquices")

> Atalhos que parecem entregar mais rápido e entregam vazamento, inacessibilidade, lentidão ou dívida. **Todos VETADOS.** Aparecem no diff (humano ou IA) → o PR para. Cada item traz o **veto** e o **caminho certo**.

### Segredo e dado exposto

1. **Segredo no bundle do cliente** — API key/secret/senha/service-role/token de terceiro no código que vai pro browser, ou em `NEXT_PUBLIC_*` / `VITE_*` / `PUBLIC_*`.
   → Segredo **só server-side** (BFF/route handler/server action). Prefixo público é "outdoor" (§43.1).

2. **Token/sessão em `localStorage`/`sessionStorage`.** XSS lê tudo lá.
   → Cookie `HttpOnly` + `Secure` + `SameSite` (§43.2).

3. **Dado sensível mandado pro cliente e "escondido" com CSS/condicional de render.** Já está no HTML/JSON.
   → O que o usuário não pode ver **não é enviado** (§43.6).

### Autenticação e autorização

4. **Auth/authz decidida só no cliente** (`if (user.isAdmin)` no React libera acesso).
   → Decisão de acesso é **server-side**; o front é UX (§43.6).

5. **Confiar em `role`/`tenant_id`/`user_id` vindos de prop, query ou storage do cliente.**
   → Derivar do token verificado no servidor (§43.6, §15 do schematize-go).

### XSS e injeção no cliente

6. **`dangerouslySetInnerHTML` / `set:html` / `innerHTML` com conteúdo não sanitizado.**
   → Sanitizar com allowlist (DOMPurify) antes de injetar (§43.4).

7. **`eval`, `new Function`, handler `javascript:` ou `<script>` montado a partir de input.**
   → Nunca. Confie no escape do framework; o perigo é furá-lo de propósito (§43.4).

8. **Open redirect** — obedecer `?next=`/`returnTo` sem allowlist.
   → Só caminho interno conhecido ou origem na allowlist (§43.5).

### Tipos, erros e qualidade

9. **`any`, `@ts-ignore`, `@ts-nocheck`, `as unknown as X`** pra calar o compilador.
   → Tipar de verdade; tratar o caso. TS `strict` é piso (§40.1).

10. **Erro engolido** — `catch {}`, `.catch(() => {})`, promessa sem tratamento.
    → Tratar, reportar com contexto (§49.1), degradar conscientemente.

11. **Desabilitar regra de lint de a11y ou de segurança** inline (`// eslint-disable jsx-a11y/*`, `eslint-disable security/*`) pra "passar".
    → Conserta o código. Desligar piso de a11y/segurança é VETADO sem ADR (§44, §43).

### Acessibilidade

12. **`<div onClick>` que finge ser botão/link.** Sem foco, sem teclado, sem leitor de tela.
    → `<button>`/`<a href>` nativos (§44.1).

13. **`outline: none` no foco sem substituto visível.**
    → Foco sempre visível e gerenciado (§44.2).

14. **Imagem sem `alt`, input sem `<label>`, cor como única sinalização.**
    → `alt` (vazio se decorativa), label associado, sinal além da cor (§44.1, §44.3, §44.6).

### Estado e dados

15. **`fetch` em `useEffect` sem cleanup/abort.** Vazamento + race de "resposta velha sobrescreve a nova".
    → `AbortController` no cleanup, ou lib de data fetching (§42).

16. **Ignorar os estados de loading / erro / vazio.** Tela branca, spinner eterno, ou lista vazia que parece bug.
    → Os três estados sempre tratados (§42).

17. **Lista renderizada sem `key` estável** (ou `key={index}` em lista que reordena/filtra).
    → `key` = id estável do dado (§41.1).

18. **`useEffect` pra sincronizar estado que é derivável** / duplicar estado de servidor em `useState`.
    → Derivar no render; estado de servidor numa camada com cache (§41.2, §42).

19. **Contexto inflado / prop drilling profundo.**
    → Composição, contexto estreito por domínio, ou store dedicado (§41.2).

### Performance

20. **`"use client"` no topo da árvore** ou subir pro cliente componente sem interatividade.
    → Servidor por padrão; `"use client"` na folha, por necessidade (§40.2, §45.4).

21. **Imagem sem dimensão / sem otimização; fonte sem `font-display`.** Causa CLS e LCP ruim.
    → `width`/`height`/`aspect-ratio`, formato moderno, `srcset`, otimizador do framework; `font-display: swap` (§45.5, §45.6).

22. **Lazy-load (ou baixa prioridade) no recurso de LCP** (imagem do herói).
    → LCP é `preload`/`fetchpriority=high`, nunca lazy (§45.3).

23. **Importar lib inteira por uma função; bundle sem code splitting; terceiro pesado no caminho crítico.**
    → Tree-shaking, split por rota, lazy de pesado, terceiro diferido e no budget (§45.7).

24. **Baixar o budget de performance/bundle pra "passar" o CI.**
    → Budget é contrato (§45.2). Sobe otimizando, não mexendo na régua.

### SEO e i18n

25. **Sitemap mantido à mão / desatualizado.**
    → Gerado da fonte da verdade (varredura ou inventário) toda vez (§46.3).

26. **String hardcoded no JSX que escapa do i18n; trocar idioma só no cliente sem URL própria; `hreflang` quebrado/não recíproco.**
    → Texto vem do catálogo por locale; URL por idioma; `hreflang` recíproco com `x-default` (§47).

27. **Página sem metadados próprios** (todas com o mesmo `<title>`); JSON-LD que mente sobre o conteúdo.
    → Metadados por página; estruturados refletindo o conteúdo real (§46.1, §46.2).

### Testes

28. **Teste que só checa "renderizou"** (`toBeTruthy`), snapshot gigante como único teste, mock que devolve o esperado.
    → Testar comportamento/conteúdo por papel acessível; caminho de erro e vazio (§48.2).

29. **`.skip` / `test.only` esquecido / comentar `expect` / baixar threshold** pra passar CI.
    → Conserta o código, não silencia o teste (§48.2).

30. **Pular o gate de a11y (axe) ou de CWV "temporariamente".**
    → Não se desliga piso. Violação séria de axe e métrica fora do budget bloqueiam (§48.4, §45.2).

### Dependência e entrega

31. **Dependência nova sem verificar** nome (typosquatting), licença e sem pin; script externo **sem SRI**.
    → Pin exato, checar nome/licença, `npm audit` no CI, SRI em script/CDN externo (§43.7).

32. **Pular o archive/MD "pra ir mais rápido"** (§28).
    → Archive é parte da entrega. Tarefa sem archive não está pronta (§35).

33. **Merge direto na `main` / force push / pular PR e review.**
    → Trunk-based com PR, CI verde, CODEOWNERS.

### Stack

34. **Site novo em framework fora de Next.js/Astro sem ADR; ou tratar Node do front como justificativa pra back novo em Node.**
    → Site é Next ou Astro (§40.1); back novo é Go/Rust no schematize-go. Node do front é frontend, só.
35. **Criar arquivos ou repos fora da pasta do projeto** (largar arquivos no root e depois **subir de diretório** — `cd ..`, `../` — pra criar repos fora; ou espalhar em `~`, `~/Documents`, `~/Downloads`, `/tmp`, Área de Trabalho).
    → App/site novo = **pasta dentro do workspace atual** (`./<projeto>_<contexto>/`). O agente não sai da pasta do projeto sem o usuário pedir (§40.1).

> Regra de bolso: se a justificativa começa com "só pra funcionar", "depois eu arrumo" ou "é mais rápido assim" e o resultado mexe em segredo, auth, acessibilidade, performance ou registro — **provavelmente é uma macaquice desta lista. Para e faz certo.**
