# electron-tools

Templates for desktop apps built with [Electron](https://www.electronjs.org) on the
WarpEngine `electron` platform (WarpEngine 4.3+): a store client, a launcher, a tool, or an
HTML game that wants a window of its own.

- `example-woodpecker.yaml` — the one-line marker (`platform: electron`): the full pipeline
  (version → linux → windows → upload → publish) is served by the update server's Woodpecker
  configuration extension; preview it with
  `curl "https://teletypegames.org/build/config?platform=electron"`.
- `example-tasks.json` — VS Code `.vscode/tasks.json`: `build` (the default
  build task) and `package (Linux)` as `warpengine` tasks on the `Makefile`,
  and `run (Electron)` (`npm start` on this computer).
- `hello/` — a minimal Hello World app: `package.json` with `electron` and `electron-builder`
  pinned, its `package-lock.json` (the pipeline runs `npm ci`), `main.js`, `index.html`.
- `warp-template.json` — what the WarpEngine Toolbox's *New Game* copies from this repo
  ("Start from the template only"), with the app's name, title, author and description
  filled in. The toolbox writes `.woodpecker.yaml`, `metadata.json` and `README.md` itself.
  The Hello World files are `templateOnly`: starting from the demo leaves them out.

*Start from the demo* gives the [WarpEngine Client](https://git.teletypegames.org/stores/warp-engine-client)
instead: a store client of your own, pointed at the catalog the toolbox is connected to.

## What the pipeline expects

- `electron-builder` in `devDependencies`, and a `package-lock.json`;
- the version in `package.json` (the toolbox's *Release* bumps it there);
- optionally a `check` script (tests that need no display) and a `build` script: the
  pipeline runs them before packaging when they exist.

The pipeline builds a Linux AppImage (`<name>-<version>-linux-x64.zip`, always) and a
Windows NSIS installer (`<name>-<version>-win-x64.zip`, through Wine on an x86_64 CI agent).
macOS packages need a Mac: `npm run dist` there, zip the result as
`<name>-<version>-mac-arm64.zip` and upload it with `/build/upload`.

The builder image is `git.teletypegames.org/build/electron-builder`:
`electronuserland/builder:22-wine`, mirrored unchanged.

## Locally

```sh
npm install
npm start          # run it
npm run dist       # package for this machine
```

## Dev container

`warp-template.json` has a `devcontainer` key that the WarpEngine Toolbox reads
(an older toolbox ignores it): a new project gets `.devcontainer/` from
`example-devcontainer.json` and `example-devcontainer.Dockerfile` — the CI
builder image the host names (`{builderImage}`) plus git and a `dev` user —
so a computer with only Docker builds with the same toolchain as the pipeline.
The tasks of `example-devcontainer-tasks.json` are merged into
`.vscode/tasks.json`: `dev image` builds the container image, `play` builds the
game and plays it in the host's web runtime. A new project from the template (not from the demo, which has its own) also gets `example-makefile.make` as its `Makefile`, the pipeline's npm steps as targets (`build`: `npm ci`, `check`, `build`; `package`: the Linux AppImage). In the container `node_modules` is a volume of its own, apart from the one of this computer, so the Linux packages there never mix with yours. The app window does not open in the container: `run (Electron)` builds there and runs `npm start` here, with a local Node; `play` shows `index.html` in the Play panel.
For an existing game repo, *WarpEngine: Add Dev Container* adds it and merges
the tasks, keeping yours.
