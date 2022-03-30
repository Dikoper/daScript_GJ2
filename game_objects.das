module game_objects public
require collision
require daslib/random
require graphics

struct MovingObstacle // ped or car
    posisiton:float2
    is_alive:bool
    target:float2
    speed:float

struct Patient
    health:int
    is_active:bool

def doDamage(var p:Patient; dmg:DMG)
    if !p.is_active
        return
    if dmg != DMG NONE
        p.health -= 25
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
        trigger = [[SphereBound pos = position, radius = 10f, is_static = true, tag = DMG TRIGGER]]

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
            complete_count++ //?
        nextPoints()

    def drawPoint()
        current_point.trigger |> drawDebug()