require daslib/media
require daslib/math
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code

var cameraMtx = compose(float4(get_screen_width()/2, get_screen_height()/2,0,1),
                        float4(0,0,0,1),
                        float4(50,-50,1,1))

def rotateOnZ(v:float2; angle:float):float2
    var result = float2()
    result.x = v.x * cos(angle) - v.y * sin(angle)
    result.y = v.x * sin(angle) + v.y * cos(angle)
    return result

class Car
    image: ImageHandle
    pos:float2
    velocity:float2
    front_ax:float2
    rear_ax:float2
    heading = float2(0.0,1.0) //forward vector
    steer_dir:int
    throttle:float
    acceleration:float2
    friction = -0.9f
    steering_angle = 0.9f //15 in rad
    tracktion:float
    mass = 2f

    rotation:float

    wheelbase = 20f

    def reset()
        pos = float2()
        return

    def calculateForces(dt:float)
        acceleration = normalize(heading) * throttle

        if (length(velocity) < 0.001f)
            velocity = float2()
        acceleration += velocity * friction

        velocity += acceleration * dt

        rear_ax = pos - heading * wheelbase/2f
        front_ax = pos + heading * wheelbase/2f

        rear_ax += velocity / mass
        front_ax += rotateOnZ(velocity, float(steer_dir) * steering_angle) / mass;

        var new_heading = normalize(front_ax - rear_ax)

        velocity = lerp(velocity, new_heading * length(velocity), tracktion)

        pos += velocity

        rotation = atan2(new_heading.y, new_heading.x)
        heading  = float2(cos(rotation), sin(rotation))

        return

    def getInput(dt:float)
        steer_dir = 0
        throttle = 0f
        tracktion = 0.1f
        if get_key(VK_UP)
            throttle = 1.1f
        if get_key(VK_DOWN)
            throttle = -0.1f
        if get_key(VK_LEFT)
            steer_dir = -1
        if get_key(VK_RIGHT)
            steer_dir = 1
        if get_key(VK_SPACE)
            tracktion = 0.01f
        if get_key(VK_R)
            self->reset()
        return

    def drawCar()
        var f = front_ax;
        var r = rear_ax
        line(r.x,r.y,f.x,f.y,0xFFFFFF )
        circle(f.x,f.y,3f,0xFF0000)
        circle(r.x,r.y,3f,0xFDF901)
        //shadow
        image |> draw_image_transformed(
            pos.x+3f,pos.y+3f,
            float4(0,0, image.width, image.height),
            0x000000,
            float2(wheelbase,wheelbase/2f),
            rotation)
        
        image |> draw_image_transformed(
            pos.x,pos.y, 
            float4(0,0, image.width, image.height),
            0xFFFFFF,
            float2(wheelbase,wheelbase/2f),
            rotation)
        


        return
    
    def drawDebugInfo()
        var text_pos = int2(10f,10f)
        var infoText = "Test\n pos - {pos}\n throttle - {throttle}\n track - {tracktion}\n vel - {length(velocity)}\n steer - {float(steer_dir) * steering_angle}"
        text_out(text_pos.x,text_pos.y, infoText,0xFF00FF00)

        //velocity
        line(pos.x,pos.y,pos.x + velocity.x ,pos.y + velocity.y, 0x00FF00)
        line(pos.x,pos.y,pos.x + heading.x* 10f,pos.y + heading.y* 10f, 0xF003F8)
        //line(pos.x,pos.y,pos.x + curr.x* 10f,pos.y + curr.y* 10f, 0xD9E25C)
        return

var player = new Car()

var map_image :ImageHandle

// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    //setup_2d_camera(float2(get_screen_width() / 2, get_screen_height() / 2), 1.0)
    //transform2d_translate(float2(get_screen_width() / 2, get_screen_height() / 2))
    transform2d_scale(float2(1f,1f),float2(0, 0))
//player init
    player.pos = float2(get_screen_width() / 2, get_screen_height() / 2)
    player.image <- create_managed_image("images/car.png")
    flip_image_x(player.image)

    map_image <- create_managed_image("images/map.jpg")

    set_window_title("Jam")
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()

    player->getInput(dt)
    player->calculateForces(dt)
    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    draw_image_region(map_image, 
        0f, 0f, 
        float4(300,200,900,600), 
        0xffffff, 
        float2(get_screen_width(), get_screen_height()))
    player->drawCar()
    player->drawDebugInfo()
    return
