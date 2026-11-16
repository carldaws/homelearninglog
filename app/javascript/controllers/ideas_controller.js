import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "list", "template" ]

  add() {
    this.listTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML.replaceAll("NEW_IDEA", Date.now()))
    this.listTarget.lastElementChild.focus()
  }
}
