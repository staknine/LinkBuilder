import { appChannel } from './socket'

export const InitFlash = {
  mounted() {
    const body = this.el.textContent || ''

    if (body === '' || appChannel.topic === '') return
    const type = this.el.getAttribute('phx-value-key') || ''

    appChannel.push('flash', { body: body, type: type })
  },
}
