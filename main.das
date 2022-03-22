require daslib/media
require daslib/math

require camera
require vehicle
require collision

var 
    SHOW_DEBUG = true
    player = new Car()
    map_image:ImageHandle
    colliders:array<SphereBound>
    cam:Camera

def setupScreen()
    var cameraMtx = compose(float4(get_screen_width()/2, get_screen_height()/2,0,1),
                        float4(0,0,0,1),
                        float4(50,-50,1,1))

    //setup_2d_camera(float2(get_screen_width() / 2, get_screen_height() / 2), 1.0)
    //transform2d_translate(float2(get_screen_width() / 2, get_screen_height() / 2))
    //transform2d_scale(float2(1f,1f),float2(0, 0))

    cam.pos = player.pos
    cam.scale = float2(2f,2f)
    cam.offset = camera::SCREEN_CENTRE

    return

def playerSetup()
    player.pos = camera::SCREEN_CENTRE
    player.image <- create_managed_image("./images/car.png")
    player.collider.tag = TAGS CAR
    flip_image_x(player.image)
    return

def placeColliders()
    var c1 = [[SphereBound pos = float2(200.,250.), radius = 150., is_static = true, tag = TAGS TRIGGER]]
    var c2 = [[SphereBound pos = float2(400.,500.), radius = 100., is_static = true, tag = TAGS BUILDING]]
    colliders |> push(c1)
    colliders |> push(c2)
    return

[export]
def initialize
    setupScreen()
    playerSetup()
    placeColliders()

    map_image <- create_managed_image("./images/map.jpg")

    set_window_title("Jam")
    return

[export]
def act(dt: float)

    for c in colliders
        if c |> checkWith(player.collider)
            player.collided = true
            player.collided_with = c
            break
        player.collided = false
    
    player->getInput()
    player->calculateForces(dt)
    player->updateCollider()

    cam.pos = lerp(cam.pos, player.pos - player.heading * -100f, 2f * dt) //jittering on turns

    if get_key_down(VK_ESCAPE)
        schedule_quit_game()
    if get_key_down(VK_TILDE)
        SHOW_DEBUG = !SHOW_DEBUG
    return

[export]
def draw
    cam |> push()
    map_image |> draw_image_region(
        0f, 0f, 
        float4(300,200,900,600),
        0xffffff, 
        float2(get_screen_width(), get_screen_height()))
    player->drawCar()
    
    if(SHOW_DEBUG)
        for c in colliders
            c |> drawDebug()
        player->drawDebugGizmos()
    cam |> pop()
    player->drawDebugInfo(float2())
    return