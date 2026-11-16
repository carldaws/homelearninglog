# Home Learning Log

Free, open source software for families who home educate. Keep a shared log of what the children did, with photos, and plan around their interests rather than a curriculum.

No ads, no email. It's a work in progress.

## Running it locally

You need Ruby (see `.ruby-version`), PostgreSQL and libvips.

```sh
bin/setup
```

That installs gems, prepares the database and starts the app at http://localhost:1611.

## Tests

```sh
bin/rails test
bin/rubocop
```

## Licence

[AGPL-3.0](LICENSE). If you run a modified copy as a website, you have to publish your changes under the same licence.
