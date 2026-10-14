// schematize-web — config de ESLint de referência (§40, §41, §43, §44), em FLAT CONFIG.
//
// Por que este arquivo existe em flat config e o antigo `.cjs` foi aposentado: o anterior estava
// em formato **eslintrc** (`module.exports = { plugins: [...], extends: [...] }`) com um cabeçalho
// mandando copiá-lo como flat config — os dois formatos são incompatíveis, então ele **não
// rodava**. E declarava `react/no-danger` **sem** `eslint-plugin-react` nos plugins, o que faz o
// ESLint **abortar** ("Definition for rule ... was not found"). Achado do inventário da vistoria
// de 2026-08-21: gate de lint que não carrega é gate ausente com aparência de gate presente.
//
// Instale: eslint@9, typescript-eslint, eslint-plugin-jsx-a11y, eslint-plugin-security,
//          eslint-plugin-import (ou eslint-plugin-import-x), eslint-plugin-react,
//          eslint-plugin-react-hooks. (Next: eslint-config-next.)
//
// A regra de ouro: estas regras NÃO se desligam inline (§44/§37). Desligar exige ADR.

import js from "@eslint/js";
import tseslint from "typescript-eslint";
import a11y from "eslint-plugin-jsx-a11y";
import security from "eslint-plugin-security";
import importPlugin from "eslint-plugin-import";
import react from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  a11y.flatConfigs.recommended,
  {
    files: ["src/**/*.{ts,tsx,js,jsx}"],
    // TYPE-AWARE: `@typescript-eslint/no-floating-promises` (e qualquer regra que precise de tipo)
    // NÃO carrega sem isto — o ESLint aborta com "You have used a rule which requires type
    // information". Um config que aborta é um gate que não roda.
    languageOptions: {
      parserOptions: { projectService: true, tsconfigRootDir: import.meta.dirname },
    },
    plugins: {
      security,
      import: importPlugin,
      react,          // declarado: sem isto, `react/no-danger` ABORTA o ESLint
      "react-hooks": reactHooks,
    },
    rules: {
      // --- §40: TS strict de verdade; nada de calar o compilador ---
      "@typescript-eslint/no-explicit-any": "error",
      "@typescript-eslint/ban-ts-comment": "error",
      "@typescript-eslint/no-floating-promises": "error",

      // --- §43: segurança ---
      "security/detect-eval-with-expression": "error",

      // `dangerouslySetInnerHTML` é ERRO, com uma saída explícita e auditável.
      // Antes: aqui era `warn` e o `check-diff.sh` BLOQUEAVA tudo — uso legítimo com sanitizador
      // travava o CI, e a saída óbvia virava desligar o gate. Agora os dois falam a mesma língua:
      // proibido por default, liberado só com o comentário-âncora que declara o sanitizador,
      // o que deixa rastro no diff e no `grep`.
      //   // eslint-disable-next-line react/no-danger -- sanitizado: DOMPurify.sanitize(x) em <arquivo>
      "react/no-danger": "error",

      "no-restricted-properties": ["error",
        { object: "localStorage", property: "setItem", message: "sessão/token em cookie HttpOnly, não localStorage (§43.2)" },
        { object: "sessionStorage", property: "setItem", message: "sessão/token em cookie HttpOnly, não sessionStorage (§43.2)" },
      ],
      "no-restricted-syntax": ["error",
        {
          selector: "MemberExpression[property.name=/^(NEXT_PUBLIC|VITE|PUBLIC|REACT_APP)_[A-Z0-9_]*(SECRET|KEY|TOKEN|PASSWORD|PRIVATE)/]",
          message: "segredo nunca em variável de prefixo público — vai pro bundle (§43.1)",
        },
      ],

      // --- §44: acessibilidade (mantém o recommended e reforça) ---
      "jsx-a11y/no-autofocus": "warn",
      "jsx-a11y/no-noninteractive-tabindex": "error",

      // --- §41/§42: hooks e data fetching ---
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "error", // dep mentirosa é bug, não estilo

      // --- §41: fronteiras de import (UI não importa infra de servidor direto) ---
      "import/no-restricted-paths": ["error", {
        zones: [
          { target: "./src/components", from: "./src/server", message: "componente de UI não importa infra de servidor direto — use server action/route handler (§40.2)" },
          { target: "./src/app/**/page.tsx", from: "./src/server/db", message: "página não fala com DB direto — passe por camada de dados (§42)" },
        ],
      }],
    },
    settings: { react: { version: "detect" } },
  },
];
