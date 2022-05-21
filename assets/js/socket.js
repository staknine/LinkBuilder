import { Socket } from 'phoenix'

const getUserToken = () => {
  const elm = document.querySelector("meta[name='channel_token']")

  if (!elm) return ''

  return elm.getAttribute('content') || ''
}

const getChannelName = () => {
  const elm = document.querySelector("meta[name='channel_name']")
  if (!elm) return ''

  return elm.getAttribute('content') || ''
}

// Connect to socket using a user token for loggen in users
let socket = new Socket('/socket', { params: { token: getUserToken() } })
socket.connect()

// App Channel
let appChannel = socket.channel(getChannelName(), {})

if (getChannelName() !== '') {
  appChannel
    .join()
    .receive('ok', resp => {
      console.log('Joined successfully', resp)
    })
    .receive('error', resp => {
      console.log('Unable to join', resp)
    })
}

export default socket
export { appChannel }
