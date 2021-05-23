---
title: Templating system
order: 1
starred: true
description: The canonical reference manual for Sistine's templating language and system
---

Sistine's main job is to take each page from the content directory and render it into a full HTML page using a _template_. Sistine's page templates are HTML files with extra template directives modeled after Ink's `std.format` function. The rest of this page details this templating system, and how Sistine finds these templates.

## Templating language and directives

Ink's templating language uses double curly braces like `{{ these }}` to denote special instructions for the templating engine. If you must include double curly braces in your template to be displayed, escape the second brace, like `{\\{`, or use the HTML entity `&#123;` to denote a curly brace.

Sistine provides the following functions in a template.

### Display a variable or property

`{{ foo.bar }}` resolves to the value of `bar` in the object `foo` in the current parameter dictionary. For example, if the page parameters looked like this

```
{
    title: 'Hello, World!'
    foo: {
        bar: [10, 20, 30]
        baz: {
            quux: 'Goodbye!'
        }
    }
}
```

The following are all valid.

- `{{ title }}`
- `{{ foo.bar }}` (though this will print the raw list object)
- `{{ foo.bar.2 }}` (prints `30`)
- `{{ foo.baz.quux }}`

Accessing an undefined or null value will not error -- it will simply render an empty string. This behavior is nice for dealing with optional values, like `page.draft` which may be usually false.

### Conditional if/else expressions

`{{ if foo }} X {{ else }} Y {{ end }}` renders X if value `foo` is truthy, `Y` otherwise. In determining truthiness, the following values and their string forms are considered false, and any other value is considered true:

- `0`
- `''`
- `()`
- `{}`
- `false`

An idiomatic trick is to check `{{ if page.some_list }}...{{ end }}` to check whether a list is empty.

### Loops through a list or object values

The loop directive is a bit more complex. The full form looks like the following, where the parts in square brackets are optional.

```
{{ each foo [by bar] [asc|desc] }}
    X
{{ else }}
    Y
{{ end }}
```

If `foo` is not empty, this directive loops through every value in the list or object `foo` ordered by each item's property `bar` and renders X for each value; if the list is empty, this renders Y. For example, a common format for a reverse-chronological blog post listing page may include

```
{{ each page.pages by date desc }}
    {{ -- post-listing -- }}
{{ else }}
    <p>No posts yet.</p>
{{ end }}
```

Besides the properties that are normally a part of each value in the list, within each `{{ each }}` section, a template has access to three special variables:

- `i` is the index in the loop, starting at 0
- `*` is the template parameter immediately outside the loop, useful for accessing out-of-scope variables from within the loop like `{{ *.site.name }}`
- `_` is the parent value, _i.e._ the thing being iterated over

### Escaping for HTML

`{{ escape foo }}` escapes the value of variable `foo` for HTML. This escapes _at least_ `<` and `&` for safe display of HTML code.

### Partial template embeds

Partial templates are defined by placing an HTML file into `./tpl/parts`. They are referred to by their base filename in other templates. Partial templates can refer to other partial templates, but normal templates cannot refer to other normal templates by their name. For example, to share a common header part across all templates, we may place a `header.html` into the partial templates folder, then write

```
{{ -- header -- }}
```

This will invoke Sistine to search for this partial template in `./tpl/parts/header.html`. If one is not found, this directive will be ignored, but you'll see an error message from Sistine in the output.

## Page template variables

All page templates are passed a dictionary with values for:

- `site`, containing site-wide metadata, imported from `./config.json`
- `page`, containing data about that specific page, including URLS, file paths, the rendered Markdown content, child and parent pages, and any other parameters defined for the page in the page's [front matter](/docs/markdown/)

In general, a template begins rendering with these variables, plus any user-defined ones.

```ink
site {
    name
    origin
    description
}
page {
    path // URL of the page
    publicPath // path to file in ./public
    contentPath // path to file in ./content
    content // compiled Markdown content
    index? // true if is an index page, else false
    pages: { name -> page } // for index pages, map of page names -> pages
    roots: page[] // parent pages, from the root (/) page down, like breadcrumbs
}
```

The `rss.xml` template is passed something slightly different. It's passed the `site` variable just like others, and then `pages`, a flat list of all the pages in the static site.

## Template resolution and rendering rules

In every directory in `./content`, there are

- Folders, which are compiled to directories in `./public` of the same name and descendant pages
- Files, which if named `index.md` are compiled to `index.html` and if not, are compiled to `{{ filename }}/index.html`

Every Sistine page renders once to a single template that is resolved in the following order of decreasing specificity.

1. A template at the same directory path and name as the content file, ignoring file extensions.
2. If an `index.md` file, the template with the name of the directory for which it is the index. For example, `./tpl/foo.md` for `./content/foo/index.md`. Non-index files skip this step.
3. `index.html` in the same directory path as the content file.
4. `tpl/index.html`, the root page template.

If no appropriate option is found after looking in these four places for any given content page, Sistine will generate an error for that page in the CLI output.

