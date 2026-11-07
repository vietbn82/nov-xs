// Top-Layer Mutual Exclusivity Coordinator (Lean SpecKit Standard)
// Guarantees modals (<dialog>) and popovers (popover="auto") never collide or race on focus return.

export const TopLayer = {
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

    let inheritedTrigger = triggerEl;
    document.querySelectorAll('dialog[open]').forEach((d) => {
      if (d.id !== dialogId) {
        if ((!inheritedTrigger || d.contains(inheritedTrigger)) && d._returnFocusEl) {
          inheritedTrigger = d._returnFocusEl;
        }
        d.close();
      }
    });

    const dialog = document.getElementById(dialogId);
    if (!dialog || typeof dialog.showModal !== 'function') return;

    dialog._returnFocusEl = inheritedTrigger;
    dialog.addEventListener(
      'close',
      () => {
        // Do not steal focus if another modal dialog was opened immediately
        if (document.querySelector('dialog[open]')) return;
        const target = dialog._returnFocusEl;
        if (target && typeof target.focus === 'function' && document.contains(target)) {
          target.focus();
        }
      },
      { once: true }
    );

    if (!dialog.open) {
      dialog.showModal();
    }
  },

  closeModal(dialogId) {
    const dialog = document.getElementById(dialogId);
    if (dialog && dialog.open) {
      dialog.close();
    }
  }
};

window.TopLayer = TopLayer;
