import { defineConfig } from "vite-plus";

export default defineConfig({
  staged: { "*": "vp check --fix" },
  run: {
    tasks: {
      check: "vp check",
      fallow: "fallow",
      verify: { command: [], dependsOn: ["check", "fallow"] },
    },
  },
  fmt: {
    sortImports: true,
    sortPackageJson: true,
  },
  lint: {
    options: { typeAware: true, typeCheck: true },
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
