import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "prompt"]
  static values = {
    aeropressUrl: String,
    v60Url: String
  }

  updateAction(event) {
    const method = event.target.value
    if (method === "aeropress") {
      this.formTarget.action = this.aeropressUrlValue
      this.promptTarget.name = "aeropress_recipe[prompt]"
    } else {
      this.formTarget.action = this.v60UrlValue
      this.promptTarget.name = "v60_recipe[prompt]"
    }
  }
}
