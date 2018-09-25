module.exports =
    activate: (state) ->
        atom.config.observe "anime-dark-ui.tab", (value) ->
            if(value == "soft")
                document.querySelector(".tab-bar").attributes
            else ()
