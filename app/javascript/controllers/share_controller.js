import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "icon", "text"]
  static values = {
    title: String,
    text: String,
    url: String
  }

  async share() {
    const shareData = {
      title: this.titleValue || document.title,
      text: this.textValue || "",
      url: this.urlValue || window.location.href
    }

    if (navigator.share && navigator.canShare?.(shareData)) {
      try {
        await navigator.share(shareData)
      } catch (err) {
        if (err.name !== "AbortError") {
          this.copyToClipboard()
        }
      }
    } else {
      this.copyToClipboard()
    }
  }

  async copyToClipboard() {
    const url = this.urlValue || window.location.href

    try {
      await navigator.clipboard.writeText(url)
      this.showCopiedFeedback()
    } catch (err) {
      const textArea = document.createElement("textarea")
      textArea.value = url
      document.body.appendChild(textArea)
      textArea.select()
      document.execCommand("copy")
      document.body.removeChild(textArea)
      this.showCopiedFeedback()
    }
  }

  showCopiedFeedback() {
    const originalText = this.textTarget.textContent
    this.textTarget.textContent = "Copied!"
    this.buttonTarget.classList.add("text-green-600")

    setTimeout(() => {
      this.textTarget.textContent = originalText
      this.buttonTarget.classList.remove("text-green-600")
    }, 2000)
  }
}
