using MyPkg
using Documenter

DocMeta.setdocmeta!(MyPkg, :DocTestSetup, :(using MyPkg); recursive=true)

makedocs(;
    modules=[MyPkg],
    authors="SatoshiTerasaki <terasakisatoshi.math@gmail.com> and contributors",
    repo="https://github.com/terasakisatoshi/jldev_poetry.jl/blob/{commit}{path}#{line}",
    sitename="jldev_poetry.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://terasakisatoshi.github.io/jldev_poetry.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/terasakisatoshi/jldev_poetry.jl",
    devbranch="main",
)
