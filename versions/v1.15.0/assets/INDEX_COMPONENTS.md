# Índice de Componentes / Hooks — <projeto>

> Catálogo fino de componentes/hooks/funções (§39), **gerado** a partir dos
> doc-comments obrigatórios (§6) via `scripts/build-index.mjs`. NÃO editar à mão
> as seções geradas — corrija o doc-comment na origem e regenere.
> Local: `<projeto>_archive/index/INDEX_COMPONENTS.md`. Última geração: <data>.

## <pasta / feature>

### Componentes
| Nome | O quê | Onde é usado | Estado/efeitos | Origem |
|---|---|---|---|---|
| `Hero` | bloco de topo com CTA primário | home `/[locale]` | sem estado; props de conteúdo i18n | `components/Hero.tsx:12` |
| `PriceTable` | tabela de planos acessível | `/[locale]/precos` | server data; loading/erro/vazio | `components/PriceTable.tsx:20` |

### Hooks
| Nome | O quê | Onde é usado | Estado/efeitos | Origem |
|---|---|---|---|---|
| `useLocale` | resolve locale atual e dicionário | layout, header | lê params; memoiza | `hooks/useLocale.ts:8` |

<!-- BEGIN GENERATED -->
<!-- conteúdo gerado por build-index; não editar manualmente -->
<!-- END GENERATED -->
