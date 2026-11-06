// Top-Layer Mutual Exclusivity Coordinator (Lean SpecKit Standard)
// Guarantees modals (<dialog>) and popovers (popover="auto") never collide or trap focus improperly.

export const TopLayer = {
  _lastTrigger: null,

  dismissAllPopovers() {
    document.querySelectorAll('[popover]').forEach((el) => {
      try {
        if (el.matches(':popover-open')) {
          el.hidePopover();
        }
      } catch {
        // Ignore if browser doesn't support :popover-open on detached node
      }
    });
  },

  openModal(dialogId, triggerEl = document.activeElement) {
    this.dismissAllPopovers();

    document.querySelectorAll('dialog[open]').forEach((d) => {
      if (d.id !== dialogId) d.close();
    });

    const dialog = document.getElementById(dialogId);
    if (!dialog || typeof dialog.showModal !== 'function') return;

    this._lastTrigger = triggerEl;
    dialog.addEventListener(
      'close',
      () => {
        if (this._lastTrigger && typeof this._lastTrigger.focus === 'function') {
          this._lastTrigger.focus();
        }
      },
      { once: true }
    );

    dialog.showModal();
  },

  closeModal(dialogId) {
    const dialog = document.getElementById(dialogId);
    if (dialog && dialog.open) {
      dialog.close();
    }
  }
};

window.TopLayer = TopLayer;
