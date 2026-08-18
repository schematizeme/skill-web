# Observabilidade de Frontend

> Parte da skill **schematize-web**. O front também precisa ser observável — erro de cliente, performance de campo e telemetria. Sem PII, sempre. O lado servidor de observabilidade (logs estruturados, tracing, métricas RED/USE) é do `schematize-go` (§16).

## Índice
- 49. Observabilidade de Frontend
  - 49.1 Captura de erro
  - 49.2 RUM / Web Vitals de campo
  - 49.3 Log estruturado sem PII
  - 49.4 Privacidade e consentimento
  - 49.5 Integração com a stack da casa (LGTM+)

---

## 49. Observabilidade de Frontend

### 49.1 Captura de erro

**MUST**
- **Capturar erro não tratado do cliente:** `window.onerror`, `unhandledrejection`, e **error boundaries** do framework (Next/React error boundary, página de erro do Astro) — pra que falha de UI vire **estado de erro projetado** (§42), não tela branca.
- Erro reportado a uma ferramenta de monitoramento (Sentry ou equivalente) com **contexto útil**: rota, release/versão, navegador, e — quando existir — um `trace_id`/`correlation_id` propagado do servidor (liga com §16.3 do schematize-go) pra casar front e back no mesmo incidente.
- **Erro de hidratação é bug rastreável**, não ruído de console a ignorar.

**VETADO**
- `catch (e) {}` / `.catch(() => {})` no cliente (erro engolido — §37). Trate, reporte com contexto, e degrade conscientemente.

### 49.2 RUM / Web Vitals de campo

**MUST**
- **Instrumentar Web Vitals reais** (LCP, INP, CLS — e TTFB/FCP de apoio) com a lib `web-vitals` (ou o relatório nativo do framework) e enviar pra um coletor/RUM. É o p75 **de campo** que confirma o budget do §45 — lab verde com campo vermelho ainda reprova.
- Atributo de release/versão em cada métrica, pra detectar regressão por deploy.

**SHOULD**
- Métricas de negócio do front (conversão de CTA, passos de funil) separadas das técnicas; amostragem quando o volume exigir.

### 49.3 Log estruturado sem PII

**MUST**
- Telemetria/log do front é **estruturada** e **não carrega PII** (nome, e-mail, CPF, telefone), token, nem conteúdo de formulário. Mascarar na origem.
- **VETADO** logar request/response inteiro, body de formulário ou storage "pra debugar" (§16.1 do schematize-go). Logue campos específicos, mascarados.

### 49.4 Privacidade e consentimento

**MUST**
- Telemetria respeita **consentimento** (banner/preferência) e `Do Not Track` quando aplicável; analytics e RUM só após consentimento onde a lei exige (a UE, p.ex.).
- Sem fingerprinting encoberto. Terceiros de telemetria entram com CSP (§43.3), SRI quando externo, e dentro do budget de performance (§45).

### 49.5 Integração com a stack da casa (LGTM+)

**MUST**
- A telemetria de front integra a **mesma stack de observabilidade da casa** (§16 do `schematize-go`), pra front e back caírem no mesmo Grafana e casarem por `trace_id`:
  - **RUM + erros:** **Grafana Faro** (Faro Web SDK) e/ou **OpenTelemetry-JS** no browser → **Grafana Alloy** (coletor) → **Tempo** (traces do usuário), **Loki** (logs/erros de cliente), **Prometheus/Mimir** (Web Vitals de campo como métrica).
  - **Propagação W3C Trace Context** do browser até o backend — um único trace ponta a ponta (front → BFF → serviço).
  - **Dashboards e alertas** de front (erro por rota/release, p75 de LCP/INP/CLS de campo, taxa de erro de hidratação) **versionados como código** no Grafana e entregues com o serviço; **Helm chart** quando o front tem runtime próprio (BFF/route handlers/adapter em container).
- Sentry (ou equivalente) é aceitável como complemento, mas o **eixo é o Grafana/LGTM+** pra correlação com o backend — evita telemetria de front ilhada de silo separado.

> O front observável é o que conta a verdade sobre o usuário real — erro dele, velocidade dele — sem nunca expor quem ele é. Telemetria com PII é vazamento; telemetria sem contexto é ruído.
