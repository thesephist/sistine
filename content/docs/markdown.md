---
title: Sistine Markdown
order: 3
description: The extra features that Sistine's Markdown parser supports, and where it deviates from the norm
---

Sistine's Markdown engine comes from the [Merlot](https://github.com/thesephist/merlot) Markdown editor web app. As a result, every Markdown feature supported by Merlot is supported in Sistine, and the ones not yet supported in Merlot are not yet here in Sistine, either. Most features of standard Markdown are supported, however, including

- Inline markup: _italic_, **bold**, ~strikethrough~, `monospace`
- Bulleted and numbered lists
- Code blocks with `\`\`\``
- Block quotes with `>`
- Headings beginning with a number of `#`s
- Inline HTML with the `!html` command

Notable features that are not yet supported include

- Table of contents generation
- Anchor links to headings (being able to link to `some-page/#some-heading`)
- Code block syntax highlighting
- Multi-paragraph list items

I will probably add them to Merlot (and thus Sistine) as I need those features out of these apps.

## Front matter in content pages

Every content page in the `./content` folder of a Sistine site should be a Markdown file, optionally beginning with _front matter_. Front matter is a list of key-value pairs that come between two triple-dashed lines. For example, the front matter for this page is something like

```
---
title: Sistine Markdown
order: 3
description: The extra features ...
---

( rest of page Markdown ... )
```

Front matter should always begin and end with three dashes. if a particular page does not need any page variables, it may omit the front matter entirely, and the entire page will be parsed as simple Markdown.

Every key in the front matter of a content page defines a [page variable](/docs/tpl/) for Sistine templates to use when rendering. All variables are parsed and treated as raw strings. In other words the `order` variable of this page is the string "3".

