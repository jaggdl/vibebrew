import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
    this.files = new DataTransfer()
  }

  select(event) {
    const newFiles = Array.from(event.target.files)

    newFiles.forEach(file => {
      if (file.type.startsWith("image/")) {
        this.files.items.add(file)
        this.addPreview(file)
      }
    })

    this.inputTarget.files = this.files.files
  }

  addPreview(file) {
    const reader = new FileReader()

    reader.onload = (e) => {
      const wrapper = document.createElement("div")
      wrapper.className = "relative group"
      wrapper.dataset.fileName = file.name
      wrapper.dataset.fileSize = file.size

      wrapper.innerHTML = `
        <img src="${e.target.result}" class="h-24 w-24 object-cover rounded-lg border border-gray-200" />
        <button type="button"
                data-action="image-preview#remove"
                class="absolute -top-2 -right-2 bg-red-500 hover:bg-red-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold shadow-md">
          &times;
        </button>
      `

      this.previewTarget.appendChild(wrapper)
    }

    reader.readAsDataURL(file)
  }

  remove(event) {
    const wrapper = event.target.closest("[data-file-name]")
    const fileName = wrapper.dataset.fileName
    const fileSize = parseInt(wrapper.dataset.fileSize)

    const newFiles = new DataTransfer()

    Array.from(this.files.files).forEach(file => {
      if (!(file.name === fileName && file.size === fileSize)) {
        newFiles.items.add(file)
      }
    })

    this.files = newFiles
    this.inputTarget.files = this.files.files
    wrapper.remove()
  }
}
