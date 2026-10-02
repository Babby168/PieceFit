import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stretch-log-dialog"
export default class extends Controller {
  static targets = [
    "completeDialog",
    "delayButton", "scheduleButton",
    "reminderStep", "destinationStep", "reminderResult"
  ]
  static values  = { stretchId: Number, signedIn: Boolean }

  // コンテキストが読み込まれたらカウントダウンタイマーが完了したらストレッチ実施完了ダイアログを表示するイベントリスナーを追加
  connect() {
    window.addEventListener("countdown-timer:complete", this.openCompleteDialogFromEvent)

    // リマインドの選択状態（まだ何も選ばれていない状態から始める）
    this.selectedSeconds = null
    this.selectedLabel = ""
  }

  // コンテキストが破棄されたらカウントダウンタイマーが完了したらストレッチ実施完了ダイアログを表示するイベントリスナーを削除
  disconnect() {
    window.removeEventListener("countdown-timer:complete", this.openCompleteDialogFromEvent)
  }

  // カウントダウンタイマーが完了したらストレッチ実施完了ダイアログを表示するメソッド
  openCompleteDialogFromEvent = () => {
    this.completeDialogTarget.showModal()
  }

  // ストレッチ実施記録を保存して、指定されたページへ移動するメソッド
  recordAndRedirect(event) {
    // 押されたボタンに指定があればそこへ。無ければ従来通りの遷移先
    const destination = event.currentTarget.dataset.destination

    // ログインしていない場合は記録せずに移動する
    if (!this.signedInValue) {
      window.Turbo.visit(destination || "/stretches")
      return
    }

    // ログインしている場合はストレッチ実施記録を保存してから移動する
    fetch(`/stretch_logs?stretch_id=${this.stretchIdValue}`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html",
      },
    }).then(async (response) => {
      if (!response.ok) return

      const html = await response.text()
      if (html) window.Turbo.renderStreamMessage(html)

      window.Turbo.visit(destination || "/mypage")
    })
  }

  // リマインド通知
  // 押された時間ボタンを覚えて、選択状態を塗りで示す
  selectDelay(event) {
    const button = event.currentTarget
    this.selectedSeconds = Number(button.dataset.seconds)
    this.selectedLabel = button.dataset.label

    // 選択中のボタンだけ塗りつぶし、それ以外は白抜きに戻す
    this.delayButtonTargets.forEach((target) => {
      const selected = target === button
      target.classList.toggle("btn-primary", selected)
      target.classList.toggle("btn-outline", !selected)
    })

    this.scheduleButtonTarget.disabled = false
  }

  // 通知の許可を求めて、予約を localStorage に保存する
  async scheduleReminder() {
    if (!this.selectedSeconds) return

    if (!("Notification" in window)) {
      this.showDestinationStep("このブラウザは通知に対応していません")
      return
    }

    // 許可ダイアログはユーザー操作の中でしか出せないため、この瞬間に要求する
    const permission = await Notification.requestPermission()
    if (permission !== "granted") {
      this.showDestinationStep("ブラウザの通知がブロックされているため設定できませんでした")
      return
    }

    // 予約は常に1件だけ。設定し直すと上書きされる
    localStorage.setItem("piecefit:reminder", JSON.stringify({
      fireAt: Date.now() + this.selectedSeconds * 1000,
    }))
    // すでに動いている見張りに「新しい予約が入った」と伝える
    window.dispatchEvent(new CustomEvent("piecefit:reminder-scheduled"))

    this.showDestinationStep(`${this.selectedLabel}にお知らせします`)
  }

  // リマインドを設定せずに移動先の選択へ進む
  skipReminder() {
    this.showDestinationStep("リマインドは設定しませんでした")
  }

  // 第1段を隠して第2段を表示する
  showDestinationStep(message) {
    this.reminderResultTarget.textContent = message
    this.reminderStepTarget.classList.add("hidden")
    this.destinationStepTarget.classList.remove("hidden")
  }
}
