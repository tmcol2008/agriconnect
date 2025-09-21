// Utility functions for Uganda Land Management System

// Date and time utilities
const DateUtils = {
  formatDate(date, format = "YYYY-MM-DD") {
    const d = new Date(date)
    const year = d.getFullYear()
    const month = String(d.getMonth() + 1).padStart(2, "0")
    const day = String(d.getDate()).padStart(2, "0")

    switch (format) {
      case "YYYY-MM-DD":
        return `${year}-${month}-${day}`
      case "DD/MM/YYYY":
        return `${day}/${month}/${year}`
      case "MMM DD, YYYY":
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return `${months[d.getMonth()]} ${day}, ${year}`
      default:
        return d.toLocaleDateString()
    }
  },

  formatDateTime(date) {
    const d = new Date(date)
    return `${this.formatDate(d)} ${d.toLocaleTimeString()}`
  },

  getRelativeTime(date) {
    const now = new Date()
    const diff = now - new Date(date)
    const seconds = Math.floor(diff / 1000)
    const minutes = Math.floor(seconds / 60)
    const hours = Math.floor(minutes / 60)
    const days = Math.floor(hours / 24)

    if (days > 0) return `${days} day${days > 1 ? "s" : ""} ago`
    if (hours > 0) return `${hours} hour${hours > 1 ? "s" : ""} ago`
    if (minutes > 0) return `${minutes} minute${minutes > 1 ? "s" : ""} ago`
    return "Just now"
  },
}

// Form validation utilities
const FormUtils = {
  validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return re.test(email)
  },

  validatePhone(phone) {
    // Uganda phone number format: +256XXXXXXXXX or 0XXXXXXXXX
    const re = /^(\+256|0)[0-9]{9}$/
    return re.test(phone.replace(/\s/g, ""))
  },

  validateRequired(value) {
    return value && value.trim().length > 0
  },

  validateMinLength(value, minLength) {
    return value && value.length >= minLength
  },

  showFieldError(fieldId, message) {
    const field = document.getElementById(fieldId)
    if (!field) return

    // Remove existing error
    const existingError = field.parentNode.querySelector(".field-error")
    if (existingError) {
      existingError.remove()
    }

    // Add error message
    const errorDiv = document.createElement("div")
    errorDiv.className = "field-error"
    errorDiv.style.cssText = `
            color: var(--destructive);
            font-size: 0.875rem;
            margin-top: 0.25rem;
        `
    errorDiv.textContent = message

    field.parentNode.appendChild(errorDiv)
    field.style.borderColor = "var(--destructive)"
  },

  clearFieldError(fieldId) {
    const field = document.getElementById(fieldId)
    if (!field) return

    const errorDiv = field.parentNode.querySelector(".field-error")
    if (errorDiv) {
      errorDiv.remove()
    }
    field.style.borderColor = ""
  },

  validateForm(formId, rules) {
    const form = document.getElementById(formId)
    if (!form) return false

    let isValid = true

    for (const [fieldId, fieldRules] of Object.entries(rules)) {
      const field = document.getElementById(fieldId)
      if (!field) continue

      const value = field.value
      this.clearFieldError(fieldId)

      for (const rule of fieldRules) {
        if (rule.type === "required" && !this.validateRequired(value)) {
          this.showFieldError(fieldId, rule.message || "This field is required")
          isValid = false
          break
        } else if (rule.type === "email" && value && !this.validateEmail(value)) {
          this.showFieldError(fieldId, rule.message || "Please enter a valid email address")
          isValid = false
          break
        } else if (rule.type === "phone" && value && !this.validatePhone(value)) {
          this.showFieldError(fieldId, rule.message || "Please enter a valid phone number")
          isValid = false
          break
        } else if (rule.type === "minLength" && value && !this.validateMinLength(value, rule.value)) {
          this.showFieldError(fieldId, rule.message || `Minimum ${rule.value} characters required`)
          isValid = false
          break
        }
      }
    }

    return isValid
  },
}

