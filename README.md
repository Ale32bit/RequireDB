# RequireDB

Repository of libraries for ComputerCraft

## Usage

1. Download [requiredb.lua](/requiredb.lua).

    `wget https://raw.github.com/Ale32bit/RequireDB/main/requiredb.lua`

2. Require the library to enable the functionality and then require the libraries you need by prepending the name with `@`. Additionally you can append the version after `:`. (i.e. `@example:0.0.1`)
   
   ```lua
   local requiredb = require "requiredb"

   local rdb = requiredb()

   local example = require("@example")
   ```

## Library Documentation

`requiredb([options: table]): requireDb`

### options

The optional options table defines the options to use.

```lua
options = {
    -- Path of the cache directory.
    path?: string = ".requiredb",

    -- Upstream repository. NO LEADING SLASH.
    repository?: string = "https://requiredb.alexdevs.me",

    -- Use cache of previously downloaded libraries.
    useCache?: boolean = true,
}
```

### requireDb

This table is returned by creating a new instance.

Creating the instance automatically injects the package loader and more can be stacked with different configurations.

```lua
-- Get the index.json of the library
requireDb.getInfo(name: string): table
-- If the library license is "custom", a HTTP GET request is made to retrieve the LICENSE file from the repository and, if successfully downloaded, will replace  the "license" field.
```

## How to add a library

1. Adding a library is as simple as creating a directory in the [packages/](/packages/) directory.

    The library name in the directory must be alphanumeric and can include hyphens (`-`).

2. Inside the newly created library directory, creare a new `index.json` file.

    Fill the file content with this template. Remember to remove comments.

    ```jsonc
    {
        // Pretty name of the library
        "name": "My Library",

        // All authors of the library
        "authors": [
            "Myself",
            "Someone else"
        ],

        // License of the library. Set to "custom" if using a custom license.
        // If "custom" is used, create and fill the file "LICENSE" in the same directory of this file index.json.
        "license": "My license",

        // Versions available to download.
        // The last item is used as "latest" version.
        "versions": [
            "1.0.0"
        ]

        // Other fields can be included, such as "website".
    }
    ```

3. Create the directory `versions` and insert all versions in respect of the versions array in `index.json`.

    The files must end with `.lua`

4. Create a pull request or host your own repository.
