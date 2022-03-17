module vehicle shared

require daslib/media
require daslib/math

class Car
    image: ImageHandle
//vehicle attrib
    mass = 2f
    steering_angle = 0.9f //in rad
    wheelbase = 20f
    friction = -0.9f
//spatial values
    pos:float2
    heading = float2(0.0,1.0) //forward vector
    front_ax:float2
    rear_ax:float2
//physics values
    velocity:float2
    traction:float
    rotation:float
    acceleration:float2
//input values
    throttle:float
    steer_dir:int

    def reset()
        pos = float2()
        return

    def calculateForces(dt:float)
        acceleration = heading * throttle

        if (length(velocity) < 0.001f)
            velocity = float2()
        acceleration += velocity * friction

        velocity += acceleration * dt

        rear_ax = pos - heading * wheelbase/2f
        front_ax = pos + heading * wheelbase/2f

        rear_ax += velocity / mass
        front_ax += rotate2D(velocity, float(steer_dir) * steering_angle) / mass;

        var new_heading = normalize(front_ax - rear_ax)

        velocity = lerp(velocity, new_heading * length(velocity), traction)

        pos += velocity

        rotation = atan2(new_heading.y, new_heading.x) //heavy operation cost?
        heading  = float2(cos(rotation), sin(rotation))
        return

    def getInput()
        steer_dir = 0
        throttle = 0f
        traction = 0.1f
        if get_key(VK_UP)
            throttle = 1.1f
        if get_key(VK_DOWN)
            throttle = -0.1f
        if get_key(VK_LEFT)
            steer_dir = -1
        if get_key(VK_RIGHT)
            steer_dir = 1
        if get_key(VK_SPACE)
            traction = 0.01f
        if get_key(VK_R)
            self->reset()
        return

    def drawCar()
        //shadow
        image |> draw_image_transformed(
            pos.x+3f,pos.y+3f,
            float4(0,0, image.width, image.height),
            0x000000,
            float2(wheelbase,wheelbase/2f),
            rotation)
        //car
        image |> draw_image_transformed(
            pos.x,pos.y, 
            float4(0,0, image.width, image.height),
            0xFFFFFF,
            float2(wheelbase,wheelbase/2f),
            rotation)
        return

    def drawDebugInfo()
        var text_pos = int2(10f,10f)
        var infoText = "Test(~ to close)\n pos - {pos}\n throttle - {throttle}\n track - {traction}\n vel - {length(velocity)}\n steer - {float(steer_dir) * steering_angle}"
        text_out(text_pos.x,text_pos.y, infoText,0xFF00FF00)

        var f = front_ax;
        var r = rear_ax
        line(r.x,r.y,f.x,f.y,0xFFFFFF )
        circle(f.x,f.y,3f,0xFF0000)
        circle(r.x,r.y,3f,0xFDF901)

        line(pos.x,pos.y,pos.x + velocity.x ,pos.y + velocity.y, 0x00FF00)
        line(pos.x,pos.y,pos.x + heading.x* 10f,pos.y + heading.y* 10f, 0xF003F8)
        return

def rotate2D(v:float2; angle:float):float2
    var result = float2()
    result.x = v.x * cos(angle) - v.y * sin(angle)
    result.y = v.x * sin(angle) + v.y * cos(angle)
    return result