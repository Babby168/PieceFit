import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="legal-tabs"
export default class extends Controller {
  static targets = [ "tab", "panel" ]

  // タブをクリックしたら該当パネルを表示する
  select(event) {
    // クリックしたタブのパラメータを取得
    const selectedKey = event.currentTarget.dataset.legalTabsKey

    // タブをアクティブにする
    this.tabTargets.forEach((tab) => {
      const isSelected = tab.dataset.legalTabsKey === selectedKey
      tab.classList.toggle("tab-active", isSelected)
      tab.setAttribute("aria-selected", isSelected)
    })

    // パネルを表示する
    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.legalTabsKey !== selectedKey)
    })
  }
}
