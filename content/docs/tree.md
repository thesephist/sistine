---
title: Directory structure
order: 2
description: Files and folders that live in a Sistine project, and what they all do
---

In a typical Sistine project, you'll find a file hierarchy that looks something like this (borrowed from the example site in the [Get started](/start/) page).

```
├── config.json
├── content
│   ├── about.md
│   └── index.md
├── public
│   ├── about
│   │   └── index.html
│   ├── css
│   │   └── main.css
│   ├── index.html
│   └── index.xml
├── static
│   └── css
│       └── main.css
└── tpl
    ├── index.html
    ├── parts
    │   └── head.html
    └── rss.xml
```

The `config.json` file defines the top-level variables for your site, like the site name and domain. You can also add arbitrary JSON data to this configuration file to access it from page templates.

`./content` contains all _content pages_, authored in Markdown with front matter. Each of these pages gets rendered to exactly one output file in the final static site. Any subdirectories in this content folder are considered distinct "sections" to the site by Sistine, and the index page of each section will have access to all of its children pages.

`./public` is the destination folder where Sistine will place the output of a build. When deploying a Sistine site, you can deploy the contents of `./public` to a file server.

`./static` stores all the static (non-content) files of the site. Everything in the static folder will be copied to the public folder before any content rendering takes place.

`./tpl` stores all page templates for the site, and generally mirrors the structure of the content folder. You can read about template files in the [templating system documentation](/docs/tpl/).

