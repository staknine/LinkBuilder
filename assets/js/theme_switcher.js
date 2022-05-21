const DEFAULT_THEME = document.querySelector('html').dataset.theme

const setTheme = theme => {
  const htmlEl = document.querySelector('html')

  htmlEl.classList.remove('light')
  htmlEl.classList.remove('dark')

  document.querySelector('html').dataset.theme = theme
  document.querySelector('html').classList.add(theme)
  localStorage.theme = theme
}

const init = () => {
  if (['light', 'dark'].includes(DEFAULT_THEME) == false) return

  if (localStorage.theme === 'dark') {
    setTheme('dark')
  } else if (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    setTheme('dark')
  } else {
    setTheme('light')
  }
}

if (document.getElementById('switch-theme')) {
  document.getElementById('switch-theme').addEventListener('click', event => {
    event.preventDefault()
    const htmlEl = document.querySelector('html')
    const oppositeTheme = htmlEl.dataset.theme == 'dark' ? 'light' : 'dark'

    setTheme(oppositeTheme)
  })
}

init()