// Data formatting utilities
const DataUtils = {
  formatCurrency(amount, currency = "UGX") {
    const formatter = new Intl.NumberFormat("en-UG", {
      style: "currency",
      currency: currency,
      minimumFractionDigits: 0,
    })
    return formatter.format(amount)
  },

  formatNumber(number) {
    return new Intl.NumberFormat("en-UG").format(number)
  },

  formatFileSize(bytes) {
    if (bytes === 0) return "0 Bytes"

    const k = 1024
    const sizes = ["Bytes", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return Number.parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i]
  },

  truncateText(text, maxLength) {
    if (text.length <= maxLength) return text
    return text.substring(0, maxLength) + "..."
  },

  capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1)
  },

  formatUserType(userType) {
    return userType.replace("_", " ").replace(/\b\w/g, (l) => l.toUpperCase())
  },
}

// Local storage utilities
const StorageUtils = {
  set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value))
      return true
    } catch (e) {
      console.error("Error saving to localStorage:", e)
      return false
    }
  },

  get(key, defaultValue = null) {
    try {
      const item = localStorage.getItem(key)
      return item ? JSON.parse(item) : defaultValue
    } catch (e) {
      console.error("Error reading from localStorage:", e)
      return defaultValue
    }
  },

  remove(key) {
    try {
      localStorage.removeItem(key)
      return true
    } catch (e) {
      console.error("Error removing from localStorage:", e)
      return false
    }
  },

  clear() {
    try {
      localStorage.clear()
      return true
    } catch (e) {
      console.error("Error clearing localStorage:", e)
      return false
    }
  },
}

// Notification utilities
const NotificationUtils = {
  show(message, type = "info", duration = 5000) {
    // Remove existing notifications
    const existing = document.querySelectorAll(".notification")
    existing.forEach((n) => n.remove())

    // Create notification element
    const notification = document.createElement("div")
    notification.className = `notification notification-${type}`
    notification.style.cssText = `
            position: fixed;
            top: 2rem;
            right: 2rem;
            z-index: 10000;
            padding: 1rem 1.5rem;
            border-radius: var(--radius);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
            max-width: 400px;
            animation: slideIn 0.3s ease-out;
        `

    // Set colors based on type
    const colors = {
      success: { bg: "#f0fdf4", border: "#bbf7d0", text: "#166534" },
      error: { bg: "#fef2f2", border: "#fecaca", text: "#991b1b" },
      warning: { bg: "#fffbeb", border: "#fed7aa", text: "#92400e" },
      info: { bg: "#eff6ff", border: "#bfdbfe", text: "#1e40af" },
    }

    const color = colors[type] || colors.info
    notification.style.backgroundColor = color.bg
    notification.style.borderLeft = `4px solid ${color.border}`
    notification.style.color = color.text

    notification.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <span>${message}</span>
                <button onclick="this.parentElement.parentElement.remove()" 
                        style="background: none; border: none; font-size: 1.2rem; cursor: pointer; color: ${color.text};">×</button>
            </div>
        `

    document.body.appendChild(notification)

    // Auto remove after duration
    if (duration > 0) {
      setTimeout(() => {
        if (notification.parentNode) {
          notification.remove()
        }
      }, duration)
    }
  },

  success(message, duration) {
    this.show(message, "success", duration)
  },

  error(message, duration) {
    this.show(message, "error", duration)
  },

  warning(message, duration) {
    this.show(message, "warning", duration)
  },

  info(message, duration) {
    this.show(message, "info", duration)
  },
}

// Add notification animation styles
const notificationStyles = document.createElement("style")
notificationStyles.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    .notification {
        animation: slideIn 0.3s ease-out;
    }
`
document.head.appendChild(notificationStyles)

// Export utilities for use in other scripts
window.DateUtils = DateUtils
window.FormUtils = FormUtils
window.DataUtils = DataUtils
window.StorageUtils = StorageUtils
window.NotificationUtils = NotificationUtils
