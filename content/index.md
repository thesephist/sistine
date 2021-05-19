---
---

# _Sistine_, the static site engine

Sistine is a simple, flexible, productive static site generator written in [Ink](https://dotink.co/) and built on [Merlot](https://github.com/thesephist/merlot)’s Markdown engine. This demo site is, of course, geneated by Sistine.

!html <p class="button-group">
<a class="button filled" href="https://github.com/thesephist/sistine" target="_blank">View source</a>
<a class="button" href="/start/">Get started &rarr;</a>
</p>

## Features

Sistine covers a lot of creative, expressive ground with a few powerful primitives. Simple templating based on a single page type, rich control over page customization with page variables, and an extended Markdown syntax.

### Simple templating

Here's the Sistine template for the [docs](/docs/) page.

```html
<!doctype html>

{{ -- head -- }}

<body>
<main>
  {{ -- header -- }}

  <article>
    {{ if page.title }}<h1>{{ page.title }}</h1>{{ end }}
    {{ page.content }}
  </article>

  {{ if page.pages }}
  <div class="postlist">
    {{ each page.pages by order asc }}
    <h2><a class="postlist-link" href="{{ path }}">{{ title }}</a></h2>
    <p>{{ description }}</p>
    {{ end }}
  </div>
  {{ end }}

  {{ -- footer -- }}
</main>

{{ -- scripts -- }}
</body>
```

- Here, `{{ -- head -- }}` is the template page.

### Productive control

Sistine tries to give you as few primitives to learn and configure as reasonable. Unlike most static site generators, Sistine has no distinction between "list" and "article" pages. There's only one idea -- the _page_.

### Extended Markdown support

Sistine's Markdown engine is borrowed from [Merlot](https://github.com/thesephist/merlot), an online Markdown editor written in Ink.

