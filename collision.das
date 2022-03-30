module collision public
require daslib/math
require daslib/graphics

enum DMG
    NONE
    BUILDING
    TRIGGER
    CAR
    PED

struct Collider
    pos:float2
    tag:DMG
    is_static:bool

struct AABBBound:Collider
    size:float2

def checkWith(var o:AABBBound;var c:SphereBound):bool
    //find closest to the sphere AABB point
    var minP = o.pos
    var maxP = o.pos + o.size
    var closest = c.pos

    if closest.x < minP.x
        closest.x = minP.x
    if closest.x > maxP.x
        closest.x = maxP.x
    
    if closest.y < minP.y
        closest.y = minP.y
    if closest.y > maxP.y
        closest.y = maxP.y

    if closest == c.pos
        return true

    //sphere test
    var dist = closest - c.pos
    return <- length_sq(dist) < (c.radius * c.radius)

def drawDebug(var o:AABBBound)
    rect(o.pos.x, o.pos.y, o.size.x, o.size.y, (0xABCDEF >> uint(o.tag)) * 2u)

struct SphereBound:Collider
    radius:float

def checkWith(var o:SphereBound;var c:SphereBound):bool
    let dist = o.pos - c.pos
    return <- length_sq(dist) < (o.radius + c.radius) * (o.radius + c.radius)

def drawDebug(var o:SphereBound)
    circle(o.pos.x, o.pos.y, o.radius, (0xABCDEF >> uint(o.tag)) * 2u)