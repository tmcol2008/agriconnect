// Authentication and session management
class AuthManager {
  constructor() {
    this.currentUser = null
    this.loadCurrentUser()
  }

  loadCurrentUser() {
    const userData = localStorage.getItem("currentUser")
    if (userData) {
      this.currentUser = JSON.parse(userData)
    }
  }

  login(username, password, userType) {
    // In a real application, this would make an API call
    // For demo purposes, we'll simulate authentication
    const user = {
      id: Math.floor(Math.random() * 1000),
      username: username,
      userType: userType,
      loginTime: new Date().toISOString(),
      isAuthenticated: true,
    }

    localStorage.setItem("currentUser", JSON.stringify(user))
    this.currentUser = user
    return user
  }

  logout() {
    localStorage.removeItem("currentUser")
    this.currentUser = null
    window.location.href = "../index.html"
  }

  isAuthenticated() {
    return this.currentUser && this.currentUser.isAuthenticated
  }

  requireAuth() {
    if (!this.isAuthenticated()) {
      window.location.href = "../index.html"
      return false
    }
    return true
  }

  hasRole(role) {
    return this.currentUser && this.currentUser.userType === role
  }

  getCurrentUser() {
    return this.currentUser
  }
}

// Global auth instance
const auth = new AuthManager()

// Utility functions for dashboard pages
function initializeDashboard() {
  if (!auth.requireAuth()) {
    return
  }

  const user = auth.getCurrentUser()

  // Update user info in navigation
  const userInfo = document.getElementById("user-info")
  if (userInfo) {
    userInfo.textContent = `${user.username} (${user.userType.replace("_", " ").toUpperCase()})`
  }

  // Set active navigation item
  const currentPage = window.location.pathname.split("/").pop().replace(".html", "")
  const navLinks = document.querySelectorAll(".sidebar-nav a")
  navLinks.forEach((link) => {
    if (link.getAttribute("href").includes(currentPage)) {
      link.classList.add("active")
    }
  })
}

function logout() {
  if (confirm("Are you sure you want to logout?")) {
    auth.logout()
  }
}

// Sample data for dashboards
const sampleData = {
  landStatistics: {
    totalDisputes: 1247,
    activeDisputes: 342,
    resolvedDisputes: 905,
    landGrabbingCases: 156,
    customaryLand: 75,
    registeredLand: 30,
    displacedPersons: 360000,
  },

  recentDisputes: [
    {
      id: "LD-2024-001",
      type: "Land Grabbing",
      location: "Kampala District",
      status: "Under Investigation",
      date: "2024-01-15",
      priority: "High",
    },
    {
      id: "LD-2024-002",
      type: "Boundary Dispute",
      location: "Wakiso District",
      status: "Mediation",
      date: "2024-01-14",
      priority: "Medium",
    },
    {
      id: "LD-2024-003",
      type: "Family Wrangle",
      location: "Mukono District",
      status: "Resolved",
      date: "2024-01-13",
      priority: "Low",
    },
  ],

  tenureTypes: [
    { name: "Customary", percentage: 75, description: "Traditional community ownership" },
    { name: "Mailo", percentage: 15, description: "Dual ownership system" },
    { name: "Freehold", percentage: 8, description: "Absolute ownership" },
    { name: "Leasehold", percentage: 2, description: "Time-limited ownership" },
  ],
}
