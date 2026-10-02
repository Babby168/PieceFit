import { Controller } from "@hotwired/stimulus"

// localStorage のキー / 通知中のタブタイトル
const STORAGE_KEY = "piecefit:reminder"
const NOTIFIED_TITLE = "⏰ そろそろストレッチ | PieceFit"
// 予約がないとき、または予約が遠いときの見直し間隔
const MAX_WAIT_MS = 30000
// 通知から戻る先（もう一度ストレッチしてもらうため部位選択に固定）
const REMINDER_DESTINATION = "/stretches"

// Connects to data-controller="reminder"
export default class extends Controller {
  static targets = [ "banner", "bannerTitle", "bannerBody" ]
  static values = { messageUrl: String }

  connect() {
    this.originalTitle = document.title

    // タブに戻ってきた時にも確認する（間引きで遅れた分をすぐ拾うため）
    this.handleVisibilityChange = () => {
      if (document.visibilityState !== "visible") return
      this.restoreTitle()
      this.tick()
    }
    document.addEventListener("visibilitychange", this.handleVisibilityChange)

    // 完了ダイアログで予約が入った直後に、残り時間ぴったりで起き直す
    this.handleReminderScheduled = () => this.tick()
    window.addEventListener("piecefit:reminder-scheduled", this.handleReminderScheduled)

    this.tick()
  }

  disconnect() {
    clearTimeout(this.timeoutId)
    document.removeEventListener("visibilitychange", this.handleVisibilityChange)
    window.removeEventListener("piecefit:reminder-scheduled", this.handleReminderScheduled)
  }

  // 予約を確認して、次の確認を予約し直す
  tick() {
    this.check()
    this.scheduleNextCheck()
  }

  // 次の確認までの待ち時間を決める（予約時刻までちょうど待つ／遠いときは30秒で見直す）
  scheduleNextCheck() {
    clearTimeout(this.timeoutId)

    const reminder = this.readReminder()
    const remaining = reminder ? reminder.fireAt - Date.now() : MAX_WAIT_MS
    const wait = Math.min(Math.max(remaining, 0), MAX_WAIT_MS)

    this.timeoutId = setTimeout(() => this.tick(), wait)
  }

  // 予約時刻を過ぎていたら通知する
  check() {
    const reminder = this.readReminder()
    if (!reminder) return
    if (Date.now() < reminder.fireAt) return

    // 先に消してから通知する（二重に発火させないため）
    localStorage.removeItem(STORAGE_KEY)
    this.notify()
  }

  // 予約内容を読み出す（壊れた値が入っていても落ちないようにする）
  readReminder() {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return null

    try {
      const reminder = JSON.parse(raw)
      return reminder.fireAt ? reminder : null
    } catch {
      localStorage.removeItem(STORAGE_KEY)
      return null
    }
  }

  // 文面をサーバーから取得して通知を出す
  async notify() {
    const response = await fetch(this.messageUrlValue, {
      headers: { "Accept": "application/json" },
    })
    // 204（送る文面がない）やエラーのときは何もしない
    if (response.status !== 200) return

    const message = await response.json()

    // タブのタイトルでも気付けるようにする
    document.title = NOTIFIED_TITLE

    // 画面内バナーは常に表示する（OS通知が静かに消えても気付けるようにするため）
    this.showBanner(message)

    // 通知が使える環境なら、上乗せでOS通知も出す
    if (!("Notification" in window) || Notification.permission !== "granted") return

    try {
      const notification = new Notification(message.title, {
        body: message.body,
        icon: "/icon.png",
        tag: "piecefit-reminder", // 複数タブで開いていても通知を1つにまとめる
      })
      notification.onclick = () => {
        window.focus()
        notification.close()
        this.restoreTitle()
        window.Turbo.visit(REMINDER_DESTINATION)
      }
    } catch {
      // スマホのChromeなど、ページから通知を作れない環境では画面内バナーだけで知らせる
    }
  }

  // 画面内バナーを表示する
  showBanner(message) {
    this.bannerTitleTarget.textContent = message.title
    this.bannerBodyTarget.textContent = message.body
    this.bannerTarget.classList.remove("hidden")
  }

  // 画面内バナーを閉じる
  closeBanner() {
    this.bannerTarget.classList.add("hidden")
    this.restoreTitle()
  }

  // 書き換えたタブタイトルを元に戻す
  restoreTitle() {
    if (document.title === NOTIFIED_TITLE) document.title = this.originalTitle
  }
}
