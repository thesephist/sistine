---
---

# Sistine, the static site engine

Sistine is a simple, flexible, productive static site generator written in [Ink](https://dotink.co/) and built on [Merlot](https://github.com/thesephist/merlot)’s Markdown engine.

!html <a class="button" href="/start/">Quick start &rarr;</a>

## Features

### Simple templating

Here's the Sistine template for this very page.

```
<!doctype html>

{{ -- head -- }}

<body>
<main>
    {{ -- header -- }}

    <article>
        {{ if page.title }}<h1>{{ page.title }}</h1>{{ end }}
        {{ page.content }}
    </article>

    {{ -- footer -- }}
</main>
</body>
```

### Productive control

Sistine tries to give you as few primitives to learn and configure as reasonable. Unlike most static site generators, Sistine has no distinction between "list" and "article" pages. There's only one idea -- the _page_.

### Extended Markdown support

## Examples

