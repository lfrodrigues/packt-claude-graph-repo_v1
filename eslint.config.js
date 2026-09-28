import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import prettier from 'eslint-config-prettier';

export default tseslint.config(
  { ignores: ['node_modules', 'dist', 'coverage', 'graph/**/*.js', 'chapters/**'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  prettier,
  { rules: { '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }] } }
);
