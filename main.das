require daslib/media
require daslib/math
require vehicle

var SHOW_DEBUG = true

var cameraMtx = compose(float4(get_screen_width()/2, get_screen_height()/2,0,1),
                        float4(0,0,0,1),
                        float4(50,-50,1,1))

var player = new vehicle::Car()

var map_image :ImageHandle

def setupScreen()
    //setup_2d_camera(float2(get_screen_width() / 2, get_screen_height() / 2), 1.0)
    //transform2d_translate(float2(get_screen_width() / 2, get_screen_height() / 2))
    transform2d_scale(float2(1f,1f),float2(0, 0))
    return

def playerSetup()
    player.pos = float2(get_screen_width() / 2, get_screen_height() / 2)
    player.image <- create_managed_image("images/car.png")
    flip_image_x(player.image)
    return

[export]
def initialize
    setupScreen()
    playerSetup()

    map_image <- create_managed_image("images/map.jpg")

    set_window_title("Jam")
    return

[export]
def act(dt: float)
    player->getInput()
    player->calculateForces(dt)

    if get_key_down(VK_ESCAPE)
        schedule_quit_game()
    if get_key_down(VK_TILDE)
        SHOW_DEBUG = !SHOW_DEBUG
    return

[export]
def draw
    map_image |> draw_image_region(
        0f, 0f, 
        float4(300,200,900,600), 
        0xffffff, 
        float2(get_screen_width(), get_screen_height()))
    player->drawCar()
    if(SHOW_DEBUG)
        player->drawDebugInfo()
    return
