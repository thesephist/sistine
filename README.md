# Sistine 🏰

**Sistine** is a static site generator written in [Ink](https://dotink.co/). Currently, Sistine is being developed within the nyc source tree, in `src/` and `vendor/`, but will be pulled out into its own repository eventually, when it's stable.

## Directory structure

```
vendor/ - vendored Ink libraries
src/ - Ink static site generator source
test/ - Tests for Sistine
content/ - Markdown-formatted blog content
tpl/ - page templates
static/ - static files copied to the generated site
public/ - destination directory for the generated site
config.json - configuration for the Sistine site
```

In every directory in `content/`, there are

- Folders, which are compiled to directories in `public/` of the same name and compiled descendants
- Files, which if named `index.md` are compild to `index.html` and if not, are compiled to `{{ filename }}/index.html`

## Sistine templates

Sistine's page templates are text files (usually HTML files) with extra template directives modeled after Ink's `std.format` at a high level, with standard page variables and conditional formatting instructions.

### Page templates

A page in Sistine is a Markdown file in `./content`. A Sistine page renders once to a single template that is resolved in the following order.

1. A template at the same directory path and name as the content file, ignoring file extensions.
2. If an `index.md` file, the template with the name of the directory for which it is the index
2. `index.html` in the same directory path as the content file
2. `tpl/index.html`, the root template

### Template parts

Template parts are partial templates that can be referenced and included from other templates. They live in `tpl/parts`.

### Template directives

- `{{ foo.bar }}` resolves to the value of `bar` in the object `foo` in the page parameters

- `{{ if foo }} X {{ else }} Y {{ end }}` renders X if value `foo` is true, `Y` otherwise

- `{{ each foo [by bar] [asc|desc] }} X {{ else }} Y {{ end }}` if `foo` is not empty, loops through every value in list `foo` ordered by bar and renders X for each value; else renders Y

- `{{ -- head -- }}` include the partial template `parts/head.html` here

### Template parameters

```ink
{
    site {
        name
        origin
        description
    }
    page {
        // always, auto-generated
        path
        publicPath
        contentPath
        content
        index? // true if is an index page
        pages { name -> page } // for index pages, map of page names -> pages

        // by convention
        title
        date
        draft
    }
}
```

Value of the `site` configuration is parsed directly from the `./config.json` file at the root of the project.

## Sistine Markdown

Sistine's content system is powered by [Merlot](https://github.com/thesephist/merlot), a Markdown engine written in pure Ink. It attempts to be broadly compatible with GitHub and CommonMark specifications.

