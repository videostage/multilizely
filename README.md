<p align="center">
  <img src="./logo.png" alt="Multilizely" width="250" height="80" /> <br /><br />
  <span>A Command Line Interface for working with <a href="https://localizely.com/">Localizely</a> in flutter projects
that contain multiple l10n.yaml files.</span>
</p>

## About

[Localizely](https://localizely.com/) is a great service to manage localization. It provides CLI
that only supports one flutter/dart package, with only one l10n.yaml per project. In some cases, it is
useful to have several flutter/dart packages in a project. For example, to split application logic
into layers, features, or just to create mono repository.

A project structure example supported by Localizely CLI:

```
  project/
    pubspec.yaml
    l10n.yaml
    lib/
      strings/
        strings.dart
        strings_en.arb
        ...
```

A project structure example that can be supported by  ***Multilizely*** CLI:

```
  project/
    pubspec.yaml
    l10n.yaml
    lib/
      strings/
        strings.dart
        strings_en.arb
        ...
    packages/
      my_feature_1/
        pubspec.yaml
        l10n.yaml
        lib/
          strings/
            strings.dart
            strings_en.arb
            ...
      ...
      my_feature_n/
        pubspec.yaml
        l10n.yaml
        lib/
          strings/
            strings.dart
            strings_en.arb
            ...
```

Multilizely allows you to upload and download translations for projects with a similar structure.

Keys across packages do not have to be unique. Multilizely add a package prefix and a project
prefix (optional) to all translation keys at uploading time, and delete that prefix at downloading.

## Getting started

### Terms

* Localization package - a directory that contain l10m.yaml at the root.

### Initialization

* Create an environment variable with [personal API token](https://app.localizely.com/account) -
  ```LOCALIZELY_TOKEN```.

* Install the latest Multilizely version as a global package.

```shell
dart pub global activate multilizely

# Or alternatively to specify a specific version:
# pub global activate multilizely 0.0.1
```

* Create and configure a ```multilizely.yaml``` in the root of the project.

```yaml
# Localizely project id
localizely_project_id: my_localizely_project_id
# Project key - project name or something to add as a localization key prefix 
# to all keys in the project (optional)
project_key: my_project_key
# Supported locales
locales:
  en:
  pt-BR:
# List of localization packages
packages:
  # Localization package key - package name or something to add as a localization key prefix
  # to all keys in the package
  myFeature1:
    # Path to the localization package relative to the root of the project
    path: packages/my_feature_1
  ...
  myFeatureN:
    path: packages/my_feature_n
```

## Commands

### Init Command

Upload all translations of a localization package to Localizely. If there are **same keys** in
Localizely already exist, then this command will overwrite them with the new values from the
package.

To specify which package should be initialized, pass a localization package key
from ```multilizely.yaml```'s localization package list to the package parameter ```--package, -p```

```shell
multilizely init -p myFeature1
```

### Update Command

Update translations of a package using the following strategy:

* Upload all new keys with translations from package's template arb file (```template-arb-file```
  property from ```l10n.yaml```) that not yet exist in Localizely.
* Download and overwrite package's localization keys with translations from Localizely to the
  package. Keys that exist in Localizely, but not exist in the package will not be added.

Pass ```--generate, -g``` parameter to run ```flutter gen-l10n``` immediately after package update.

```shell
multilizely update -p myfeature1 -g
```

### Common Parameters

* ```--package, -p``` - Package key.
* ```--all-packages``` - Run command for all packages. There is no need to pass project key
  parameter in that case.
* ```--test``` - Do not upload files to localizely and do not update localization packages. Only
  build result arb files in buid/multilizely.

During commands execution Multilizely performs some actions like merging arb files or downloading
and split them from Localizely. That process generates temporary arb files that locates at the
build/multilizely directory. This can be useful for solving issues at the integration stage or
during contribution.

## Welcome to contribute!

The Update command was designed based on the development process of our team and may not fit for
you. If so, it is possible to refactor update command in a more abstract way by creating
UpdateCommandStrategy abstraction or something. You can open an issue to describe your idea or
problem to solve.