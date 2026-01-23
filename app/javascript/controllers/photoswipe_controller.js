import { Controller } from "@hotwired/stimulus"
import PhotoSwipeLightbox from "photoswipe/lightbox"

export default class extends Controller {
  connect() {
    this.lightbox = new PhotoSwipeLightbox({
      gallery: this.element,
      children: "a",
      pswpModule: () => import("photoswipe")
    })

    this.lightbox.init()
  }

  disconnect() {
    if (this.lightbox) {
      this.lightbox.destroy()
      this.lightbox = null
    }
  }
}
