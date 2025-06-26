import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]
  
  
  connect() {
    // Close dropdown when clicking outside
    document.querySelector("#desktop-menu-btn").addEventListener("click", this.toggle.bind(this))
    document.addEventListener("click", this.closeOnClickOutside.bind(this))
  }
  
  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside.bind(this))
  }
  
  toggle(event) {
    const menu = document.getElementById('menu');
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
    console.log("Dropdown toggled")
    if (menu) {
      menu.classList.add("hidden")
    }
  }
  
  closeOnClickOutside(event) {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.menuTarget.classList.toggle("hidden")
    }
  }
}
