module camera shared
require graphics

let SCREEN_CENTRE = float2(get_screen_width() / 2, get_screen_height() / 2)

struct Camera
    pos:float2
    offset:float2
    scale = float2(1f,1f)

def push(var c:Camera)
    transform2d_push()
    transform2d_translate(-c.pos + c.offset) //translate vector is reversed
    transform2d_scale(c.scale, c.pos)

def pop(var c:Camera)
    transform2d_pop()

def camToWorld(var c:Camera; v:float2):float2
    return v + c.pos - c.offset

def camToLocal(var c:Camera; v:float2):float2
    return v - c.pos + c.offset
