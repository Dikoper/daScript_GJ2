require daslib/media
require daslib/math

require camera
require vehicle
require collision
require game_objects
require menus
require map

enum GAMESTATE
    MENU
    INGAME
    GAMEOVER
    SCORE

let
    timelimit = 3f * 60f //in seconds

var 
    SHOW_DEBUG = false
    static_colliders:array<AABBBound>
    player:Car?
    obstacles = new ObstaclesManager()
    a_points = new ActivitiesManager()
    cam:Camera
    pat:Patient
    game_state:GAMESTATE
    timer:float
    timestamp:float
    time_from_start:float

    scrm_sound: SoundHandle <- create_managed_sound("./sounds/scream.mp3")

    mus_hndlr: PlayingSoundHandle

def setupScreen()
    cam.pos = player.pos
    cam.scale = float2(3f)
    cam.offset = camera::SCREEN_CENTRE

def playerSetup()
    player = new Car(camera::SCREEN_CENTRE, "./images/ambulance.png")
    //make_image_color_transparent(player.image, get_pixel(player.image, 0, 0))

def playerInit()
    player -> reset()
    player.pos = player_spawn
    pat.is_active = false

def placeColliders()   
    for b in static_boxes
        var c = [[AABBBound pos = float2(b[0],b[1]), size = float2(b[2],b[3]), is_static = true, tag = DMG BUILDING]]
        static_colliders |> push(c)

def initPoints()
    for n in navpoints
        obstacles.waypoints |> push(n)

    for d in drops
        a_points.drop_points |> push(new ActivityPoint(d))

    for p in picks
        a_points.pick_points |> push(new ActivityPoint(p))

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
    set_resolution(1280, 720)
    setupScreen()

    game_state = GAMESTATE MENU
    return

[export]
def act(dt: float)
    if get_key_down(VK_ESCAPE)
        schedule_quit_game()
    time_from_start += dt

    if game_state == GAMESTATE INGAME
        if !is_playing(mus_hndlr)
            mus_hndlr = play_sound(ingameMusic)
        updateGame(dt) //TODO fix different namings(upper lower)
        return

    if game_state == GAMESTATE MENU
        if !is_playing(mus_hndlr)
            mus_hndlr = play_sound(startMusic)
        if get_key_down(VK_RETURN)
            resetGame()
            game_state = GAMESTATE INGAME
            return

    if game_state == GAMESTATE GAMEOVER
        if get_key_down(VK_RETURN)
            game_state = GAMESTATE SCORE
            return
    
    if game_state == GAMESTATE SCORE
        if !is_playing(mus_hndlr)
            mus_hndlr = play_sound(scoreMusic)
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
        drawGame()
        set_font_size(60)
        text_out(SCREEN_CENTRE.x-150f,SCREEN_CENTRE.y-20f,"GAME OVER\npress return", 0xFFAAFF)
        return
    
    if game_state == GAMESTATE SCORE   
        showScoreMenu(a_points.complete_count * 100)
    
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

    for o in obstacles.cars
        o.is_collide = false
        if o.is_alive && (o.collider |> checkWith(player.collider))
            o.is_collide = true
            o.is_alive = false
            player.collided_with = o.collider.tag
            player.collided = true
            if(o.collider.tag == DMG CAR)
                pat |> doDamage(o.collider.tag)
            break
        for c in static_colliders
            if c |> checkWith(o.collider)
                o.is_collide = true

    
    obstacles->update(dt)
    
    randomize_seed(a_points.seed)
    randomize_seed(obstacles.seed)
    
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
            scrm_sound |> play_sound(0.9f)
    
    player->getInput()
    player->calculateForces(dt)
    player->updateCollider()

    cam.pos = lerp(cam.pos, player.pos - player.heading * -100f, 2f * dt) //jittering on turns

    if get_key_down(VK_TILDE)
        SHOW_DEBUG = !SHOW_DEBUG
    return

def drawGame()
    cam |> push()
    drawMap()
    
    player->drawCar()
    
    a_points->drawPoint()
    obstacles->draw()
    

    if(SHOW_DEBUG)
        for c in static_colliders
            c |> drawDebug()
        player->drawDebugGizmos()
    //point arrow
    var pointline = normalize(a_points.current_point.position - player.pos) * 20f
    fill_circle(player.pos.x + pointline.x, player.pos.y + pointline.y, 1f, 0xFF0000)
    line(player.pos.x, player.pos.y, player.pos.x + pointline.x, player.pos.y + pointline.y, 0xFF0000)

    cam |> pop()
    drawUI()
    if(SHOW_DEBUG)
        player->drawDebugInfo(float2())
        text_out(SCREEN_CENTRE.x,0f,"{a_points.activity_state}",0xFFFFFF)
    return

def drawUI()
    set_font_size(40)
    text_out(10,10,"Saved",0xAAFF33)
    text_out(10,50,"{a_points.complete_count}",0xFFFFFF)
    text_out(float(get_screen_width() - 200), 10f,"{int(timer/60f)}:{int(timer%60f)}",0xFF0000) //TODO show minutes and seconds
    if(a_points.activity_state == STATES DROPING)
        text_out(SCREEN_CENTRE.x,10f,"{int(pat.health)}",0x11EE11) //TODO show only when patient is on board
    set_font_size(20)