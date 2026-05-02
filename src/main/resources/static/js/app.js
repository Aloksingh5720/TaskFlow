(function () {
  /* ---- Force refresh on browser back/forward ------------ */
  function isBackForwardNavigation(event) {
    if (event && event.persisted) {
      return true;
    }
    const navEntries = window.performance
      ? window.performance.getEntriesByType("navigation")
      : [];
    return navEntries.length > 0 && navEntries[0].type === "back_forward";
  }

  window.addEventListener("pageshow", function (event) {
    if (isBackForwardNavigation(event)) {
      window.location.reload();
    }
  });

  /* ---- Sidebar Toggle ------------------------------------ */
  const sidebar = document.getElementById("mainSidebar");
  const appShell = document.querySelector(".app-shell");
  const mobileQuery = window.matchMedia("(max-width: 991.98px)");
  const SIDEBAR_STATE_KEY = "pm.sidebar.collapsed";
  const htmlRoot = document.documentElement;

  // Create and insert backdrop for mobile
  let backdrop = document.querySelector(".app-sidebar-backdrop");
  if (!backdrop && sidebar) {
    backdrop = document.createElement("div");
    backdrop.className = "app-sidebar-backdrop";
    document.body.appendChild(backdrop);
  }

  function openSidebar() {
    sidebar.classList.add("is-open");
    if (backdrop) backdrop.classList.add("is-open");
  }
  function closeSidebar() {
    sidebar.classList.remove("is-open");
    if (backdrop) backdrop.classList.remove("is-open");
  }

  function toggleSidebar() {
    if (!sidebar) return;
    if (mobileQuery.matches) {
      sidebar.classList.contains("is-open") ? closeSidebar() : openSidebar();
      return;
    }
    if (appShell) {
      appShell.classList.toggle("sidebar-collapsed");
      const isCollapsed = appShell.classList.contains("sidebar-collapsed");
      localStorage.setItem(SIDEBAR_STATE_KEY, isCollapsed ? "1" : "0");
      htmlRoot.classList.toggle("pref-sidebar-collapsed", isCollapsed);
    }
  }
  window.__pmToggleSidebar = function (event) {
    if (event && typeof event.preventDefault === "function") {
      event.preventDefault();
    }
    toggleSidebar();
  };

  if (sidebar) {
    // Restore desktop sidebar state after page navigation.
    if (!mobileQuery.matches && appShell) {
      const isCollapsed = localStorage.getItem(SIDEBAR_STATE_KEY) === "1";
      appShell.classList.toggle("sidebar-collapsed", isCollapsed);
      htmlRoot.classList.toggle("pref-sidebar-collapsed", isCollapsed);
    }

    sidebar
      .querySelectorAll(".sidebar-admin-toggle")
      .forEach(function (toggle) {
        toggle.addEventListener("click", function (event) {
          const isDesktopCollapsed =
            !mobileQuery.matches &&
            appShell &&
            appShell.classList.contains("sidebar-collapsed");
          if (!isDesktopCollapsed) return;

          event.preventDefault();
          event.stopPropagation();
          const targetHref = toggle.getAttribute("data-admin-default-href");
          if (targetHref) {
            window.location.href = targetHref;
          }
        });
      });

    // Delegated binding: works even if inner icon/span is clicked or header is re-rendered.
    document.addEventListener("click", function (event) {
      const trigger = event.target.closest("[data-sidebar-toggle]");
      if (!trigger) return;
      window.__pmToggleSidebar(event);
    });

    if (backdrop) {
      backdrop.addEventListener("click", closeSidebar);
    }
  }

  /* ---- Active Nav Detection ----------------------------- */
  if (sidebar) {
    const currentPathWithQuery =
      window.location.pathname + window.location.search;
    sidebar.querySelectorAll(".nav-link").forEach(function (link) {
      const href = link.getAttribute("href");
      if (!href || href === "#") return;

      const linkUrl = new URL(href, window.location.origin);
      const linkPathWithQuery = linkUrl.pathname + linkUrl.search;

      if (linkPathWithQuery === currentPathWithQuery) {
        link.classList.add("active");
      }
    });

    const adminMenu = sidebar.querySelector("#adminMenu");
    const adminToggle = sidebar.querySelector(".sidebar-admin-toggle");
    const hasActiveAdminChild = !!(
      adminMenu && adminMenu.querySelector(".sidebar-subnav .nav-link.active")
    );
    const isDesktopCollapsed =
      !mobileQuery.matches &&
      appShell &&
      appShell.classList.contains("sidebar-collapsed");

    if (adminToggle && hasActiveAdminChild) {
      adminToggle.classList.add("active");
      adminToggle.setAttribute(
        "aria-expanded",
        isDesktopCollapsed ? "false" : "true",
      );
    }
    if (adminMenu && hasActiveAdminChild && !isDesktopCollapsed) {
      adminMenu.classList.add("show");
    }
  }

  /* ---- Wrap naked tables --------------------------------- */
  const contentContainer = document.querySelector(".content-container");
  if (contentContainer) {
    contentContainer.querySelectorAll("table.table").forEach(function (table) {
      const parent = table.parentElement;
      if (
        parent &&
        (parent.classList.contains("table-responsive") ||
          parent.classList.contains("table-shell"))
      )
        return;
      const wrapper = document.createElement("div");
      wrapper.className = "table-shell mb-4";
      table.parentNode.insertBefore(wrapper, table);
      wrapper.appendChild(table);
    });

    /* Pagination align */
    contentContainer.querySelectorAll(".pagination").forEach(function (p) {
      p.classList.add("justify-content-end");
    });
  }

  /* ---- Ripple Effect on Buttons ------------------------- */
  function addRipple(e) {
    const btn = e.currentTarget;
    const circle = document.createElement("span");
    const rect = btn.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    const x = e.clientX - rect.left - size / 2;
    const y = e.clientY - rect.top - size / 2;
    circle.className = "ripple-wave";
    circle.style.cssText = `width:${size}px;height:${size}px;left:${x}px;top:${y}px`;
    btn.classList.add("ripple-container");
    // Remove existing ripples
    btn.querySelectorAll(".ripple-wave").forEach((r) => r.remove());
    btn.appendChild(circle);
    circle.addEventListener("animationend", () => circle.remove());
  }
  document.querySelectorAll(".btn").forEach(function (btn) {
    btn.addEventListener("click", addRipple);
  });

  /* ---- Toast init -------------------------------------- */
  if (window.bootstrap && bootstrap.Toast) {
    document.querySelectorAll(".app-toast-container .toast").forEach(function (el) {
      bootstrap.Toast.getOrCreateInstance(el, {
        delay: parseInt(el.dataset.bsDelay, 10) || 5000,
      }).show();
    });
  }

  /* ---- Tooltip init (if any [data-bs-toggle="tooltip"]) - */
  if (window.bootstrap && bootstrap.Tooltip) {
    document
      .querySelectorAll('[data-bs-toggle="tooltip"]')
      .forEach(function (el) {
        new bootstrap.Tooltip(el);
      });
  }
})();
