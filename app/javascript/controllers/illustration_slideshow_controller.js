import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="illustration-slideshow"
export default class extends Controller {
  static targets = ["image", "step"]
  static values = {
    images: Array,
    keyVisual: String,       // ★追加：カウントダウン終了後に戻すキービジュアル
    interval: { type: Number, default: 5 }, // 1枚あたりの表示秒数
    loops: { type: Number, default: 1 }     // ★追加：全ステップを何周させるか
  }

  connect() {
    this.tickIndex = 0
    this.timerId = null
  }

  disconnect() {
    this.clearTimer()
  }

  start() {
    if (this.timerId) return // 二重start防止

    this.tickIndex = 0
    this.showStep(0)

    const totalTicks = this.imagesValue.length * this.loopsValue

    this.timerId = setInterval(() => {
      this.tickIndex += 1

      if (this.tickIndex >= totalTicks) {
        this.clearTimer()
        return // ★変更：ここでは戻さない。キービジュアルへの復帰は countdown-timer:complete 側（stop）に任せる
      }

      const stepIndex = this.tickIndex % this.imagesValue.length
      this.showStep(stepIndex)
    }, this.intervalValue * 1000)
  }

  // カウントダウン完了・中止時（countdown-timer:complete）
  stop() {
    this.clearTimer()
    this.revertToKeyVisual() // ★キービジュアルに戻す
  }

  // カウントダウンリセット時（countdown-timer:reset）
  reset() {
    this.clearTimer()
    this.tickIndex = 0
    this.revertToKeyVisual()
  }

  clearTimer() {
    if (this.timerId) {
      clearInterval(this.timerId)
      this.timerId = null
    }
  }

  showStep(index) {
    this.fadeToImage(this.imagesValue[index])
    this.highlightStep(index)
  }

  revertToKeyVisual() {
    this.fadeToImage(this.keyVisualValue)
    this.highlightStep(-1) // どのstepもハイライトしない
  }

  // ★フェード切り替え
  fadeToImage(src) {
    if (this.imageTarget.src.endsWith(src)) return // 同じ画像なら何もしない

    this.imageTarget.classList.add("opacity-0")

    setTimeout(() => {
      this.imageTarget.src = src
      this.imageTarget.classList.remove("opacity-0")
    }, 200) // CSS側のtransition-duration(200ms)と合わせる
  }

  // ★ハイライトを強調
  highlightStep(activeIndex) {
    this.stepTargets.forEach((el, index) => {
      if (index === activeIndex) {
        el.classList.add("bg-primary", "text-primary-content", "font-bold", "shadow-md", "scale-[1.02]")
      } else {
        el.classList.remove("bg-primary", "text-primary-content", "font-bold", "shadow-md", "scale-[1.02]")
      }
    })
  }
}
