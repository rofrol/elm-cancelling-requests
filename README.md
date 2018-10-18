## Server

```bash
$ npm i -g serve
$ serve
```

Prepare file in `txt/leviathan.txt`.


```bash
$ elm-reactor
```

Open web browser at http://localhost:8000/src/Main.elm.

You may also throttle speed in Network tab in Developer Tools.

https://pablohirafuji.github.io/elm-http-progress-example/

## gzip

To enable gzip compression, you may use nginx as proxy.

Then start

`serve -l 5001` and `nginx` with the settings from nginx.conf from this repo.
