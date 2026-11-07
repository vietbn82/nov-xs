// Slide-Over Right Drawer (<app-drawer>)
// Built on native <dialog> + TopLayer coordinator so it never squishes or breaks main page layout.

class AppDrawer extends HTMLElement {
  connectedCallback() {
    if (this.hasAttribute('rendered')) return;
    this.setAttribute('rendered', 'true');

    const rawDrawerId = this.getAttribute('drawer-id') || 'app-inspector-drawer';
    const drawerId = rawDrawerId.replace(/[^a-zA-Z0-9_-]/g, '');
    const title = this.escapeHtml(this.getAttribute('title') || 'Inspector');
    const childNodes = Array.from(this.childNodes);

    this.innerHTML = `
      <dialog id="${drawerId}" class="app-drawer" aria-labelledby="${drawerId}-title">
        <div class="l-split app-dialog__header">
          <h2 id="${drawerId}-title" class="app-dialog__title">${title}</h2>
          <button type="button" class="btn btn--ghost" data-close-drawer="${drawerId}" aria-label="Close drawer">
            ✕
          </button>
        </div>
        <div class="l-stack app-drawer__body"></div>
      </dialog>
    `;

    this.querySelector('.app-drawer__body')?.append(...childNodes);
    const dialog = this.querySelector('dialog');
    this.querySelector('[data-close-drawer]')?.addEventListener('click', () => {
      window.TopLayer?.closeModal(drawerId);
    });

    // Light-dismiss when clicking backdrop outside drawer box
    dialog?.addEventListener('click', (e) => {
      if (e.target === dialog) {
        window.TopLayer?.closeModal(drawerId);
      }
    });
  }

  escapeHtml(str) {
    return String(str)
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
  }
}

if (!customElements.get('app-drawer')) {
  customElements.define('app-drawer', AppDrawer);
}
