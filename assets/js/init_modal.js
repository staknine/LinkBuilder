export const InitModal = {
  mounted() {
    const handleOpenCloseEvent = event => {
      if (event.detail.open === false) {
        this.el.removeEventListener("modal-change", handleOpenCloseEvent)

        setTimeout(() => {
          this.pushEventTo(event.detail.id, "close", {})
        }, 300);
      }
    }
    this.el.addEventListener("modal-change", handleOpenCloseEvent)

    this.handleEvent('close', data => {
      if (!document.getElementById(data.id)) return

      const event = new CustomEvent('close-now')
      this.el.dispatchEvent(event)
    })
  }
}
