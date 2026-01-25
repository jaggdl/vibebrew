import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progress"]
  static values = {
    autoClose: { type: Number, default: 5000 }
  }

  connect() {
    if (this.autoCloseValue > 0) {
      this.startProgressBar()
      this.timeout = setTimeout(() => this.close(), this.autoCloseValue)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  startProgressBar() {
    if (this.hasProgressTarget) {
      this.progressTarget.style.transition = `width ${this.autoCloseValue}ms linear`
      requestAnimationFrame(() => {
        this.progressTarget.style.width = "0%"
      })
    }
  }

  close() {
    this.element.classList.add("opacity-0", "transition-opacity", "duration-300")
    setTimeout(() => this.element.remove(), 300)
  }
}
