class AppDialog extends HTMLElement {
  connectedCallback() {
    if (this.hasAttribute('rendered')) return;
    this.setAttribute('rendered', 'true');

    const dialogId = this.getAttribute('dialog-id') || 'app-modal';
    const title = this.getAttribute('title') || 'Details';
    const bodyContent = this.innerHTML;

    this.innerHTML = `
      <dialog id="${dialogId}" class="app-dialog" aria-labelledby="${dialogId}-title">
        <div class="app-dialog__header">
          <h2 id="${dialogId}-title" class="app-dialog__title">${title}</h2>
          <button type="button" class="btn btn--ghost" data-close-dialog="${dialogId}" aria-label="Close modal">
            ✕
          </button>
        </div>
        <div class="app-dialog__body">
          ${bodyContent}
        </div>
      </dialog>
    `;

    this.querySelector(`[data-close-dialog="${dialogId}"]`)?.addEventListener('click', () => {
      window.TopLayer?.closeModal(dialogId);
    });
  }
}

if (!customElements.get('app-dialog')) {
  customElements.define('app-dialog', AppDialog);
}
