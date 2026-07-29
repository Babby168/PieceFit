import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stretch-log"
export default class extends Controller {
  static values = { stretchId: Number }

  connect() {
    window.addEventListener("countdown-timer:complete", this.recordLog.bind(this))
  }

  disconnect() {
    window.removeEventListener("countdown-timer:complete", this.recordLog.bind(this))
  }

  recordLog() {
    fetch(`/stretch_logs?stretch_id=${this.stretchIdValue}`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
    })
  }
}
