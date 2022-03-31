module menus public

require daslib/media

var
    startBackground <- create_image("./images/menu.png")
    scoreBackground <- create_image("./images/score.png")

    startMusic: SoundHandle <- create_managed_sound("./sounds/intro.mp3")
    ingameMusic: SoundHandle <- create_managed_sound("./sounds/ingame.mp3")
    scoreMusic: SoundHandle <- create_managed_sound("./sounds/score.mp3")

def showStartMenu()
    startBackground |> draw_image(
        0f, 0f,
        0xffffff, 
        float2(get_screen_width(), get_screen_height()))
    return

def showScoreMenu(score:int)
    scoreBackground |> draw_image(
        0f, 0f,
        0xffffff, 
        float2(get_screen_width(), get_screen_height()))
    
    set_font_size(120)
    text_out(get_screen_width()/2 - 400,get_screen_height()/2 - 100,"SCORE: {score}",0xFFFFFF)

    set_font_size(14)

    return