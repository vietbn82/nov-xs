// Slide-Over Right Drawer (<app-drawer>)
// Built on native <dialog> + TopLayer coordinator so it never squishes or breaks main page layout.

class AppDrawer extends HTMLElement {
  connectedCallback() {
    if (this.hasAttribute('rendered')) return;
    this.setAttribute('rendered', 'true');

    const drawerId = this.getAttribute('drawer-id') || 'app-inspector-drawer';
    const title = this.getAttribute('title') || 'Inspector';
    const bodyContent = this.innerHTML;

    this.innerHTML = `
      <dialog id="${drawerId}" class="app-drawer" aria-labelledby="${drawerId}-title">
        <div class="l-split app-dialog__header">
          <h2 id="${drawerId}-title" class="app-dialog__title">${title}</h2>
          <button type="button" class="btn btn--ghost" data-close-drawer="${drawerId}" aria-label="Close drawer">
            ✕
          </button>
        </div>
        <div class="l-stack app-drawer__body">
          ${bodyContent}
        </div>
      </dialog>
    `;

    const dialog = this.querySelector(`#${drawerId}`);
    this.querySelector(`[data-close-drawer="${drawerId}"]`)?.addEventListener('click', () => {
      window.TopLayer?.closeModal(drawerId);
    });

    // Light-dismiss when clicking backdrop outside drawer box
    dialog?.addEventListener('click', (e) => {
      if (e.target === dialog) {
        window.TopLayer?.closeModal(drawerId);
      }
    });
  }
}

if (!customElements.get('app-drawer')) {
  customElements.define('app-drawer', AppDrawer);
}
