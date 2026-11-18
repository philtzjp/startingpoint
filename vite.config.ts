import { defineConfig } from "vite-plus";

export default defineConfig({
  staged: { "*": "vp fmt --no-error-on-unmatched-pattern" },
  fmt: {
    sortImports: true,
    sortPackageJson: true,
  },
});
