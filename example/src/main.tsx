import { main as Main } from './example.gleam';

import { render } from 'preact';

if (import.meta.env.DEV) {
  await import('preact/devtools');
}

const app = document.getElementById('app');

if (app) {
  render(<Main />, app);
}
