// Runtime UI Geometry & Anti-Breakage Health Probe (Nov-XS)
// Detects horizontal overflow, off-screen clipping, overlapping controls, <44px touch targets, and overlay collisions.

export const UiHealthProbe = {
  runAudit() {
    const issues = [];

    // 1. Check horizontal viewport overflow
    const docWidth = document.documentElement.scrollWidth;
    const winWidth = document.documentElement.clientWidth;
    if (docWidth > winWidth + 1) {
      issues.push({
        type: 'HORIZONTAL_OVERFLOW',
        detail: `Document scrollWidth (${docWidth}px) exceeds viewport (${winWidth}px).`
      });
    }

    // 2. Check visible interactive elements for off-screen bounds, <44px touch target & bounding-box collisions
    const controls = Array.from(
      document.querySelectorAll('button, a[href], input, select, textarea, [role="button"]')
    ).filter((el) => {
      const style = window.getComputedStyle(el);
      const rect = el.getBoundingClientRect();
      return style.display !== 'none' && style.visibility !== 'hidden' && rect.width > 0 && rect.height > 0;
    });

    const rects = controls.map((el) => ({ el, rect: el.getBoundingClientRect() }));

    for (let i = 0; i < rects.length; i++) {
      const { el, rect } = rects[i];
      if (rect.right > winWidth + 1 || rect.left < -1) {
        issues.push({
          type: 'HORIZONTAL_OVERFLOW',
          detail: `<${el.tagName.toLowerCase()}> extends outside horizontal viewport (${Math.round(rect.left)}px..${Math.round(rect.right)}px vs ${winWidth}px).`
        });
      }

      if (rect.height < 44 || rect.width < 44) {
        issues.push({
          type: 'SMALL_TOUCH_TARGET',
          detail: `<${el.tagName.toLowerCase()}> (${Math.round(rect.width)}x${Math.round(rect.height)}px) is below 44px target.`
        });
      }

      for (let j = i + 1; j < rects.length; j++) {
        const other = rects[j];
        if (el.contains(other.el) || other.el.contains(el)) continue;

        const overlapX = Math.max(0, Math.min(rect.right, other.rect.right) - Math.max(rect.left, other.rect.left));
        const overlapY = Math.max(0, Math.min(rect.bottom, other.rect.bottom) - Math.max(rect.top, other.rect.top));
        if (overlapX > 4 && overlapY > 4) {
          issues.push({
            type: 'ELEMENT_OVERLAP',
            detail: `Interactive elements <${el.tagName.toLowerCase()}> and <${other.el.tagName.toLowerCase()}> overlap by ${Math.round(overlapX)}x${Math.round(overlapY)}px.`
          });
        }
      }
    }

    // 3. Check Top-Layer exclusivity (at most 1 open dialog)
    const openDialogs = document.querySelectorAll('dialog[open]');
    if (openDialogs.length > 1) {
      issues.push({
        type: 'TOP_LAYER_COLLISION',
        detail: `${openDialogs.length} <dialog> elements are open simultaneously.`
      });
    }

    return {
      passed: issues.length === 0,
      viewport: `${winWidth}x${document.documentElement.clientHeight}`,
      interactiveCount: controls.length,
      issues
    };
  }
};

window.UiHealthProbe = UiHealthProbe;
