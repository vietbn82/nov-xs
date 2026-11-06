class AppHeader extends HTMLElement {
  connectedCallback() {
    if (this.hasAttribute('rendered')) return;
    this.setAttribute('rendered', 'true');

    const brand = this.getAttribute('brand') || 'App';
    const active = this.getAttribute('active') || 'home';

    this.innerHTML = `
      <header class="app-header">
        <div class="app-header__inner">
          <a href="/" class="app-header__brand" aria-label="${brand} Home">
            <span class="app-header__accent">◆</span>
            <span>${brand}</span>
          </a>
          <nav class="app-header__nav" aria-label="Primary Navigation">
            <a href="/"
               class="app-header__link ${active === 'home' ? 'is-active' : ''}"
               ${active === 'home' ? 'aria-current="page"' : ''}>
              Workspace
            </a>
            <button type="button" class="btn btn--ghost" data-action="open-cmd" aria-label="Open Command Palette">
              <span>Command</span>
              <kbd class="kbd">Ctrl K</kbd>
            </button>
            <button type="button" class="btn btn--ghost" data-action="open-drawer" aria-label="Open Inspector Drawer">
              Inspector
            </button>
          </nav>
        </div>
      </header>
    `;

    this.querySelector('[data-action="open-cmd"]')?.addEventListener('click', (e) => {
      document.querySelector('app-cmd-palette')?.open(e.currentTarget);
    });

    this.querySelector('[data-action="open-drawer"]')?.addEventListener('click', (e) => {
      window.TopLayer?.openModal('app-inspector-drawer', e.currentTarget);
    });
  }
}

if (!customElements.get('app-header')) {
  customElements.define('app-header', AppHeader);
}
