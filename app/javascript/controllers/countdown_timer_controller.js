import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="countdown-timer"
export default class extends Controller {
  static targets = ["time", "startButton", "abortButton"]
  static values  = { duration: { type: Number, default: 60 } }

  connect() {
    // 初期表示
    this.remainingSeconds = this.durationValue
    this.timerId = null
    this.updateDisplay()
  }

  disconnect() {
    this.clearTimer()
  }

  start() {
    // スタート処理
    if (this.timerId) return // 二重start防止

    this.startButtonTarget.classList.add("hidden") // スタートボタンを非表示
    this.abortButtonTarget.classList.remove("hidden") // 中止ボタンを表示

    this.timerId = setInterval(() => {
      this.remainingSeconds -= 1 // 1秒ごとにカウントダウン
      this.updateDisplay() // 表示を更新

      if (this.remainingSeconds <= 0) { // カウントダウンが0になったら
        this.complete() // 完了処理
      }
    }, 1000) // 1秒ごとにカウントダウン
  }

  reset() {
    // リセット処理
    this.clearTimer()
    this.remainingSeconds = this.durationValue
    this.updateDisplay()

    this.startButtonTarget.classList.remove("hidden") // スタートボタンを表示
    this.abortButtonTarget.classList.add("hidden") // 中止ボタンを非表示
  }

  complete() {
    // 中止処理
    this.clearTimer()
    this.remainingSeconds = 0
    this.updateDisplay()

    this.startButtonTarget.classList.add("hidden") // スタートボタンを非表示
    this.abortButtonTarget.classList.add("hidden") // 中止ボタンを非表示
    this.timeTarget.textContent = "完了！"
  }

  clearTimer() {
    if (this.timerId) {
      clearInterval(this.timerId)
      this.timerId = null
    }
  }

  updateDisplay() {
    const minutes = Math.floor(this.remainingSeconds / 60)
    const seconds = this.remainingSeconds % 60
    const formatted = `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`
    this.timeTarget.textContent = formatted
  }
}
