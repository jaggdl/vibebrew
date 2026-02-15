import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["results"]

  show() {
    const frame = document.getElementById("search_results")
    if (frame) {
      frame.classList.remove("hidden")
    }
  }

  hide() {
    // Delay hiding to allow clicking on results
    setTimeout(() => {
      const frame = document.getElementById("search_results")
      if (frame) {
        frame.classList.add("hidden")
      }
    }, 200)
  }
}
