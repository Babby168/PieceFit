import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"
import "./controllers"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

document.addEventListener("turbo:load", () => {
  if (typeof window.gtag !== "function") return

  window.gtag("event", "page_view", {
    page_title: document.title,
    page_location: window.location.href,
    page_path: window.location.pathname
  })
})
