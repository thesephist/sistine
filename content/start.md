---
title: Get started with Sistine
---

Let's build a simple static site with Sistine, from installation to deploy.

## Install Sistine

This guide will show a lot of shell commands in code blocks. Whenever you see a line beginning with a `$`, it represents a command you need to type into your shell (except the leading `$`); other lines represent output, which might not match what you see exactly, but should be close enough to guide you.

### Prerequisite: install Ink

Sistine is written in the [Ink programming language](https://dotink.co/). If you don't have Ink on your system, you'll need to [install it from a release on GitHub](https://dotink.co/docs/overview/#setup-and-installation). Sistine works on Ink releases v0.1.9 and up -- you can check the version of Ink you have by running `ink --version`.

```
$ ink --version
ink v0.1.9
```

### Get Sistine from source

Sistine currently doesn't have a simple installation method. We'll have to clone the source repository and run the program from the repository.

```
$ git clone https://github.com/thesephist/sistine
Cloning into 'sistine'...
remote: Enumerating objects: 207, done.
remote: Counting objects: 100% (207/207), done.
remote: Compressing objects: 100% (103/103), done.
Receiving objects: 100% (207/207), 50.59 KiB | 2.66 MiB/s, done.
remote: Total 207 (delta 85), reused 186 (delta 68), pack-reused 0
Resolving deltas: 100% (85/85), done.
```

Once you have Ink installed in your `$PATH` and Sistine cloned, run `./sistine help` to check that it runs correctly.

```
$ sistine/sistine help
```

## Set up a project

// TODO: might require a new `init` command in Sistine

## Customize

## Deploy
