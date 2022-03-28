require daslib/media
require daslib/math

require camera
require vehicle
require collision
require game_objects
require menus

enum GAMESTATE
    MENU
    INGAME
    GAMEOVER
    SCORE
let
    timelimit = 100f * 60f //in seconds

var 
    SHOW_DEBUG = true
    player = new Car()
    map_image = create_managed_image("./images/map.jpg")
    colliders:array<SphereBound>
    cam:Camera
    a_points = new ActivitiesManager()
    game_state:GAMESTATE
    timer:float

def setupScreen()
    // var cameraMtx = compose(float4(get_screen_width()/2, get_screen_height()/2,0,1),
    //                     float4(0,0,0,1),
    //                     float4(50,-50,1,1))

    //setup_2d_camera(float2(get_screen_width() / 2, get_screen_height() / 2), 1.0)
    //transform2d_translate(float2(get_screen_width() / 2, get_screen_height() / 2))
    //transform2d_scale(float2(1f,1f),float2(0, 0))

    cam.pos = player.pos
    cam.scale = float2(2f,2f)
    cam.offset = camera::SCREEN_CENTRE

    return

def playerSetup()
    player.image <- create_managed_image("./images/car.png") // TODO move to another init
    player.collider.tag = TAGS CAR
    flip_image_x(player.image)
    return

def playerInit()
    player -> reset()
    player.pos = camera::SCREEN_CENTRE
    return

def placeColliders()
    var c1 = [[SphereBound pos = float2(200.,250.), radius = 150., is_static = true, tag = TAGS TRIGGER]]
    var c2 = [[SphereBound pos = float2(400.,500.), radius = 100., is_static = true, tag = TAGS BUILDING]]
    colliders |> push(c1)
    colliders |> push(c2)
    return

def initPoints()
    var c1 = new ActivityPoint(float2(550.,350.))
    var c2 = new ActivityPoint(float2(550.,250.))
    var c3 = new ActivityPoint(float2(650.,350.))
    var c4 = new ActivityPoint(float2(750.,250.))
    a_points.points |> push(c1)
    a_points.points |> push(c2)
    a_points.points |> push(c3)
    a_points.points |> push(c4)
    a_points->nextPoints()

def resetGame()
    timer = timelimit
    playerInit()
    return

[export]
def initialize
    setupScreen()
    playerSetup()
    placeColliders()
    initPoints()
    resetGame()

    set_window_title("Jam")

    game_state = GAMESTATE MENU
    return

[export]
def act(dt: float)
    if game_state == GAMESTATE INGAME 
        updateGame(dt) //TODO fix different namings(upper lower)
        return

    if game_state == GAMESTATE MENU  
        if get_key_down(VK_RETURN)
            resetGame()
            game_state = GAMESTATE INGAME
            return

    if game_state == GAMESTATE GAMEOVER
        if get_key_down(VK_RETURN)
            game_state = GAMESTATE SCORE
            return
    
    if game_state == GAMESTATE SCORE   
        if get_key_down(VK_RETURN)
            game_state = GAMESTATE MENU
            return

    if get_key_down(VK_ESCAPE)
        schedule_quit_game()

[export]
def draw

    if game_state == GAMESTATE INGAME   
        drawGame()
    
    if game_state == GAMESTATE MENU  
        showStartMenu()

    if game_state == GAMESTATE GAMEOVER
        set_font_size(20)
        text_out(SCREEN_CENTRE.x-20f,SCREEN_CENTRE.y-20f,"GAME OVER",0xFFFFFF)
        return
    
    if game_state == GAMESTATE SCORE   
        showScoreMenu()
    
    if(SHOW_DEBUG)
        text_out(0f,0f,"{game_state}",0xFFFFFF)
    return

def updateGame(dt:float&)
    if timer < 0f
        game_state = GAMESTATE GAMEOVER
    timer -= dt

    for c in colliders
        if c |> checkWith(player.collider)
            player.collided = true
            player.collided_with = c
            break
        player.collided = false
    
    if(a_points.current_point.trigger |> checkWith(player.collider) && length(player.velocity) < 0.01)
        a_points -> switchPoints()
    
    player->getInput()
    player->calculateForces(dt)
    player->updateCollider()

    cam.pos = lerp(cam.pos, player.pos - player.heading * -100f, 2f * dt) //jittering on turns

    if get_key_down(VK_TILDE)
        SHOW_DEBUG = !SHOW_DEBUG
    return

def drawGame()
    cam |> push()
    map_image |> draw_image_region(
        0f, 0f, 
        float4(300,200,900,600),
        0xffffff, 
        float2(get_screen_width(), get_screen_height()))
    
    player->drawCar()
    a_points->drawPoint()

    if(SHOW_DEBUG)
        for c in colliders
            c |> drawDebug()
        player->drawDebugGizmos()

    cam |> pop()
    drawUI()
    if(SHOW_DEBUG)
        player->drawDebugInfo(float2())
    return

def drawUI()
    var p = float2(5.,5.)

    text_out(p.x,p.y,"Score",0xFFFFFF)
    text_out(p.x,p.y+10f,"{a_points.complete_count}",0xFFFFFF)
    text_out(p.x,p.y+20f,"Time",0xFFFFFF)
    text_out(p.x,p.y+30f,"{int(timer)}",0xFFFFFF) //TODO show minutes and seconds
    return