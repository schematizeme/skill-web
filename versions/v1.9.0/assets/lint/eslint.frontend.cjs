// schematize-web — config de ESLint de referência (§40, §43, §44, §41).
// Copie/mescle no eslint.config.cjs (flat) ou .eslintrc. Requer:
//   eslint-plugin-jsx-a11y, eslint-plugin-security, eslint-plugin-import (ou import-x),
//   @typescript-eslint, eslint-plugin-react-hooks, e (Next) eslint-config-next.
// A regra de ouro: estas regras NÃO se desligam inline (§44/§37).
module.exports = {
  plugins: ["jsx-a11y", "security", "import", "@typescript-eslint", "react-hooks"],
  extends: [
    "plugin:jsx-a11y/recommended",
    "plugin:react-hooks/recommended",
  ],
  rules: {
    // --- §40: TS strict de verdade; nada de calar o compilador ---
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/ban-ts-comment": "error",
    "@typescript-eslint/no-floating-promises": "error",

    // --- §43: segurança ---
    "security/detect-eval-with-expression": "error",
    "react/no-danger": "warn", // dangerouslySetInnerHTML: revisar em /schematize-review
    "no-restricted-properties": ["error",
      { object: "localStorage", property: "setItem", message: "sessão/token em cookie HttpOnly, não localStorage (§43.2)" },
      { object: "sessionStorage", property: "setItem", message: "sessão/token em cookie HttpOnly, não sessionStorage (§43.2)" },
    ],
    "no-restricted-syntax": ["error",
      { selector: "MemberExpression[property.name=/^(NEXT_PUBLIC|VITE|PUBLIC|REACT_APP)_[A-Z0-9_]*(SECRET|KEY|TOKEN|PASSWORD|PRIVATE)/]", message: "segredo em env público — exposto no bundle (§43.1). Passe por BFF/server." },
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
        { target: "./src/components", from: "./src/server", message: "componente de UI não importa infra de servidor direto — use server action/route handler (§41)" },
        { target: "./src/app/**/page.tsx", from: "./src/server/db", message: "página não fala com DB direto — passe por camada de dados (§42)" },
      ],
    }],
  },
};
