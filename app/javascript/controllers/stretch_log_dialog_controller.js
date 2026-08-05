import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stretch-log-dialog"
export default class extends Controller {
  static targets = ["completeDialog", "abortDialog"]
  static values  = { stretchId: Number }

  connect() {
    window.addEventListener("countdown-timer:complete", this.openCompleteDialogFromEvent)
  }

  disconnect() {
    window.removeEventListener("countdown-timer:complete", this.openCompleteDialogFromEvent)
  }

  openCompleteDialogFromEvent = () => {
    this.completeDialogTarget.showModal()
  }

  openAbortConfirm() {
    this.abortDialogTarget.showModal()
  }

  closeAbortConfirm() {
    this.abortDialogTarget.close()
  }

  recordAndRedirect() {
    fetch(`/stretch_logs?stretch_id=${this.stretchIdValue}`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
    }).then(async(response) => {
      if (!response.ok) return

      const html = await response.text()
      if (html) window.Turbo.renderStreamMessage(html)

      window.Turbo.visit("/mypage")
    })
  }
}
