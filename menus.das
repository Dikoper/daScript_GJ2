module menus public

require daslib/media

var
    startBackground <- create_image("./images/start.jpg")
    tutorialBackground <- create_image("./images/tutorial.jpg")
    scoreBackground <- create_image("./images/score.jpg")

def showStartMenu()
    startBackground |> draw_image(
        0f, 0f,
        0xffffff, 
        float2(get_screen_width(), get_screen_height()))
    return

def showTutorial()
    tutorialBackground |> draw_image(
        0f, 0f,
        0xffffff, 
        float2(get_screen_width(), get_screen_height()))
    return

def showScoreMenu()
    scoreBackground |> draw_image(
        0f, 0f,
        0xffffff, 
        float2(get_screen_width(), get_screen_height()))
    return