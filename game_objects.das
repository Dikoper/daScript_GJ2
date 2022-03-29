module game_objects public
require collision
require daslib/random
require graphics

struct MovingObstacle // ped or car
    posisiton:float2
    is_alive:bool
    target:float2
    speed:float

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
        trigger = [[SphereBound pos = position, radius = 10f, is_static = true, tag = TAGS TRIGGER ]]


class ActivitiesManager //TODO refactor this!
    points:array<ActivityPoint?>
    current_point:ActivityPoint?
    pick_point_idx:int
    drop_point_idx:int
    activity_state: STATES
    seed:int4
    complete_count:int // count of completed activities P->D

    def nextPoints()    
        var idx1 = random_int(seed) % length(points)
        var idx2 = (random_int(seed) + pick_point_idx) % length(points)
        
        if idx1 == idx2
            //panic("activities idx are the same")
            idx1++
            return
        
        pick_point_idx = idx1
        drop_point_idx = idx2

        points[pick_point_idx].is_active = true
        points[drop_point_idx].is_active = false

        current_point = points[pick_point_idx]

        activity_state = STATES PICKING


    def switchPoints()
        if(activity_state == STATES PICKING)
            points[pick_point_idx].is_active = false
            points[drop_point_idx].is_active = true
            current_point = points[drop_point_idx]
            activity_state = STATES DROPING
            return

        complete_count++ // there is a bug
        nextPoints()       
        return

    def drawPoint()
        current_point.trigger |> drawDebug()