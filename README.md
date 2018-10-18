Based on https://pablohirafuji.github.io/elm-http-progress-example/

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

## gzip

To enable gzip compression, you may use nginx as proxy.

Then start

`serve -l 5001` and `nginx` with the settings from nginx.conf from this repo.

## Conclusions

- To cancel request we need to use https://github.com/elm-lang/http/blob/1.0.0/src/Http/Progress.elm
- Request with only GET method. Maybe there is a way for POST request.
- We don't need progress bar to cancel request.
- Restarting request is probably best done in subscription. I am using such code:
- It works for txt file or json and probably other as well.
- For many urls, we need some mechanism to track which url should be restarted etc.

```elm
subscriptions : Model -> Sub Msg
subscriptions model =
    if model.cancel then
        Time.every Time.second (always RestartDownload)
    else
        case model.bookUrl of
            Just bookUrl ->
                Http.getString bookUrl
                    |> Progress.track bookUrl GetBookProgress

            Nothing ->
                Sub.none
```

I have added 2 screenshots from Chrome and Firefox showing that download is restarted:

Chrome

![](/chrome.png)

Firefox

![](/firefox.png)

Regarding progress bar. Even if progress bar does not work in Chrome when gzip enabled https://bugs.chromium.org/p/chromium/issues/detail?id=463622, or sometimes even in Firefox does not work, we still can abort request. Also to show progress, server probably must support it by sending content length - not sure if it works for json.
