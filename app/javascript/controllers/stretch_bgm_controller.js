import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "piecefit-bgm-muted"
const DEFAULT_VOLUME = 0.1

// Connects to data-controller="stretch-bgm"
export default class extends Controller {
  static targets = ["player", "muteButton", "unmutedIcon", "mutedIcon"]

 // ページ読み込み時に実行
  connect() {
    // デフォルトの音量を設定
    this.playerTarget.volume = DEFAULT_VOLUME
    // ミュート状態を適用
    this.applyMuted(this.readMuted())
  }

  // ページ離れ時に実行
  disconnect() {
    // 停止
    this.stop()
  }

  // 再生
  play() {
    // 再生位置を先頭に戻す
    this.playerTarget.currentTime = 0
    // playPromise 変数に再生を試みた結果を代入
    const playPromise = this.playerTarget.play()
    // playPromise が存在し、catch メソッドが存在する場合、catch メソッドを実行
    if (playPromise?.catch) playPromise.catch(() => {})
  }

  // 停止
  stop() {
    // 停止する
    this.playerTarget.pause()
    // 再生位置を先頭に戻す
    this.playerTarget.currentTime = 0
  }

  // ミュート/ミュート解除の切り替え
  toggleMute() {
    // ミュート状態を切り替えて適用
    this.applyMuted(!this.playerTarget.muted)
  }

  // ミュート状態を読み込む
  readMuted() {
    // ローカルストレージに window 経由でアクセスして、STORAGE_KEY の値を取得して、それが "true" の場合は true を返す
    return window.localStorage.getItem( STORAGE_KEY) === "true"
  }

  // ミュート状態を適用する
  applyMuted(muted) {
    // ミュート状態を適用
    this.playerTarget.muted = muted
    // ミュート状態をローカルストレージに保存
    window.localStorage.setItem(STORAGE_KEY, String(muted))

    // ミュート解除アイコンを表示/非表示
    this.unmutedIconTarget.classList.toggle("hidden", muted)
    // ミュートアイコンを表示/非表示
    this.mutedIconTarget.classList.toggle("hidden", !muted)
    // ミュートボタンの aria-pressed 属性を適用
    this.muteButtonTarget.setAttribute("aria-pressed", String(muted))
  }
}
