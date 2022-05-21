// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
//
// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
import "./socket"
import "phoenix_html"
import topbar from "../vendor/topbar"
import Alpine from "alpinejs"
import "./theme_switcher"

import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {InitFlash} from "./init_flash"
import {InitCheckout} from "./init_checkout"
import {InitModal} from "./init_modal"

let Hooks = {}
Hooks.InitFlash = InitFlash
Hooks.InitCheckout = InitCheckout
Hooks.InitModal = InitModal

window.Alpine = Alpine
Alpine.start()

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: {_csrf_token: csrfToken},
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to)
      }
    }
  }
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
window.addEventListener('phx:page-loading-start', info => topbar.show())
window.addEventListener('phx:page-loading-stop', info => topbar.hide())

// Close modals and dropdowns on page leave
// Add a x-on:page-leave="open = false" to an element that has x-data on it
window.addEventListener("phx:page-loading-start", info => {
  document.querySelectorAll('[x-data]').forEach(el => el.dispatchEvent(new CustomEvent('page-leave')))
})

// Used for triggering modals to be displayed with the slide-in-animation
window.addEventListener("phx:page-loading-stop", info => {
  const modal = document.querySelector('#modal')
  if (modal) {
    liveSocket.execJS(modal, modal.getAttribute("data-init-modal"))
  }
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
