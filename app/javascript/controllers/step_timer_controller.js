import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progressBar", "currentStep", "currentTime", "playIcon", "pauseIcon", "stepRow"]
  static values = {
    steps: Array,
    currentIndex: { type: Number, default: -1 },
    elapsed: { type: Number, default: 0 },
    playing: { type: Boolean, default: false }
  }

  connect() {
    this.interval = null
    this.timedStepIndices = this.stepsValue
      .map((step, index) => step.time > 0 ? index : null)
      .filter(index => index !== null)

    if (this.timedStepIndices.length > 0) {
      this.currentIndexValue = this.timedStepIndices[0]
      this.updateDisplay()
    }
  }

  disconnect() {
    this.stop()
  }

  get currentStep() {
    return this.stepsValue[this.currentIndexValue] || {}
  }

  get currentStepTime() {
    return this.currentStep.time || 0
  }

  get currentStepDescription() {
    return this.currentStep.description || ""
  }

  get progress() {
    if (this.currentStepTime === 0) return 0
    return Math.min((this.elapsedValue / this.currentStepTime) * 100, 100)
  }

  get remainingTime() {
    return Math.max(this.currentStepTime - this.elapsedValue, 0)
  }

  get currentTimedPosition() {
    return this.timedStepIndices.indexOf(this.currentIndexValue)
  }

  toggle() {
    if (this.playingValue) {
      this.pause()
    } else {
      this.play()
    }
  }

  play() {
    if (this.timedStepIndices.length === 0) return

    this.playingValue = true
    this.updatePlayPauseIcon()
    this.highlightCurrentStep()

    this.interval = setInterval(() => {
      this.elapsedValue++
      this.updateDisplay()

      if (this.elapsedValue >= this.currentStepTime) {
        this.nextStep()
      }
    }, 1000)
  }

  pause() {
    this.playingValue = false
    this.updatePlayPauseIcon()

    if (this.interval) {
      clearInterval(this.interval)
      this.interval = null
    }
  }

  stop() {
    this.pause()
    this.elapsedValue = 0
    this.updateDisplay()
  }

  nextStep() {
    const currentPos = this.currentTimedPosition
    if (currentPos < this.timedStepIndices.length - 1) {
      this.currentIndexValue = this.timedStepIndices[currentPos + 1]
      this.elapsedValue = 0
      this.updateDisplay()
    } else {
      this.pause()
    }
  }

  previousStep() {
    const currentPos = this.currentTimedPosition
    if (currentPos > 0) {
      this.currentIndexValue = this.timedStepIndices[currentPos - 1]
      this.elapsedValue = 0
      this.updateDisplay()
    }
  }

  goToStep(event) {
    const index = parseInt(event.currentTarget.dataset.stepIndex, 10)
    if (this.timedStepIndices.includes(index)) {
      this.currentIndexValue = index
      this.elapsedValue = 0
      this.updateDisplay()
    }
  }

  updateDisplay() {
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${this.progress}%`
    }

    if (this.hasCurrentStepTarget) {
      this.currentStepTarget.textContent = `Step ${this.currentIndexValue + 1}: ${this.currentStepDescription}`
    }

    if (this.hasCurrentTimeTarget) {
      this.currentTimeTarget.textContent = this.formatTime(this.remainingTime)
    }

    this.highlightCurrentStep()
  }

  highlightCurrentStep() {
    this.stepRowTargets.forEach((row, index) => {
      const isActive = this.playingValue && index === this.currentIndexValue
      row.toggleAttribute("data-active", isActive)

      if (isActive) {
        row.scrollIntoView({ behavior: "smooth", block: "center" })
      }
    })
  }

  updatePlayPauseIcon() {
    if (this.hasPlayIconTarget && this.hasPauseIconTarget) {
      this.playIconTarget.classList.toggle("hidden", this.playingValue)
      this.pauseIconTarget.classList.toggle("hidden", !this.playingValue)
    }
  }

  formatTime(seconds) {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return mins > 0 ? `${mins}:${secs.toString().padStart(2, '0')}` : `${secs}s`
  }

  stepsValueChanged() {
    this.timedStepIndices = this.stepsValue
      .map((step, index) => step.time > 0 ? index : null)
      .filter(index => index !== null)

    if (this.timedStepIndices.length > 0 && this.currentIndexValue === -1) {
      this.currentIndexValue = this.timedStepIndices[0]
    }
    this.updateDisplay()
  }

  currentIndexValueChanged() {
    this.updateDisplay()
  }
}
