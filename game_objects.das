module game_objects public
require collision
require daslib/random
require daslib/media
require math

var catch_sound: SoundHandle <- create_managed_sound("./sounds/catch.wav")

var imgs = [[ImageHandle[]
    create_managed_image("./images/taxi.png");
    create_managed_image("./images/van.png");
    create_managed_image("./images/mini_truck.png");
    create_managed_image("./images/car.png")
    ]]

struct MovingObstacle
    img:ImageHandle
    collider:SphereBound
    position:float2
    target:float2
    velocity:float2
    speed:float
    rotation:float
    is_alive:bool
    is_collide:bool
    t_idx:int

class ObstaclesManager
    cars:array<MovingObstacle>
    waypoints:array<float2>
    seed:int4
    COOLDOWN = 3f
    timer:float

    def update(dt:float)
        for c in cars
            if c.is_alive
                var dist =  c.target - c.position
                if c.is_collide
                    c.velocity = normalize(c.target - c.position) * c.speed * -0.9f
                    c.target = getNewTarget(c.t_idx, false)
                    
                    c.position += c.velocity
                    c.collider.pos = c.position
                    c.rotation = atan2(dist.y, dist.x)
                    break
                if length(dist) > 1.0f
                    c.velocity = normalize(c.target - c.position) * c.speed
                    c.position += c.velocity
                    c.collider.pos = c.position
                    c.rotation = atan2(dist.y, dist.x)
                else
                    c.target = getNewTarget(c.t_idx,true)

        if(timer > COOLDOWN) 
            debug(timer)
            if(length(cars) < 20)
                spawnObstacle()
                timer = 0f
        timer += dt    
        return

    def getNewTarget(var idx:int&; move_next:bool):float2
        if move_next
            idx = ++idx % length(waypoints)
        else
            idx = random_int(seed) % length(waypoints)
        return waypoints[idx]
    
    def spawnObstacle()
        var p1 = waypoints[random_int(seed) % length(waypoints)] 
        randomize_seed(seed)
        var p2 = waypoints[random_int(seed) % length(waypoints)] 
        var p = p1 + float2( random_int(seed)%20, random_int(seed)%20)
        var t = p2 + float2( random_int(seed)%20, random_int(seed)%20)
        var c = [[SphereBound pos = p, radius = 10f, is_static = false, tag = DMG CAR]]
        var o = [[MovingObstacle position = p, target = t, is_alive = true, speed = 0.5f, collider = c, img = imgs[random_int(seed)%4]]]
        cars |> push(o)
        return
    
    def draw()
        for c in cars
            var clr = c.is_alive ? 0xFFFFFF : 0x000000
            c.img |> draw_image_transformed(
                c.position.x, c.position.y,
                float4(0,0, c.img.width, c.img.height),
                clr,
                float2(c.collider.radius * 3f ,c.collider.radius * 1.5f),
                c.rotation)
        return

struct Patient
    health:int
    is_active:bool

def doDamage(var p:Patient; dmg:DMG)
    if !p.is_active
        return
    if dmg != DMG NONE
        p.health -= 5
        return
    p.health--

enum STATES
    PICKING
    DROPING

class ActivityPoint //drop and pick points
    position:float2
    is_active:bool
    trigger:SphereBound

    def ActivityPoint(p:float2)
        position = p
        is_active = false
        trigger = [[SphereBound pos = position, radius = 25f, is_static = true, tag = DMG TRIGGER]]

class ActivitiesManager //TODO refactor this!
    pick_points:array<ActivityPoint?>
    drop_points:array<ActivityPoint?>
    current_point:ActivityPoint?
    seed:int4
    pidx:int
    didx:int
    complete_count:int
    activity_state: STATES   

    def nextPoints()    
        pidx = random_int(seed) % length(pick_points)
        didx = random_int(seed) % length(drop_points)

        current_point = pick_points[pidx]
        current_point.is_active = true
        activity_state = STATES PICKING

    def switchPoints(is_complete:bool)
        if(activity_state == STATES PICKING)
            current_point = drop_points[didx]
            current_point.is_active = true
            activity_state = STATES DROPING
            return

        if is_complete
            complete_count++
            catch_sound |> play_sound()
        nextPoints()

    def drawPoint()
        current_point.trigger |> drawDebug()