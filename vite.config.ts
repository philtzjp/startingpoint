import { defineConfig } from "vite-plus";

export default defineConfig({
  staged: { "*": "vp fmt --no-error-on-unmatched-pattern" },
  fmt: {
    sortImports: true,
    sortPackageJson: true,
  },
  lint: {
    jsPlugins: [{ name: "no-comments", specifier: "eslint-plugin-no-comments" }],
    rules: {
      "no-comments/disallowComments": [
        "error",
        {
          allow: [
            "oxlint-disable",
            "oxlint-enable",
            String.raw`fallow-ignore-(?:next-line|file) \S`,
            String.raw`@vitest-environment \S+$`,
            String.raw`v8 ignore (?:start|stop|next|file|if|else)\b`,
            "@vite-ignore $",
            "/ <reference (?:types|path|lib)=",
          ],
        },
      ],
    },
  },
});
