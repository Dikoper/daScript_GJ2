module collision public
require daslib/math
require daslib/graphics

enum TAGS
    NONE
    BUILDING
    TRIGGER
    CAR
    PED

struct AABBBound
    pos:float2
    size:float2

def checkWith(o:AABBBound ; c:AABBBound):bool
    var is_collide = false

    //if collided - true
    return <- is_collide

struct SphereBound
    pos:float2
    radius:float

    is_static:bool
    tag:TAGS

def drawDebug(var b:SphereBound)
    circle(b.pos.x,b.pos.y,b.radius,(0xABCDEF >> uint(b.tag)) * 2u)

def checkWith(o:SphereBound& ; c:SphereBound&):bool
    var is_collide = false

    let dist = o.pos - c.pos
    is_collide = length_sq(dist) < (o.radius + c.radius) * (o.radius + c.radius) 
    return <- is_collide