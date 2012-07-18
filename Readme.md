## Who put Lisp in my JavaScript?

This project adds [Sibilant] support to the vim editor. It handles syntax,
indenting, compiling, and more.

[Sibilant]: http://sibilantjs.info

### Install from a Zipball

This is the quickest way to get things running.

1. Download the latest zipball from [github][zipball-github].
   The latest version on github is under Download
   Packages (don't use the Download buttons.)

2. Extract the archive into `~/.vim/`:

        unzip -od ~/.vim vim-sibilant-HASH.zip

These steps are also used to update the plugin.

[zipball-github]: https://github.com/joefiorini/vim-sibilant/downloads

### Install with Pathogen

Since this plugin has rolling versions based on git commits, using pathogen and
git is the preferred way to install. The plugin ends up contained in its own
directory and updates are just a `git pull` away.

1. Install tpope's [pathogen] into `~/.vim/autoload/` and add this line to your
   `vimrc`:

        call pathogen#infect()

    To get the all the features of this plugin, make sure you also have a
    `filetype plugin indent on` line in there.

[pathogen]: http://www.vim.org/scripts/script.php?script_id=2332

2. Create and change into `~/.vim/bundle/`:

        $ mkdir ~/.vim/bundle
        $ cd ~/.vim/bundle

3. Make a clone of the `vim-sibilant` repository:

        $ git clone https://github.com/joefiorini/vim-sibilant.git

#### Updating

1. Change into `~/.vim/bundle/vim-sibilant/`:

        $ cd ~/.vim/bundle/vim-sibilant

2. Pull in the latest changes:

        $ git pull

### SibilantMake: Compile the Current File

The `SibilantMake` command compiles the current file and parses any errors. The full signature of the command is:

    :[silent] SibilantMake[!] [SIBILANT-OPTIONS]...

By default, `SibilantMake` shows all compiler output and jumps to the first line
reported as an error by `sibilant`:

    :SibilantMake

Compiler output can be hidden with `silent`:

    :silent SibilantMake

Line-jumping can be turned off by adding a bang:

    :SibilantMake!

`SibilantMake` can be manually loaded for a file with:

    :compiler sibilant

#### Recompile on write

To recompile a file when it's written, add an `autocmd` like this to your
`vimrc`:

    au BufWritePost *.sibilant silent SibilantMake!

All of the customizations above can be used, too. This one compiles silently
and with the `-b` option, but shows any errors:

    au BufWritePost *.sibilant silent SibilantMake! -b | cwindow | redraw!

The `redraw!` command is needed to fix a redrawing quirk in terminal vim, but
can removed for gVim.

#### Default compiler options

The `SibilantMake` command passes any options in the `sibilant_make_options`
variable along to the compiler. You can use this to set default options:

    let sibilant_make_options = '--bare'

#### Path to compiler

To change the compiler used by `SibilantMake` and `SibilantCompile`, set
`sibilant_compiler` to the full path of an executable or the filename of one
in your `$PATH`:

    let sibilant_compiler = '/usr/bin/sibilant'

This option is set to `sibilant` by default.

### SibilantCompile: Compile Snippets of Sibilant

The `SibilantCompile` command shows how the current file or a snippet of
Sibilant is compiled to JavaScript. The full signature of the command is:

    :[RANGE] SibilantCompile [watch|unwatch] [vert[ical]] [WINDOW-SIZE]

Calling `SibilantCompile` without a range compiles the whole file.

Calling `SibilantCompile` with a range, like in visual mode, compiles the selected
snippet of Sibilant.

This scratch buffer can be quickly closed by hitting the `q` key.

Using `vert` splits the SibilantCompile buffer vertically instead of horizontally:

    :SibilantCompile vert

Set the `sibilant_compile_vert` variable to split the buffer vertically by
default:

    let sibilant_compile_vert = 1

The initial size of the SibilantCompile buffer can be given as a number:

    :SibilantCompile 4

#### Watch (live preview) mode

Watch mode is like the live Sibilant tutorial on the Sibilant homepage.

Writing some code and then writing the file automatically updates the
compiled JavaScript buffer.

Use `watch` to start watching a buffer (`vert` is also recommended):

    :SibilantCompile watch vert

After making some changes in insert mode, hit escape and the Sibilant will
be recompiled. Changes made outside of insert mode don't trigger this recompile,
but calling `SibilantCompile` will compile these changes without any bad effects.

To get synchronized scrolling of a Sibilant and SibilantCompile buffer, set
`scrollbind` on each:

    :setl scrollbind

Use `unwatch` to stop watching a buffer:

    :SibilantCompile unwatch

### SibilantRun: Run some Sibilant

The `SibilantRun` command compiles the current file or selected snippet and runs
the resulting JavaScript. Output is shown at the bottom of the screen.

