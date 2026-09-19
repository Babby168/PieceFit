// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Google Analytics のページビューイベントを送信する
document.addEventListener("turbo:load", () => {
  if (typeof window.gtag !== "function") return

  window.gtag("event", "page_view", {
    page_title: document.title,
    page_location: window.location.href,
    page_path: window.location.pathname
  })
})
