import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stretch-log-dialog"
export default class extends Controller {
  static targets = ["completeDialog", "abortDialog"]
  static values  = { stretchId: Number, signedIn: Boolean }

  // コンテキストが読み込まれたらカウントダウンタイマーが完了したらストレッチ実施完了ダイアログを表示するイベントリスナーを追加
  connect() {
    window.addEventListener("countdown-timer:complete", this.openCompleteDialogFromEvent)
  }

  // コンテキストが破棄されたらカウントダウンタイマーが完了したらストレッチ実施完了ダイアログを表示するイベントリスナーを削除
  disconnect() {
    window.removeEventListener("countdown-timer:complete", this.openCompleteDialogFromEvent)
  }

  // カウントダウンタイマーが完了したらストレッチ実施完了ダイアログを表示するメソッド
  openCompleteDialogFromEvent = () => {
    this.completeDialogTarget.showModal()
  }

  // ストレッチ実施中止確認ダイアログを表示するメソッド
  openAbortConfirm() {
    this.abortDialogTarget.showModal()
  }

  // ストレッチ実施中止確認ダイアログを閉じるメソッド
  closeAbortConfirm() {
    this.abortDialogTarget.close()
  }

  // ストレッチ実施記録を保存し、マイページにリダイレクトするメソッド
  recordAndRedirect() {
    // ログインしていない場合は部位選択ページにリダイレクト
    if (!this.signedInValue) {
      window.Turbo.visit("/stretches")
      return
    }

    // ログインしている場合はストレッチ実施記録を保存し、マイページにリダイレクト
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

      window.Turbo.visit("/mypage")
    })
  }
}
