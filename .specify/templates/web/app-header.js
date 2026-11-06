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
            <span class="app-header__accent">${brand}</span>
          </a>
          <nav class="app-header__nav" aria-label="Primary Navigation">
            <a href="/"
               class="app-header__link ${active === 'home' ? 'is-active' : ''}"
               ${active === 'home' ? 'aria-current="page"' : ''}>
              Workspace
            </a>
            <a href="/scalar/v1"
               class="app-header__link"
               target="_blank"
               rel="noopener">
              API Docs
            </a>
          </nav>
        </div>
      </header>
    `;
  }
}

if (!customElements.get('app-header')) {
  customElements.define('app-header', AppHeader);
}
