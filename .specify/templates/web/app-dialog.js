class AppDialog extends HTMLElement {
  connectedCallback() {
    if (this.hasAttribute('rendered')) return;
    this.setAttribute('rendered', 'true');

    const rawDialogId = this.getAttribute('dialog-id') || 'app-modal';
    const dialogId = rawDialogId.replace(/[^a-zA-Z0-9_-]/g, '');
    const title = this.escapeHtml(this.getAttribute('title') || 'Details');
    const childNodes = Array.from(this.childNodes);

    this.innerHTML = `
      <dialog id="${dialogId}" class="app-dialog" aria-labelledby="${dialogId}-title">
        <div class="l-split app-dialog__header">
          <h2 id="${dialogId}-title" class="app-dialog__title">${title}</h2>
          <button type="button" class="btn btn--ghost" data-close-dialog="${dialogId}" aria-label="Close modal">
            ✕
          </button>
        </div>
        <div class="app-dialog__body"></div>
      </dialog>
    `;

    this.querySelector('.app-dialog__body')?.append(...childNodes);
    this.querySelector('[data-close-dialog]')?.addEventListener('click', () => {
      window.TopLayer?.closeModal(dialogId);
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

if (!customElements.get('app-dialog')) {
  customElements.define('app-dialog', AppDialog);
}
