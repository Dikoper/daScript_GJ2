module map public

require daslib/media

var player_spawn = float2(1100,730)

var static_boxes = [[float4[]
    float4(540,250,390,50);
    float4(520,310,68,68);
    float4(590,365,265,105);
    float4(910,310,320,150);
    float4(1230,300,205,130);
    float4(1445,300,70,850);
    float4(520,470,125,45);
    float4(420,520,192,570);
    float4(370,1088,55,130);
    float4(425,1185,255,40);
    float4(675,1045,760,180);
    float4(705,530,380,65);
    float4(725,660,350,35);
    float4(700,710,120,250);
    float4(820,710,155,95);
    float4(980,740,95,65);
    float4(950,860,415,120);
    float4(1160,535,190,260)
]]

var drops = [[float2[]
    float2(630,630);
    float2(1335,1035)
]]

var picks = [[float2[]
    float2(470,1140);
    float2(860,860);
    float2(1330,460);
    float2(660,330);
    float2(900,620);
    float2(1400,830);
    float2(1160,535)
]]

var navpoints = [[float2[]
    float2(660,1000);
    float2(1410,1010);
    float2(1400,500);
    float2(675,500)
]]

var map_image = create_managed_image("./images/tst4.jpg") // TODO move to another module

def drawMap()
    map_image |> draw_image_region(
        0f, 0f, 
        float4(0,0,map_image.width,map_image.height),//float4(300,200,900,600),
        0xffffff,
        float2(float(get_screen_width())*1.5, float(get_screen_height())*2.0))

