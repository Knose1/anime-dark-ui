background_interval = -1;
currentBackground = -1;
theme = "anime-dark-ui"
transTimeout = -1;


module.exports =
    activate: (state) ->
        transElm.add();

        atom.config.observe "#{theme}.tab", (value) ->
            setTab(value);
        atom.config.observe "#{theme}.timing.timer", (timer) ->

            backgrounds = loadBackground();

            # -- Timer > 0 -- #
            if timer != 0 && backgrounds.length != 0
                setBGinter(timer);

            #-- Random Background --#
            else if backgrounds.length != 0
                unsetBGinter();

                try
                    clearTimeout(transTimeout)
                catch error


                newBackground = currentBackground;
                while currentBackground == newBackground
                    newBackground = Math.floor(Math.random() * backgrounds.length);

                currentBackground = newBackground;

                setBackground(backgrounds[newBackground]);
            else
                setBackground(backgrounds[0]);

        atom.config.observe "#{theme}.darkObject.dark", (value) ->
            setDarkBG(value);

        atom.config.observe "#{theme}.darkObject.dark_settings", (value) ->
            setDarkBGSettings(value)

    desactivate: ->
        transElm.remove();
        unsetTab();
        unsetBGinter();
        unsetBackground();
        removeDarkBG();
        removeDarkBGSettings();







# -- Transition -- #

transElm = {
    it: () ->
        return document.querySelector("body bg-transition");

    add: () ->
        document.body.appendChild(transElm.it() || document.createElement("bg-transition"))
    remove: () ->
        document.querySelectorAll("body bg-transition").forEach (e) ->
            document.body.removeChild(e);

        try
            clearTimeout(transTimeout)
        catch error

}



setTransition = (url) ->

    if (transElm.it() == null)
        transElm.add();

    if (transElm.it() == null)
        return atom.notifications.addInfo("Cannot add the transition element, please restart your Atom");

    transTimeout = setTimeout(() ->
        if (url != undefined)
            url = url.replace(/\\/g,"/");
            transElm.it().style.backgroundImage = "url( \"#{url} \")";
            transElm.it().style.transition = "none";
            transElm.it().style.opacity = "1";
        clearTimeout(transTimeout);
    ,atom.config.get( "#{theme}.timing.transiton") * 1000)


playTransition = () ->
    transElm.it().style.transition = "#{atom.config.get "#{theme}.timing.transiton"}s linear opacity";
    transElm.it().style.opacity = "0";







# -- Tab type -- #

setTab = (value) ->
    if value == "soft"
        document.querySelectorAll(".tab-bar").forEach (elm) ->
            elm.setAttribute("h","22px")
    else
        document.querySelectorAll(".tab-bar").forEach (elm) ->
            elm.setAttribute("h","30px")



unsetTab = () ->
    document.querySelectorAll(".tab-bar").forEach (elm) ->
        elm.removeNamedItem("h")







# -- set Background -- #

setBackground = (url) ->
    if (url != undefined)
        url = url.replace(/\\/g,"/")
        document.body.style.backgroundImage = "url( \"#{url} \")";
        #document.body.style.transition = "#{atom.config.get "#{theme}.timing.transiton"}s linear background-image";
        console.log("new background detected: \"#{url}\"");



loadBackground = () ->
    backgrounds = atom.config.get "#{theme}.backgrounds";
    i = -1;
    backgrounds.array = [];
    while i < 10
        i += 1;
        backgrounds.array.push(backgrounds[i])

    backgrounds = backgrounds.array;

    # remove "null" parameters
    backgrounds = backgrounds.filter (f) ->
        return f && f != "null";

    return backgrounds;



unsetBackground = () ->
    document.body.style.backgroundImage = "unset"







# -- timer -- #

setBGinter = (timer) ->
    console.log("setBGinter() called");
    if background_interval != 0
        clearInterval(background_interval);
    else
        backgrounds = loadBackground();

        newBackground = currentBackground;
        while currentBackground == newBackground
            newBackground = Math.floor(Math.random() * backgrounds.length);

        currentBackground = newBackground;
        setTransition(backgrounds[currentBackground]);
        playTransition();
        setBackground(backgrounds[currentBackground]);

    background_interval = setInterval(
        ()->
            backgrounds = loadBackground();

            newBackground = currentBackground;
            while currentBackground == newBackground
                newBackground = Math.floor(Math.random() * backgrounds.length);

            currentBackground = newBackground;
            setTransition(backgrounds[newBackground]);
            playTransition();
            setBackground(backgrounds[newBackground]);

        , 60000 * timer;
    )



unsetBGinter = () ->
    if background_interval != 0
        clearInterval(background_interval);
    background_interval = 0;







# -- Background color opacity -- #

setDarkBG = (alpha) ->
    document.querySelector("atom-workspace.workspace.scrollbars-visible-always").style.backgroundColor = "rgba(0, 0, 0, #{alpha / 100})"
    console.log("darkBG alpha is now #{alpha}%")

removeDarkBG = () ->
    document.querySelector("atom-workspace.workspace.scrollbars-visible-always").style.backgroundColor = "unset"






# -- Setting Background color opacity -- #

setDarkBGSettings = (alpha) ->
    if document.querySelector("style.animeDarkUi.setDarkBGSettings")
        document.querySelector("style.animeDarkUi.setDarkBGSettings").innerHTML =
        "
            atom-pane-container atom-pane .item-views .pane-item:not(.styleguide) div.panels {\n
                \tbackground-color:rgba(0, 0, 0, #{alpha / 100});\n
            }\n
            atom-pane-container atom-pane .item-views .pane-item:not(.styleguide) div.config-menu {\n
                \tbackground-color:rgba(0, 0, 0, #{(alpha - 10) / 100});\n
            }
        "

    else
        style = document.createElement("style");
        style.classList.add("animeDarkUi","setDarkBGSettings");
        style.innerHTML =
        "
            atom-pane-container atom-pane .item-views .pane-item:not(.styleguide) div.panels {\n
                \tbackground-color:rgba(0, 0, 0, #{alpha / 100});\n
            }\n
            atom-pane-container atom-pane .item-views .pane-item:not(.styleguide) div.config-menu {\n
                \tbackground-color:rgba(0, 0, 0, #{(alpha - 10) / 100});\n
            }
        "
        style.priority = "2"
        document.querySelector("atom-styles").appendChild(style)

    console.log("darkBG-Settings alpha is now #{alpha}%");

removeDarkBGSettings = () ->
    document.querySelector("atom-styles").removeChild(document.querySelector("style.animeDarkUi.setDarkBGSettings"));
