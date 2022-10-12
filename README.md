# Experimenting with Dev Container Features

**Warning: this is an experimental repository.  At the moment, it is not intended for use by anyone other than the author.**

## Features

This repository contains a _collection_ of features. Each sub-section below shows a sample `devcontainer.json` alongside example usage of the feature.

### `shinx-needs`

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/AlexanderLanin/features/sphinx-needs:1": "1.0.2"
    }
}
```
