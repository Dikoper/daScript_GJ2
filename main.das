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
    player:Car?
    map_image = create_managed_image("./images/map.jpg")
    static_colliders:array<AABBBound> //array of pointers
    dynamic_colliders:array<SphereBound> //array of pointers
    cam:Camera
    a_points = new ActivitiesManager()
    game_state:GAMESTATE
    timer:float
    timestamp:float
    time_from_start:float
    pat:Patient

def setupScreen()
    cam.pos = player.pos
    cam.scale = float2(3f)
    cam.offset = camera::SCREEN_CENTRE

def playerSetup()
    player = new Car(camera::SCREEN_CENTRE, "./images/car.png")

def playerInit()
    player -> reset()
    player.pos = camera::SCREEN_CENTRE
    pat.is_active = false

def placeColliders()
    var c1 = [[SphereBound pos = float2(200.,250.), radius = 150f, is_static = false, tag = DMG CAR]]
    var c2 = [[SphereBound pos = float2(400.,500.), radius = 100f, is_static = false, tag = DMG TRIGGER]]

    var c3 = [[AABBBound pos = float2(500.,300.), size = float2(100.,100.), is_static = true, tag = DMG BUILDING]]
    var c4 = [[AABBBound pos = float2(700.,300.), size = float2(100.,100.), is_static = true, tag = DMG BUILDING]]

    dynamic_colliders |> push(c1)
    dynamic_colliders |> push(c2)
    
    static_colliders |> push(c3)
    static_colliders |> push(c4)

def initPoints()
    a_points.pick_points |> push(new ActivityPoint(float2(850.,450.)))
    a_points.pick_points |> push(new ActivityPoint(float2(850.,550.)))
    a_points.drop_points |> push(new ActivityPoint(float2(950.,450.)))
    a_points.drop_points |> push(new ActivityPoint(float2(950.,550.)))

    a_points->nextPoints()
    a_points.activity_state = STATES PICKING
    a_points.complete_count = 0

def resetGame()
    timer = timelimit
    timestamp = 0f
    playerInit()
    return

[export]
def initialize
    playerSetup()
    placeColliders()
    initPoints()
    resetGame()

    set_window_title("Jam")
    setupScreen()

    game_state = GAMESTATE MENU
    return

[export]
def act(dt: float)
    if get_key_down(VK_ESCAPE)
        schedule_quit_game()
    time_from_start += dt

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

    player.collided = false
    for c in static_colliders
        if c |> checkWith(player.collider)
            player.collided = true
            player.collided_with = c.tag
            if(c.tag == DMG BUILDING)
                pat |> doDamage(c.tag)
            break
    
    for c in dynamic_colliders
        if c |> checkWith(player.collider)
            player.collided_with = c.tag
            player.collided = true
            if(c.tag == DMG CAR)
                pat |> doDamage(c.tag)
            break
    
    randomize_seed(a_points.seed)
    
    if (a_points.current_point.trigger |> checkWith(player.collider))
        if (length(player.velocity) < 0.01)
            a_points -> switchPoints(pat.is_active)
    
    if (a_points.activity_state == STATES DROPING)
        pat.is_active = true
        if timestamp > 1.0
            pat |>doDamage(DMG NONE)
            timestamp = 0f
        timestamp += dt

        if (pat.health < 1)
            pat.is_active = false
            pat.health = 100
            a_points.activity_state = STATES PICKING
            a_points -> nextPoints()
    
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
        for c in static_colliders
            c |> drawDebug()
        for c in dynamic_colliders
            c |> drawDebug()
        player->drawDebugGizmos()
    //point arrow
    var pointline = normalize(a_points.current_point.position - player.pos) * 20f
    line(player.pos.x, player.pos.y, player.pos.x + pointline.x, player.pos.y + pointline.y, 0xFF0000)

    cam |> pop()
    drawUI()
    if(SHOW_DEBUG)
        player->drawDebugInfo(float2())
        text_out(SCREEN_CENTRE.x,0f,"{a_points.activity_state}",0xFFFFFF)    
    return

def drawUI()
    var p = float2(float(get_screen_width() - 100), 0f)

    text_out(p.x,p.y,"Score",0xFFFFFF)
    text_out(p.x,p.y+10f,"{a_points.complete_count}",0xFFFFFF)
    text_out(p.x,p.y+20f,"Time",0xFFFFFF)
    text_out(p.x,p.y+30f,"{int(timer)}",0xFFFFFF) //TODO show minutes and seconds
    text_out(p.x,p.y+40f,"Patient",0xFFFFFF)
    text_out(p.x,p.y+50f,"{int(pat.health)}",0xFFFFFF) //TODO show only when patient is on board