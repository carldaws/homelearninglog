import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "button", "content" ]

  toggle() {
    const revealing = this.contentTarget.hidden
    this.contentTarget.hidden = !revealing
    this.buttonTarget.setAttribute("aria-expanded", revealing)
    if (revealing) this.contentTarget.querySelector("textarea")?.focus()
  }
}
