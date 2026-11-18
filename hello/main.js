const { app, BrowserWindow } = require('electron')
const path = require('node:path')

function open () {
  const window = new BrowserWindow({ width: 800, height: 600, autoHideMenuBar: true })
  window.loadFile(path.join(__dirname, 'index.html'))
}

app.whenReady().then(open)
app.on('window-all-closed', () => app.quit())
