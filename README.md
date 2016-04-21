# [Fractalrabbit.com](http://www.fractalrabbit.com)

Blog 'n' stuff, using `hugo`

## Install

 __First__:

1. `brew install hugo`
1. `mkdir fractalrabbit.com && cd fractalrabbit.com && hugo new site .`
1. `git clone git@github.com:SenjinDarashiva/hugo-uno.git themes/hugo-uno`
1. `hugo new post/welcome.md`
1. `hugo server -w`

__Second__:

- open `config.toml` and change the title & baseUrl; then add a theme setting (`theme = "hugo-uno"`)
- edit `content/post/welcome.md` and remove the `draft = true` line.  Add some content

__Third__:

Browse to [http://localhost:1313](http://localhost:1313)
