# pyve.nvim

## Why this exists
Working with virtual environments in Python while using Neovim can be frustrating.
The hassle of activating the environment, opening Neovim, opening a new terminal window,
activating again, and using the correct path to the activation script can be tedious.
*pyve* was born out of the desire to eliminate these worries and streamline the process -for me.

## How it works

Brief overview,
- Its only active for when a python file is opened.
- It searches for a virtual environment by going up the directory structure until it finds one, using some [assumptions](#assumptions)

## Assumptions
pyve makes several assumptions to function effectively:
- Project root markers -> It checks for a limited number of [markers](https://github.com/musaubrian/pyve.nvim/blob/main/lua/pyve.lua#L2)
to see if its at the project root
- Virtual environment names -> it tries to detect common [virtual envs names](https://github.com/musaubrian/pyve.nvim/blob/main/lua/pyve.lua#L37)

## Setup
Lazy:
```lua
{
    "musaubrian/pyve.nvim",
    config = function
        require("pyve")
    end
}
```

Packer:

```lua
use { "musaubrian/pyve.nvim" }
require("pyve")
```

That's all you need to do

## Contribution
Contributions are welcome!
If you have ideas for improvements or have found a bug,
please open an issue or submit a pull request.

## Limitations
- [ ] As of this moment, it only supports normal virtual envs (created with `python3 -m venv`)
Not sure how it will behave with others like conda
- [ ] It makes some assumptions about your project as listed [here](#assumptions)
- [ ] LSP functionality works great, with the python-language-server(pyls) which is what I currently use, haven't tested out others

[LICENSE](./LICENSE)


