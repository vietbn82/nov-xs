// Top-Layer Notification Stack (<app-toast>)
// Uses HTML5 `popover="manual"` so toasts render in the native Top-Layer above <dialog> modals without z-index conflicts.

class AppToast extends HTMLElement {
  connectedCallback() {
    if (this.hasAttribute('rendered')) return;
    this.setAttribute('rendered', 'true');

    this.innerHTML = `
      <div id="app-toast-stack" class="app-toast-stack" popover="manual" role="status" aria-live="polite"></div>
    `;
    this.stackEl = this.querySelector('#app-toast-stack');
  }

  show({ title, variant = 'info', durationMs = 3200 }) {
    if (!this.stackEl) return;
    try {
      if (!this.stackEl.matches(':popover-open')) {
        this.stackEl.showPopover();
      }
    } catch {
      // Fallback if popover API is unsupported in test runner
    }

    const toast = document.createElement('div');
    toast.className = `app-toast app-toast--${variant}`;
    toast.textContent = title;
    this.stackEl.appendChild(toast);

    setTimeout(() => {
      toast.remove();
      if (this.stackEl && this.stackEl.children.length === 0) {
        try {
          this.stackEl.hidePopover();
        } catch {}
      }
    }, durationMs);
  }
}

if (!customElements.get('app-toast')) {
  customElements.define('app-toast', AppToast);
}

window.AppToast = {
  show(options) {
    const el = document.querySelector('app-toast');
    if (el && typeof el.show === 'function') {
      el.show(typeof options === 'string' ? { title: options } : options);
    }
  }
};
