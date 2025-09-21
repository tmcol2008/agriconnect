// Navigation and routing utilities for Uganda Land Management System

// Declare the auth variable before using it
const auth = {
  getCurrentUser: () => {
    // Placeholder for actual authentication logic
    return { userType: "citizen" } // Example user type
  },
  logout: () => {
    // Placeholder for actual logout logic
    window.location.href = "../index.html"
  },
}

class NavigationManager {
  constructor() {
    this.currentPage = null
    this.breadcrumbs = []
    this.init()
  }

  init() {
    // Set current page based on URL
    const path = window.location.pathname
    const page = path.split("/").pop().replace(".html", "")
    this.currentPage = page || "index"

    // Initialize mobile navigation
    this.initMobileNavigation()

    // Initialize breadcrumbs
    this.updateBreadcrumbs()
  }

  initMobileNavigation() {
    // Create mobile menu toggle button
    const sidebar = document.querySelector(".sidebar")
    if (sidebar && window.innerWidth <= 768) {
      const toggleButton = document.createElement("button")
      toggleButton.innerHTML = "☰"
      toggleButton.className = "mobile-menu-toggle"
      toggleButton.style.cssText = `
                position: fixed;
                top: 1rem;
                left: 1rem;
                z-index: 1000;
                background: var(--primary);
                color: var(--primary-foreground);
                border: none;
                padding: 0.5rem;
                border-radius: var(--radius);
                font-size: 1.2rem;
                cursor: pointer;
            `

      toggleButton.addEventListener("click", () => {
        sidebar.classList.toggle("open")
      })

      document.body.appendChild(toggleButton)

      // Close sidebar when clicking outside
      document.addEventListener("click", (e) => {
        if (!sidebar.contains(e.target) && !toggleButton.contains(e.target)) {
          sidebar.classList.remove("open")
        }
      })
    }
  }

  updateBreadcrumbs() {
    const breadcrumbContainer = document.getElementById("breadcrumbs")
    if (!breadcrumbContainer) return

    const breadcrumbs = this.generateBreadcrumbs()
    breadcrumbContainer.innerHTML = breadcrumbs
      .map((crumb, index) => {
        if (index === breadcrumbs.length - 1) {
          return `<span class="breadcrumb-current">${crumb.title}</span>`
        }
        return `<a href="${crumb.url}" class="breadcrumb-link">${crumb.title}</a>`
      })
      .join(' <span class="breadcrumb-separator">></span> ')
  }

  generateBreadcrumbs() {
    const breadcrumbs = [{ title: "Home", url: "../index.html" }]

    switch (this.currentPage) {
      case "citizen":
        breadcrumbs.push({ title: "Citizen Dashboard", url: "citizen.html" })
        break
      case "government_official":
        breadcrumbs.push({ title: "Government Dashboard", url: "government_official.html" })
        break
      case "legal_aid":
        breadcrumbs.push({ title: "Legal Aid Dashboard", url: "legal_aid.html" })
        break
      case "researcher":
        breadcrumbs.push({ title: "Research Dashboard", url: "researcher.html" })
        break
      case "admin":
        breadcrumbs.push({ title: "Admin Dashboard", url: "admin.html" })
        break
    }

    return breadcrumbs
  }

  navigateTo(url) {
    window.location.href = url
  }

  goBack() {
    window.history.back()
  }

  // Quick navigation shortcuts
  goToDashboard() {
    const user = auth.getCurrentUser()
    if (user) {
      this.navigateTo(`dashboards/${user.userType}.html`)
    }
  }

  goToLogin() {
    this.navigateTo("../index.html")
  }
}

// Global navigation instance
const navigation = new NavigationManager()

// Utility functions for common navigation tasks
function quickNavigate(destination) {
  const user = auth.getCurrentUser()
  if (!user) {
    navigation.goToLogin()
    return
  }

  const routes = {
    dashboard: `dashboards/${user.userType}.html`,
    profile: `profile.html`,
    settings: `settings.html`,
    help: `help.html`,
    logout: "../index.html",
  }

  if (routes[destination]) {
    if (destination === "logout") {
      auth.logout()
    } else {
      navigation.navigateTo(routes[destination])
    }
  }
}

// Keyboard shortcuts for navigation
document.addEventListener("keydown", (e) => {
  // Only activate shortcuts when not typing in input fields
  if (e.target.tagName === "INPUT" || e.target.tagName === "TEXTAREA") {
    return
  }

  // Alt + D = Dashboard
  if (e.altKey && e.key === "d") {
    e.preventDefault()
    navigation.goToDashboard()
  }

  // Alt + L = Logout
  if (e.altKey && e.key === "l") {
    e.preventDefault()
    auth.logout()
  }

  // Alt + B = Back
  if (e.altKey && e.key === "b") {
    e.preventDefault()
    navigation.goBack()
  }
})

// Add navigation styles
const navStyles = document.createElement("style")
navStyles.textContent = `
    .breadcrumb-container {
        padding: 1rem 0;
        border-bottom: 1px solid var(--border);
        margin-bottom: 1rem;
    }
    
    .breadcrumb-link {
        color: var(--primary);
        text-decoration: none;
        font-size: 0.875rem;
    }
    
    .breadcrumb-link:hover {
        text-decoration: underline;
    }
    
    .breadcrumb-separator {
        color: var(--muted-foreground);
        margin: 0 0.5rem;
    }
    
    .breadcrumb-current {
        color: var(--foreground);
        font-weight: 500;
        font-size: 0.875rem;
    }
    
    .mobile-menu-toggle {
        display: none;
    }
    
    @media (max-width: 768px) {
        .mobile-menu-toggle {
            display: block !important;
        }
        
        .sidebar {
            transform: translateX(-100%);
            transition: transform 0.3s ease;
        }
        
        .sidebar.open {
            transform: translateX(0);
        }
        
        .main-content {
            margin-left: 0;
            padding: 1rem;
            padding-top: 4rem;
        }
    }
`
document.head.appendChild(navStyles)
