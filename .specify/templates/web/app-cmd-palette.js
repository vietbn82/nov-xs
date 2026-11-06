// Raycast / Linear-Style Command Palette (<app-cmd-palette>)
// Global Ctrl+K / Cmd+K launcher with keyboard navigation and built-in UI Health Audit trigger.

class AppCmdPalette extends HTMLElement {
  connectedCallback() {
    if (this.hasAttribute('rendered')) return;
    this.setAttribute('rendered', 'true');

    this.commands = [
      {
        id: 'audit-ui',
        label: 'Run Live UI Geometry & Health Audit',
        shortcut: 'Audit',
        run: () => {
          const report = window.UiHealthProbe?.runAudit();
          if (report?.passed) {
            window.AppToast?.show({
              title: `UI Audit Passed (${report.interactiveCount} controls verified at ${report.viewport})`,
              variant: 'success'
            });
          } else {
            window.AppToast?.show({
              title: `UI Audit Found ${report?.issues?.length || 1} Issue(s)`,
              variant: 'danger'
            });
          }
        }
      },
      {
        id: 'open-inspector',
        label: 'Open AI & System Inspector Drawer',
        shortcut: 'Drawer',
        run: () => window.TopLayer?.openModal('app-inspector-drawer')
      },
      {
        id: 'open-scalar',
        label: 'Open Scalar OpenAPI Reference',
        shortcut: 'API',
        run: () => window.open('/scalar/v1', '_blank', 'noopener')
      }
    ];

    this.innerHTML = `
      <dialog id="app-cmd-dialog" class="cmd-dialog" aria-label="Command Palette">
        <div class="l-stack">
          <input data-role="search" class="input-field" type="search" placeholder="Type a command or search..." aria-label="Filter commands" autocomplete="off" />
          <ul data-role="results" class="item-list" role="listbox"></ul>
        </div>
      </dialog>
    `;

    this.inputEl = this.querySelector('[data-role="search"]');
    this.listEl = this.querySelector('[data-role="results"]');

    this.inputEl?.addEventListener('input', () => this.renderList(this.inputEl.value));
    this.renderList('');

    window.addEventListener('keydown', (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        this.open();
      }
    });
  }

  open(triggerEl = document.activeElement) {
    window.TopLayer?.openModal('app-cmd-dialog', triggerEl);
    if (this.inputEl) {
      this.inputEl.value = '';
      this.renderList('');
      this.inputEl.focus();
    }
  }

  renderList(query) {
    if (!this.listEl) return;
    const normalized = query.trim().toLowerCase();
    const matches = this.commands.filter((c) => c.label.toLowerCase().includes(normalized));

    if (matches.length === 0) {
      this.listEl.innerHTML = '<li class="empty-state">No matching commands.</li>';
      return;
    }

    this.listEl.innerHTML = matches
      .map(
        (cmd) => `
        <li>
          <button type="button" class="cmd-item" data-cmd-id="${cmd.id}">
            <span>${cmd.label}</span>
            <kbd class="kbd">${cmd.shortcut}</kbd>
          </button>
        </li>`
      )
      .join('');

    this.listEl.querySelectorAll('[data-cmd-id]').forEach((btn) => {
      btn.addEventListener('click', () => {
        const cmd = this.commands.find((c) => c.id === btn.getAttribute('data-cmd-id'));
        window.TopLayer?.closeModal('app-cmd-dialog');
        cmd?.run();
      });
    });
  }
}

if (!customElements.get('app-cmd-palette')) {
  customElements.define('app-cmd-palette', AppCmdPalette);
}
