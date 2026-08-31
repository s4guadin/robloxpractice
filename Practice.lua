local BLOCKED_PLACE_ID=114234929420007
if game.PlaceId==BLOCKED_PLACE_ID then
    warn("esse jogo tem proteção anti-menu do nosso sistema, não é possível usar neste jogo")
    return
end

P,T,A,X=game:GetService("Players"),game:GetService("TweenService"),game:GetService("AssetService"),game:GetService("TextService")

local pg=P.LocalPlayer:WaitForChild("PlayerGui")local o=pg:FindFirstChild("PracticeIntro")if o then o:Destroy()end

-- CONFIG

local SPEED,GEAR=5,2.5

local WW,WH,MW,MH=420,150,800,440

local HW,HH,CY=320,88,44

local FONT,FS=Enum.Font.GothamBlack,44

local PW,PH,PS=45,35,40

local GP,GPS,RPAD=4,1,2

local PXO,PYO,TXO,TYO,LXO,LYO=0,0,0,0,0,0

local ROT,OPEN,HOLD=-2,.40,.52

local TDELAY=.12

local WIPE,WA=62,-5

local LOAD,TURNS=.6,2

local BLEN,BTH,BPX,BPY=30,4.5,10,8

local SHW,SHA=36,.9
local TOPH,SW=58,174

local BG,BD,W=Color3.fromRGB(17,17,20),Color3.fromRGB(48,48,55),Color3.fromRGB(249,249,250)

local function D(t)return t*5/math.max(SPEED,.01)end

local function G(t)return D(t)*5/math.max(GEAR,.01)end

local function N(c,p)local x=Instance.new(c)for k,v in pairs(p)do x[k]=v end return x end

local function Q(x,t,p,s,d)local a=T:Create(x,TweenInfo.new(t,s or Enum.EasingStyle.Quint,d or Enum.EasingDirection.Out),p)a:Play()return a end

local function R(x,r)N("UICorner",{Parent=x,CornerRadius=UDim.new(0,r)})end

local function mkP()

    local w,h=128,96 local im=A:CreateEditableImage({Size=Vector2.new(w,h)})local b=buffer.create(w*h*4)

    local O={{2,2},{88,2},{98,3},{108,7},{117,11},{123,19},{126,28},{125,36},{121,43},{115,49},{108,53},{99,55},{50,55},{41,78},{19,94},{26,55},{35,21},{20,21}}

    local H={{52,22},{92,22},{98,24},{103,27},{104,32},{102,37},{98,40},{92,42},{47,42}}

    local S={{.25,.25},{.75,.25},{.25,.75},{.75,.75}}

    local function poly(x,y,p)local z=false local j=#p for i=1,#p do local a,b=p[i],p[j]if((a[2]>y)~=(b[2]>y))and x<(b[1]-a[1])*(y-a[2])/((b[2]-a[2])+.0001)+a[1]then z=not z end j=i end return z end

    for y=0,h-1 do for x=0,w-1 do

        local n=0

        for _,s in ipairs(S)do if poly(x+s[1],y+s[2],O)and not poly(x+s[1],y+s[2],H)then n=n+1 end end

        local i=(y*w+x)*4

        buffer.writeu8(b,i,249)buffer.writeu8(b,i+1,249)buffer.writeu8(b,i+2,250)buffer.writeu8(b,i+3,math.floor(n/4*255))

    end end

    im:WritePixelsBuffer(Vector2.zero,Vector2.new(w,h),b)return im

end

local function mkPlus()

    local w,h,c=96,96,48 local im=A:CreateEditableImage({Size=Vector2.new(w,h)})local b=buffer.create(w*h*4)

    local pts={{-.82,-.05,.8,Color3.fromRGB(245,55,155)},{-.55,.58,.72,Color3.fromRGB(125,60,235)},{-.3,-.74,.68,Color3.fromRGB(255,105,32)},{.14,-.8,.68,Color3.fromRGB(255,225,28)},{.68,-.34,.68,Color3.fromRGB(140,255,45)},{.82,.08,.72,Color3.fromRGB(35,235,95)},{.48,.62,.72,Color3.fromRGB(15,220,220)},{0,.82,.72,Color3.fromRGB(25,115,250)}}

    local function g(x,y,a,b,r)local dx,dy=x-a,y-b return math.exp(-((dx*dx+dy*dy)/(r*r))*2)end

    local function rb(x,y,sx,sy,r)local qx,qy=math.abs(x)-sx+r,math.abs(y)-sy+r local ox,oy=math.max(qx,0),math.max(qy,0)return math.sqrt(ox*ox+oy*oy)+math.min(math.max(qx,qy),0)-r end

    for y=0,h-1 do for x=0,w-1 do

        local dx,dy=x-c,y-c

        local al=math.clamp(-math.min(rb(dx,dy,39,13,10),rb(dx,dy,13,39,10))+1,0,1)*255

        local nx,ny=dx/39,dy/39 local r,gg,bl,t=0,0,0,0

        for _,p in ipairs(pts)do local q=g(nx,ny,p[1],p[2],p[3])r=r+p[4].R*q gg=gg+p[4].G*q bl=bl+p[4].B*q t=t+q end

        r,gg,bl=r/t,gg/t,bl/t

        local l=g(nx,ny,-.1,-.15,.65)*.07

        r=r+(1-r)*l gg=gg+(1-gg)*l bl=bl+(1-bl)*l

        local i=(y*w+x)*4

        buffer.writeu8(b,i,math.floor(r*255))buffer.writeu8(b,i+1,math.floor(gg*255))buffer.writeu8(b,i+2,math.floor(bl*255))buffer.writeu8(b,i+3,math.floor(al))

    end end

    im:WritePixelsBuffer(Vector2.zero,Vector2.new(w,h),b)return im

end

local PI,LI

local okA,errA=pcall(function()PI=mkP()end)

if not okA then warn("ESP mkP falhou: "..tostring(errA)) end

local okB,errB=pcall(function()LI=mkPlus()end)

if not okB then warn("ESP mkPlus falhou: "..tostring(errB)) end


-- KEY SYSTEM (Practice Discord Auth Worker)
local HS=game:GetService("HttpService")
local KEY_API="https://practice-discord-auth.lexlutorddnet.workers.dev/verify-key"
local KEY_DIR,KEY_FILE,DEV_FILE,HW_FILE="PracticePlus","PracticePlus/key.txt","PracticePlus/device.txt","PracticePlus/hardware.txt"
local CLIENT_NAME,CLIENT_VERSION="Practice Client","1.0.0"
local REQ=request or http_request or (syn and syn.request)
local LIC={authorized=false,key="",tier="",plan="",expires="",discord_id="",discord_name="",username="",avatar_url="",message=""}
local function trim(s)return tostring(s or ""):gsub("^%s+",""):gsub("%s+$","")end
local function ensureDir()if makefolder then pcall(function()if not isfolder or not isfolder(KEY_DIR)then makefolder(KEY_DIR)end end)end end
local function fread(p)if not(readfile and isfile)then return nil end local ok,v=pcall(function()return isfile(p)and readfile(p)or nil end)return ok and v or nil end
local function fwrite(p,v)if not writefile then return end ensureDir()pcall(function()writefile(p,tostring(v))end)end
local function fdel(p)if delfile and isfile then pcall(function()if isfile(p)then delfile(p)end end)end end
local function uuidok(s)s=trim(s):lower()return #s==36 and s:sub(9,9)=="-"and s:sub(14,14)=="-"and s:sub(19,19)=="-"and s:sub(24,24)=="-"and s:gsub("-",""):match("^[0-9a-f]+$")~=nil end
local function hex64(s)s=trim(s):lower()return #s==64 and s:match("^[0-9a-f]+$")~=nil end
local function h32(s,seed)local h=seed for i=1,#s do h=(h*33+s:byte(i))%4294967296 h=bit32.bxor(h,bit32.rshift(h,13))end return string.format("%08x",h)end
local function hash64(s)local o=""for i=1,8 do o=o..h32(s.."|"..i,(5381+i*2654435761)%4294967296)end return o end
local function uuidFromHash(h)return h:sub(1,8).."-"..h:sub(9,12).."-"..h:sub(13,16).."-"..h:sub(17,20).."-"..h:sub(21,32)end
local function rawDeviceSeed()
    local r=""
    if type(gethwid)=="function"then local ok,v=pcall(gethwid)if ok and v then r=trim(v)end end
    if r==""then pcall(function()r=trim(game:GetService("RbxAnalyticsService"):GetClientId())end)end
    if r==""then r=trim(fread(KEY_DIR.."/seed.txt"))end
    if r==""then r=HS:GenerateGUID(false):lower()fwrite(KEY_DIR.."/seed.txt",r)end
    return r
end
local function deviceIdentity()
    local d=trim(fread(DEV_FILE)):lower()local h=trim(fread(HW_FILE)):lower()
    if uuidok(d)and hex64(h)then return d,h end
    local raw=rawDeviceSeed()local base=hash64("Practice+|"..raw)
    d=uuidok(raw)and raw:lower()or uuidFromHash(hash64("device|"..raw))
    h=hash64("hardware|"..raw.."|"..d.."|"..base)
    fwrite(DEV_FILE,d)fwrite(HW_FILE,h)return d,h
end
local DEVICE_UUID,HARDWARE_HASH=deviceIdentity()
local function executorName()if type(identifyexecutor)=="function"then local ok,a,b=pcall(identifyexecutor)if ok then return trim(a)..(b and(" "..trim(b))or"")end end return "unknown"end
local function decode(body)local ok,d=pcall(function()return HS:JSONDecode(body or "")end)return ok and type(d)=="table"and d or{}end
local function applyLicense(k,d)
    local r=type(d.record)=="table"and d.record or{}
    LIC.authorized=d.authorized==true and d.ok==true;LIC.key=k;LIC.tier=trim(d.tier or r.tier);LIC.plan=trim(r.plan);LIC.expires=trim(r.expires_at);LIC.discord_id=trim(d.discord_id or r.discord_id);LIC.discord_name=trim(d.discord_name or r.discord_name);LIC.username=trim(d.username or r.username);LIC.avatar_url=trim(d.avatar_url or r.avatar_url);LIC.message=trim(d.message)
    return LIC.authorized
end
local ERRORS={invalid_key="Key inválida.",blocked_key="Esta key está bloqueada.",expired_key="Esta key expirou.",device_mismatch="Esta key já está vinculada a outro dispositivo.",hardware_mismatch="O hardware desta key não corresponde a este PC.",hardware_fingerprint_weak="Fingerprint de hardware insuficiente.",client_identity_required="Identidade do cliente recusada pelo servidor.",client_version_not_allowed="Esta versão do Practice+ não é permitida.",client_build_not_allowed="Esta build do Practice+ não é permitida.",rate_limited="Muitas tentativas. Aguarde um pouco.",server_error="Erro interno no servidor de keys.",device_required="Não foi possível gerar o Device ID.",hardware_required="Não foi possível gerar o Hardware ID."}
local function verifyKey(k)
    k=trim(k)if k==""then return false,"Digite uma key.","invalid_key"end
    if not REQ then return false,"Seu executor não oferece request/http_request.","network"end
    local payload={key=k,device_uuid=DEVICE_UUID,hardware_hash=HARDWARE_HASH,hardware_score=32,client_name=CLIENT_NAME,client_version=CLIENT_VERSION,roblox_user_id=tostring(P.LocalPlayer.UserId),place_id=tostring(game.PlaceId),executor=executorName()}
    local ok,res=pcall(function()return REQ({Url=KEY_API,Method="POST",Headers={["Content-Type"]="application/json",Accept="application/json"},Body=HS:JSONEncode(payload)})end)
    if not ok then return false,"Falha ao conectar ao servidor de keys.","network"end
    local code=tonumber(res.StatusCode or res.Status or 0)or 0 local d=decode(res.Body or res.body)
    if code==429 then return false,ERRORS.rate_limited,"rate_limited"end
    if code>=500 then return false,ERRORS.server_error,"network"end
    if applyLicense(k,d)then fwrite(KEY_FILE,k)return true,"Autorizado.","authorized"end
    local m=trim(d.message)if m==""then m="invalid_key"end return false,ERRORS[m]or("Acesso negado: "..m),m
end
local function savedKey()return trim(fread(KEY_FILE))end
local function keyGate(prefill,msg)
    local g=N("ScreenGui",{Name="PracticeKeyGate",Parent=pg,IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=1000000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    local shade=N("Frame",{Parent=g,Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(5,5,7),BackgroundTransparency=.18,BorderSizePixel=0})
    local box=N("CanvasGroup",{Parent=g,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(430,254),BackgroundColor3=Color3.fromRGB(16,16,20),BorderSizePixel=0,GroupTransparency=1})R(box,12)N("UIStroke",{Parent=box,Color=Color3.fromRGB(66,67,79),Transparency=.28,Thickness=1})
    local bs=N("UIScale",{Parent=box,Scale=.95})
    local lg=N("Frame",{Parent=box,Position=UDim2.fromOffset(22,18),Size=UDim2.fromOffset(82,38),BackgroundTransparency=1})
    local lp=N("ImageLabel",{Parent=lg,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(17,19),Size=UDim2.fromOffset(31,24),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,Rotation=ROT,ZIndex=4})if PI then pcall(function()lp.ImageContent=Content.fromObject(PI)end)end
    local lplus=N("ImageLabel",{Parent=lg,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(49,19),Size=UDim2.fromOffset(25,25),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=5})if LI then pcall(function()lplus.ImageContent=Content.fromObject(LI)end)end
    N("TextLabel",{Parent=box,Position=UDim2.fromOffset(92,18),Size=UDim2.new(1,-115,0,23),BackgroundTransparency=1,Text="Practice+",Font=Enum.Font.GothamBold,TextSize=17,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left})
    N("TextLabel",{Parent=box,Position=UDim2.fromOffset(92,40),Size=UDim2.new(1,-115,0,14),BackgroundTransparency=1,Text="LICENSE ACCESS",Font=Enum.Font.GothamBold,TextSize=8,TextColor3=Color3.fromRGB(91,93,106),TextXAlignment=Enum.TextXAlignment.Left})
    N("Frame",{Parent=box,Position=UDim2.fromOffset(22,69),Size=UDim2.new(1,-44,0,1),BackgroundColor3=Color3.fromRGB(61,62,73),BackgroundTransparency=.45,BorderSizePixel=0})
    N("TextLabel",{Parent=box,Position=UDim2.fromOffset(23,86),Size=UDim2.new(1,-46,0,18),BackgroundTransparency=1,Text="Insira sua key do Practice+",Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Color3.fromRGB(224,225,232),TextXAlignment=Enum.TextXAlignment.Left})
    local input=N("TextBox",{Parent=box,Position=UDim2.fromOffset(23,113),Size=UDim2.new(1,-46,0,42),BackgroundColor3=Color3.fromRGB(23,23,29),BorderSizePixel=0,Text=prefill or"",PlaceholderText="Practice-...",PlaceholderColor3=Color3.fromRGB(76,78,91),Font=Enum.Font.Code,TextSize=11,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false})R(input,8)N("UIPadding",{Parent=input,PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})local ist=N("UIStroke",{Parent=input,Color=Color3.fromRGB(61,62,74),Transparency=.42,Thickness=1})
    local status=N("TextLabel",{Parent=box,Position=UDim2.fromOffset(24,165),Size=UDim2.new(1,-48,0,18),BackgroundTransparency=1,Text=msg or("Dispositivo: "..DEVICE_UUID:sub(1,8).."..."),Font=Enum.Font.Gotham,TextSize=9,TextColor3=Color3.fromRGB(104,106,118),TextXAlignment=Enum.TextXAlignment.Left})
    local enter=N("TextButton",{Parent=box,Position=UDim2.fromOffset(23,194),Size=UDim2.new(1,-46,0,39),BackgroundColor3=Color3.fromRGB(99,130,246),BorderSizePixel=0,Text="Authenticate",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=W,AutoButtonColor=false})R(enter,8)
    local unlocked,busy=false,false
    local function setStatus(t,bad)status.Text=t status.TextColor3=bad and Color3.fromRGB(229,103,110)or Color3.fromRGB(104,210,151)end
    local function go()if busy then return end local k=trim(input.Text)if k==""then setStatus("Digite uma key.",true)return end busy=true enter.Text="Verifying..."status.TextColor3=Color3.fromRGB(126,128,142)status.Text="Validando licença..."task.spawn(function()local ok,text,kind=verifyKey(k)if ok then setStatus("Acesso autorizado.",false)enter.Text="Authorized"Q(lplus,D(.30),{Rotation=360},Enum.EasingStyle.Quint)task.wait(D(.18))Q(box,D(.14),{GroupTransparency=1},Enum.EasingStyle.Quad)Q(bs,D(.14),{Scale=.96},Enum.EasingStyle.Quad)task.wait(D(.15))unlocked=true g:Destroy()else setStatus(text,true)enter.Text="Authenticate"Q(ist,D(.1),{Color=Color3.fromRGB(170,65,73),Transparency=.1},Enum.EasingStyle.Quad)task.delay(D(.35),function()if ist.Parent then Q(ist,D(.15),{Color=Color3.fromRGB(61,62,74),Transparency=.42},Enum.EasingStyle.Quad)end end)busy=false end end)end
    enter.MouseButton1Click:Connect(go)input.FocusLost:Connect(function(ep)if ep then go()end end)
    Q(box,D(.18),{GroupTransparency=0},Enum.EasingStyle.Quad)Q(bs,D(.25),{Scale=1},Enum.EasingStyle.Back)
    repeat task.wait()until unlocked or not g.Parent return unlocked
end
local sk=savedKey()local access,why,kind=false,nil,nil
if sk~=""then access,why,kind=verifyKey(sk)if not access and(kind=="invalid_key"or kind=="blocked_key"or kind=="expired_key")then fdel(KEY_FILE)sk=""end end
if not access then if not keyGate(sk,why)then return end end

local gui=N("ScreenGui",{Name="PracticeIntro",Parent=pg,IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=999999})
task.spawn(function()while gui.Parent do task.wait(120)if not gui.Parent then break end local ok,msg,kind=verifyKey(LIC.key)if not ok and kind~="network"and kind~="rate_limited"then warn("[Practice+] licença recusada: "..tostring(msg))fdel(KEY_FILE)if gui.Parent then gui:Destroy()end break end end end)


local win=N("CanvasGroup",{Parent=gui,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(WW,WH),BackgroundColor3=BG,BorderSizePixel=0,GroupTransparency=1})

R(win,10)N("UIStroke",{Parent=win,Color=BD,Transparency=.4,Thickness=1})

local sc=N("UIScale",{Parent=win,Scale=.97})

local logo=N("CanvasGroup",{Parent=win,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(HW,HH),BackgroundTransparency=1})

local TW=X:GetTextSize("ractice",FS,FONT,Vector2.new(1000,100)).X

local ST=(HW-(PW+GP+RPAD+TW+GPS+PS))/2

local PX,TX=ST+PW/2+PXO,ST+PW+GP+RPAD+TXO

local LX=TX+TW+GPS+PS/2+LXO

local IP,IL=UDim2.fromOffset(HW/2-18,CY),UDim2.fromOffset(HW/2+24,CY)

local rev=N("Frame",{Parent=logo,Position=UDim2.fromOffset(TX,4+TYO),Size=UDim2.fromOffset(0,80),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2})

N("TextLabel",{Parent=rev,Size=UDim2.fromOffset(TW+6,80),BackgroundTransparency=1,Text="ractice",Font=FONT,TextSize=FS,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,ZIndex=2})

local wipe=N("Frame",{Parent=logo,AnchorPoint=Vector2.new(0,.5),Position=UDim2.fromOffset(TX-10,CY),Size=UDim2.fromOffset(WIPE,88),BackgroundColor3=BG,BorderSizePixel=0,Rotation=WA,ZIndex=4})

local p=N("ImageLabel",{Parent=logo,AnchorPoint=Vector2.new(.5,.5),Position=IP,Size=UDim2.fromOffset(PW,PH),BackgroundTransparency=1,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,Rotation=ROT,ZIndex=5})

if PI then pcall(function()p.ImageContent=Content.fromObject(PI)end) end

local ph=N("Frame",{Parent=logo,AnchorPoint=Vector2.new(.5,.5),Position=IL,Size=UDim2.fromOffset(PS,PS),BackgroundTransparency=1,ZIndex=5})

local plus=N("ImageLabel",{Parent=ph,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=5})

if LI then pcall(function()plus.ImageContent=Content.fromObject(LI)end) end

-- SHINE

local fx=N("Frame",{Parent=logo,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=7})

local shine=N("Frame",{Parent=fx,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(-60,CY),Size=UDim2.fromOffset(SHW,120),BackgroundColor3=W,BackgroundTransparency=1,BorderSizePixel=0,Rotation=-18,ZIndex=7})R(shine,99)

-- BORDAS

local corners={}

local function C(ax,ay,h)

    local sx,sy=h and 0 or BTH,h and BTH or 0

    local tx,ty=h and BLEN or BTH,h and BTH or BLEN

    local f=N("Frame",{Parent=win,AnchorPoint=Vector2.new(ax,ay),Position=UDim2.new(ax,ax==1 and-BPX or BPX,ay,ay==1 and-BPY or BPY),Size=UDim2.fromOffset(sx,sy),BackgroundColor3=W,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=6})

    R(f,99)corners[#corners+1]={f,UDim2.fromOffset(sx,sy),UDim2.fromOffset(tx,ty)}

end

C(0,0,true)C(0,0,false)C(1,0,true)C(1,0,false)

C(0,1,true)C(0,1,false)C(1,1,true)C(1,1,false)

-- MENU PREMIUM
local UI=game:GetService("UserInputService")
local ACCENT=Color3.fromRGB(99,130,246)
local accentObjects,controlRefreshers={},{}
local function bindAccent(o,prop)
    prop=prop or "BackgroundColor3"
    o[prop]=ACCENT
    accentObjects[#accentObjects+1]={o,prop}
    return o
end
local function softStroke(x,col,tr,th)
    return N("UIStroke",{Parent=x,Color=col or BD,Transparency=tr or .45,Thickness=th or 1})
end
local function grad(x,a,b,rot)
    return N("UIGradient",{Parent=x,Rotation=rot or 90,Color=ColorSequence.new(a,b)})
end

local menu=N("CanvasGroup",{Parent=win,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,GroupTransparency=1,Visible=false})

-- HEADER
local top=N("Frame",{Parent=menu,Size=UDim2.new(1,0,0,TOPH),BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0,ZIndex=20})
R(top,10)
grad(top,Color3.fromRGB(27,27,32),Color3.fromRGB(18,18,22),0)
N("Frame",{Parent=top,Position=UDim2.new(0,0,1,-10),Size=UDim2.new(1,0,0,10),BackgroundColor3=Color3.fromRGB(18,18,22),BorderSizePixel=0,ZIndex=20})
local topLine=N("Frame",{Parent=top,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(73,74,86),BackgroundTransparency=.50,BorderSizePixel=0,ZIndex=24})
N("UIGradient",{Parent=topLine,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.12,.28),NumberSequenceKeypoint.new(.45,.72),NumberSequenceKeypoint.new(1,1)})})

-- titulo P+; hover abre para Practice+ igual a intro
local brand=N("TextButton",{Parent=top,Position=UDim2.fromOffset(16,7),Size=UDim2.fromOffset(185,44),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=30})
local BPW,BPH,BPS,BFS=28,22,22,16
local BTW=X:GetTextSize("ractice",BFS,Enum.Font.GothamBold,Vector2.new(300,50)).X
local brandP=N("ImageLabel",{Parent=brand,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(24,22),Size=UDim2.fromOffset(BPW,BPH),BackgroundTransparency=1,ImageTransparency=0,ScaleType=Enum.ScaleType.Fit,Rotation=ROT,ZIndex=32})
if PI then pcall(function()brandP.ImageContent=Content.fromObject(PI)end)end
local brandRev=N("Frame",{Parent=brand,Position=UDim2.fromOffset(37,4),Size=UDim2.fromOffset(0,36),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=31})
N("TextLabel",{Parent=brandRev,Size=UDim2.fromOffset(BTW+4,36),BackgroundTransparency=1,Text="ractice",Font=Enum.Font.GothamBold,TextSize=BFS,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,ZIndex=31})
local brandPH=N("Frame",{Parent=brand,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(53,22),Size=UDim2.fromOffset(BPS,BPS),BackgroundTransparency=1,ZIndex=33})
local brandPlus=N("ImageLabel",{Parent=brandPH,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ImageTransparency=0,ScaleType=Enum.ScaleType.Fit,ZIndex=33})
if LI then pcall(function()brandPlus.ImageContent=Content.fromObject(LI)end)end
local brandToken=0
local function brandOpen(open)
    brandToken+=1
    local token=brandToken
    if open then
        Q(brandP,D(.22),{Position=UDim2.fromOffset(21,22),Rotation=0},Enum.EasingStyle.Quint)
        Q(brandPH,D(.28),{Position=UDim2.fromOffset(42+BTW,22)},Enum.EasingStyle.Quint)
        Q(brandPlus,D(.28),{Rotation=360},Enum.EasingStyle.Quint)
        task.delay(D(.035),function()if token==brandToken then Q(brandRev,D(.22),{Size=UDim2.fromOffset(BTW+4,36)},Enum.EasingStyle.Quart)end end)
    else
        Q(brandRev,D(.16),{Size=UDim2.fromOffset(0,36)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        Q(brandP,D(.24),{Position=UDim2.fromOffset(24,22),Rotation=ROT},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
        Q(brandPH,D(.24),{Position=UDim2.fromOffset(53,22)},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
        Q(brandPlus,D(.24),{Rotation=0},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
    end
end
brand.MouseEnter:Connect(function()brandOpen(true)end)
brand.MouseLeave:Connect(function()brandOpen(false)end)

-- descricao separada do logo, deixando a marca limpa
N("TextLabel",{Parent=top,Position=UDim2.fromOffset(205,19),Size=UDim2.fromOffset(170,20),BackgroundTransparency=1,Text="CONTROL CENTER",Font=Enum.Font.GothamMedium,TextSize=9,TextColor3=Color3.fromRGB(92,94,107),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=23})
local online=N("Frame",{Parent=top,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-103,.5,0),Size=UDim2.fromOffset(80,26),BackgroundColor3=Color3.fromRGB(24,31,29),BorderSizePixel=0,ZIndex=23})
R(online,8)softStroke(online,Color3.fromRGB(58,91,77),.6,1)
N("Frame",{Parent=online,AnchorPoint=Vector2.new(0,.5),Position=UDim2.fromOffset(10,13),Size=UDim2.fromOffset(6,6),BackgroundColor3=Color3.fromRGB(81,209,142),BorderSizePixel=0,ZIndex=24})
local od=online:FindFirstChildOfClass("Frame") if od then R(od,99)end
N("TextLabel",{Parent=online,Position=UDim2.fromOffset(22,0),Size=UDim2.new(1,-26,1,0),BackgroundTransparency=1,Text="READY",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.fromRGB(137,218,174),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=24})

local function topButton(x,text,col)
    local b=N("TextButton",{Parent=top,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,x,.5,0),Size=UDim2.fromOffset(31,31),BackgroundColor3=Color3.fromRGB(31,31,37),BackgroundTransparency=.10,BorderSizePixel=0,Text=text,Font=Enum.Font.GothamBold,TextSize=15,TextColor3=col or Color3.fromRGB(178,179,191),AutoButtonColor=false,ZIndex=32})
    R(b,8)softStroke(b,Color3.fromRGB(63,64,75),.46,1)
    return b
end
local close=topButton(-15,"×",Color3.fromRGB(212,110,114))
local minBtn=topButton(-53,"—",Color3.fromRGB(195,196,206))
minBtn.MouseEnter:Connect(function()Q(minBtn,D(.10),{BackgroundColor3=Color3.fromRGB(45,45,53),TextColor3=W},Enum.EasingStyle.Quad)end)
minBtn.MouseLeave:Connect(function()Q(minBtn,D(.10),{BackgroundColor3=Color3.fromRGB(31,31,37),TextColor3=Color3.fromRGB(195,196,206)},Enum.EasingStyle.Quad)end)
close.MouseEnter:Connect(function()Q(close,D(.10),{BackgroundColor3=Color3.fromRGB(74,34,39),TextColor3=Color3.fromRGB(255,192,195)},Enum.EasingStyle.Quad)end)
close.MouseLeave:Connect(function()Q(close,D(.10),{BackgroundColor3=Color3.fromRGB(31,31,37),TextColor3=Color3.fromRGB(212,110,114)},Enum.EasingStyle.Quad)end)
close.MouseButton1Click:Connect(function()gui:Destroy()end)

-- area de arraste sem cobrir titulo nem botoes
local dragArea=N("Frame",{Parent=top,Position=UDim2.fromOffset(390,0),Size=UDim2.new(1,-510,1,0),BackgroundTransparency=1,Active=true,ZIndex=25})

-- MINIMIZADO: root transparente; fundo separado nunca cobre o P+
local floatShell=N("Frame",{Parent=gui,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-22,1,-22),Size=UDim2.fromOffset(60,60),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=999999})
local floatScale=N("UIScale",{Parent=floatShell,Scale=.84})
local floatVisual=N("CanvasGroup",{Parent=floatShell,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,GroupTransparency=1,ZIndex=1})
local floatBg=N("Frame",{Parent=floatVisual,Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(19,19,24),BorderSizePixel=0,ZIndex=1})
R(floatBg,30)grad(floatBg,Color3.fromRGB(37,38,47),Color3.fromRGB(16,16,20),45)softStroke(floatBg,Color3.fromRGB(95,97,112),.18,1.35)
local floatInner=N("Frame",{Parent=floatVisual,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(49,49),BackgroundColor3=Color3.fromRGB(13,13,17),BackgroundTransparency=.10,BorderSizePixel=0,ZIndex=2})
R(floatInner,25)softStroke(floatInner,Color3.fromRGB(255,255,255),.92,1)
local icon=N("Frame",{Parent=floatVisual,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(54,34),BackgroundTransparency=1,ZIndex=20})
local floatP=N("ImageLabel",{Parent=icon,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(15,17),Size=UDim2.fromOffset(28,22),BackgroundTransparency=1,ImageTransparency=0,ScaleType=Enum.ScaleType.Fit,Rotation=ROT,ZIndex=21,Visible=true})
if PI then pcall(function()floatP.ImageContent=Content.fromObject(PI)end)end
local floatPlus=N("ImageLabel",{Parent=icon,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(41,17),Size=UDim2.fromOffset(22,22),BackgroundTransparency=1,ImageTransparency=0,ScaleType=Enum.ScaleType.Fit,ZIndex=22,Visible=true})
if LI then pcall(function()floatPlus.ImageContent=Content.fromObject(LI)end)end
local floatHit=N("TextButton",{Parent=floatShell,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,Active=true,ZIndex=100})

local function makeDrag(handle,target,onMove)
    local dragging=false
    local startInput,startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true startInput=i.Position startPos=target.Position
            if onMove then onMove(false)end
        end
    end)
    UI.InputChanged:Connect(function(i)
        if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
            local d=i.Position-startInput
            if onMove and d.Magnitude>5 then onMove(true)end
            target.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UI.InputEnded:Connect(function(i)
        if dragging and(i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch)then dragging=false end
    end)
end
makeDrag(dragArea,win)
local floatMoved=false
makeDrag(floatHit,floatShell,function(moved)floatMoved=moved end)

local function minimize()
    brandOpen(false)
    Q(win,D(.14),{GroupTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    Q(sc,D(.14),{Scale=.985},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    task.wait(D(.14))
    win.Visible=false
    floatShell.Visible=true
    floatVisual.GroupTransparency=1 floatScale.Scale=.84
    -- explicito para impedir o bug de o fundo cobrir os assets
    floatP.Visible=true floatPlus.Visible=true floatP.ImageTransparency=0 floatPlus.ImageTransparency=0
    Q(floatVisual,D(.15),{GroupTransparency=0},Enum.EasingStyle.Quad)
    Q(floatScale,D(.20),{Scale=1},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
end
local function restore()
    Q(floatScale,D(.10),{Scale=.90},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    Q(floatVisual,D(.10),{GroupTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    task.wait(D(.10))
    floatShell.Visible=false
    win.Visible=true win.GroupTransparency=1 sc.Scale=.985
    Q(win,D(.16),{GroupTransparency=0},Enum.EasingStyle.Quad)
    Q(sc,D(.20),{Scale=1},Enum.EasingStyle.Quint)
end
minBtn.MouseButton1Click:Connect(minimize)
floatHit.Activated:Connect(function()if floatMoved then floatMoved=false return end restore()end)
floatHit.MouseEnter:Connect(function()Q(floatScale,D(.11),{Scale=1.07},Enum.EasingStyle.Quad)Q(floatPlus,D(.18),{Rotation=90},Enum.EasingStyle.Quint)end)
floatHit.MouseLeave:Connect(function()if floatShell.Visible then Q(floatScale,D(.11),{Scale=1},Enum.EasingStyle.Quad)Q(floatPlus,D(.18),{Rotation=0},Enum.EasingStyle.Quint)end end)

-- SIDEBAR mais clara
local side=N("Frame",{Parent=menu,Position=UDim2.fromOffset(0,TOPH),Size=UDim2.new(0,SW,1,-TOPH),BackgroundColor3=Color3.fromRGB(13,13,16),BorderSizePixel=0,ZIndex=5})
grad(side,Color3.fromRGB(17,17,21),Color3.fromRGB(11,11,14),90)
N("Frame",{Parent=side,AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=Color3.fromRGB(58,59,69),BackgroundTransparency=.45,BorderSizePixel=0})
N("TextLabel",{Parent=side,Position=UDim2.fromOffset(16,15),Size=UDim2.fromOffset(135,14),BackgroundTransparency=1,Text="WORKSPACE",Font=Enum.Font.GothamBold,TextSize=8,TextColor3=Color3.fromRGB(82,84,96),TextXAlignment=Enum.TextXAlignment.Left})
local sideStatus=N("Frame",{Parent=side,AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-14),Size=UDim2.new(1,-24,0,42),BackgroundColor3=Color3.fromRGB(18,18,22),BorderSizePixel=0})
R(sideStatus,9)softStroke(sideStatus,Color3.fromRGB(54,55,65),.58,1)
local sd=bindAccent(N("Frame",{Parent=sideStatus,AnchorPoint=Vector2.new(0,.5),Position=UDim2.fromOffset(12,21),Size=UDim2.fromOffset(7,7),BackgroundColor3=ACCENT,BorderSizePixel=0}))R(sd,99)
N("TextLabel",{Parent=sideStatus,Position=UDim2.fromOffset(29,7),Size=UDim2.new(1,-36,0,14),BackgroundTransparency=1,Text="Practice+",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.fromRGB(203,204,213),TextXAlignment=Enum.TextXAlignment.Left})
N("TextLabel",{Parent=sideStatus,Position=UDim2.fromOffset(29,21),Size=UDim2.new(1,-36,0,12),BackgroundTransparency=1,Text="Local session",Font=Enum.Font.Gotham,TextSize=8,TextColor3=Color3.fromRGB(85,87,99),TextXAlignment=Enum.TextXAlignment.Left})

-- fundo de conteudo separado da sidebar
local contentBG=N("Frame",{Parent=menu,Position=UDim2.fromOffset(SW,TOPH),Size=UDim2.new(1,-SW,1,-TOPH),BackgroundColor3=Color3.fromRGB(16,16,20),BorderSizePixel=0,ZIndex=0})
grad(contentBG,Color3.fromRGB(18,18,22),Color3.fromRGB(14,14,18),90)

-- #####################################################################

-- ABA PLAYER (controles: ESP / Aimbot / Fly / Noclip)

-- #####################################################################

-- Estado das configuracoes

local SET = {

    espEnabled        = false,

    espTeamColor      = true,

    espNames          = false,

    espTracers        = false,

    espBoxes          = false,

    espShowSelf       = false,

    espColor          = Color3.fromRGB(235,70,70),

    aimbotEnabled     = false,

    aimFOV            = 150,

    aimSmooth         = 4,

    flyEnabled        = false,

    flySpeed          = 50,

    noclipEnabled     = false,

    walkSpeed         = 16,

    jumpPower         = 50,

    noFallDamage      = false,

    godMode           = false,

    hitboxExpand      = false,

    hitboxSize        = 1.5,

    antiAfk           = false,

    zoomFOV           = 0,

    theme             = 1,

}

local ESP_FOLDERS = { "Zombie", "Zombies", "Creeper", "Enemies", "Mobs" }

-- Containers de conteudo: um por aba (Home / Player / Visuals / Settings)

local ct=N("Frame",{Parent=menu,Position=UDim2.fromOffset(SW,TOPH),Size=UDim2.new(1,-SW,1,-TOPH),BackgroundTransparency=1,ZIndex=2})

-- Construtor de card (estilo escuro do menu)

local function card(parent,y,h)
    local f=N("Frame",{Parent=parent,Position=UDim2.fromOffset(18,y),Size=UDim2.new(1,-36,0,h),BackgroundColor3=Color3.fromRGB(21,21,26),BorderSizePixel=0})
    R(f,10)
    grad(f,Color3.fromRGB(26,26,32),Color3.fromRGB(19,19,24),90)
    softStroke(f,Color3.fromRGB(58,59,69),.48,1)
    return f
end

-- Toggle estilo switch (ON/OFF)

local function mkToggle(parent,y,title,sub,onChange,def)
    local c=card(parent,y,58)
    local titleL=N("TextLabel",{Parent=c,Position=UDim2.fromOffset(15,9),Size=UDim2.new(1,-92,0,19),BackgroundTransparency=1,Text=title,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Color3.fromRGB(229,229,235),TextXAlignment=Enum.TextXAlignment.Left})
    N("TextLabel",{Parent=c,Position=UDim2.fromOffset(15,30),Size=UDim2.new(1,-92,0,15),BackgroundTransparency=1,Text=sub or "",Font=Enum.Font.Gotham,TextSize=10,TextColor3=Color3.fromRGB(102,104,116),TextXAlignment=Enum.TextXAlignment.Left})
    local state=def or false
    local btn=N("TextButton",{Parent=c,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-15,.5,0),Size=UDim2.fromOffset(46,25),BackgroundColor3=Color3.fromRGB(36,36,43),BorderSizePixel=0,Text="",AutoButtonColor=false})
    R(btn,13)softStroke(btn,Color3.fromRGB(66,67,78),.54,1)
    local knob=N("Frame",{Parent=btn,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(12.5,12.5),Size=UDim2.fromOffset(18,18),BackgroundColor3=Color3.fromRGB(184,185,195),BorderSizePixel=0})R(knob,9)
    local function refresh(instant)
        local pos=state and UDim2.fromOffset(33.5,12.5)or UDim2.fromOffset(12.5,12.5)
        local bg=state and ACCENT or Color3.fromRGB(36,36,43)
        local kc=state and W or Color3.fromRGB(184,185,195)
        if instant then btn.BackgroundColor3=bg knob.Position=pos knob.BackgroundColor3=kc
        else Q(btn,D(.14),{BackgroundColor3=bg},Enum.EasingStyle.Quad)Q(knob,D(.17),{Position=pos,BackgroundColor3=kc},Enum.EasingStyle.Quint)end
    end
    controlRefreshers[#controlRefreshers+1]=function()refresh(true)end
    refresh(true)
    c.MouseEnter:Connect(function()Q(titleL,D(.10),{TextColor3=W},Enum.EasingStyle.Quad)end)
    c.MouseLeave:Connect(function()Q(titleL,D(.10),{TextColor3=Color3.fromRGB(229,229,235)},Enum.EasingStyle.Quad)end)
    btn.MouseButton1Click:Connect(function()state=not state refresh(false)onChange(state)end)
    return {set=function(v)state=v refresh(false)end,get=function()return state end}
end

-- Slider horizontal

local function mkSlider(parent,y,title,minV,maxV,decimals,suffix,val,onChange)
    local c=card(parent,y,82)
    N("TextLabel",{Parent=c,Position=UDim2.fromOffset(15,10),Size=UDim2.new(1,-112,0,18),BackgroundTransparency=1,Text=title,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Color3.fromRGB(229,229,235),TextXAlignment=Enum.TextXAlignment.Left})
    local pill=N("Frame",{Parent=c,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-15,0,8),Size=UDim2.fromOffset(82,23),BackgroundColor3=Color3.fromRGB(29,29,35),BorderSizePixel=0})
    R(pill,7)softStroke(pill,Color3.fromRGB(58,59,70),.56,1)
    local vl=N("TextLabel",{Parent=pill,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,TextColor3=Color3.fromRGB(217,218,226),Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Center})
    local rail=N("Frame",{Parent=c,Position=UDim2.fromOffset(15,53),Size=UDim2.new(1,-30,0,5),BackgroundColor3=Color3.fromRGB(34,34,41),BorderSizePixel=0})R(rail,3)
    local fill=bindAccent(N("Frame",{Parent=rail,Size=UDim2.new(0,0,1,0),BackgroundColor3=ACCENT,BorderSizePixel=0}))R(fill,3)
    local thumb=N("TextButton",{Parent=rail,AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(15,15),BackgroundColor3=W,Text="",BorderSizePixel=0,AutoButtonColor=false})R(thumb,8)
    bindAccent(N("UIStroke",{Parent=thumb,Color=ACCENT,Thickness=2,Transparency=.18}),"Color")
    local dragging=false
    local function update(frac,silent)
        frac=math.clamp(frac,0,1)
        local value=minV+frac*(maxV-minV)
        local step=10^decimals value=math.round(value*step)/step
        vl.Text=tostring(value)..(suffix and suffix~="" and " "..suffix or "")
        fill.Size=UDim2.fromScale(frac,1) thumb.Position=UDim2.fromScale(frac,.5)
        if not silent then onChange(value)end
    end
    local function setByValue(v)update((v-minV)/(maxV-minV),true)end
    local function dragTo(pos)update((pos.X-rail.AbsolutePosition.X)/math.max(rail.AbsoluteSize.X,1))end
    local function beginDrag(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true dragTo(input.Position)Q(thumb,D(.08),{Size=UDim2.fromOffset(18,18)},Enum.EasingStyle.Quad)end
    end
    local function endDrag(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false Q(thumb,D(.10),{Size=UDim2.fromOffset(15,15)},Enum.EasingStyle.Quad)end
    end
    thumb.InputBegan:Connect(beginDrag)rail.InputBegan:Connect(beginDrag)
    thumb.InputEnded:Connect(endDrag)rail.InputEnded:Connect(endDrag)
    UI.InputChanged:Connect(function(input)if dragging and(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then dragTo(input.Position)end end)
    UI.InputEnded:Connect(function(input)if dragging then endDrag(input)end end)
    update((val-minV)/(maxV-minV))
    return {set=setByValue,get=function()return minV+(fill.Size.X.Scale)*(maxV-minV)end,frame=c}
end

local UserInputService=game:GetService("UserInputService")

local RunService=game:GetService("RunService")

local player=P.LocalPlayer

-- Aberaca ESP: destaca outros jogadores + inimigos (chams, nomes, caixas)

local espHighlights={}

local espTags={}

local function getTargets()

    local ts={}

    if SET.espShowSelf and player.Character and player.Character.PrimaryPart then

        ts[#ts+1]=player.Character

    end

    for _,pl in ipairs(P:GetPlayers()) do

        if pl~=player and pl.Character and pl.Character.PrimaryPart then ts[#ts+1]=pl.Character end

    end

    for _,fn in ipairs(ESP_FOLDERS) do

        local f=workspace:FindFirstChild(fn)

        if f then for _,child in ipairs(f:GetChildren()) do

            if child:IsA("Model") and child.PrimaryPart then ts[#ts+1]=child end

        end end

    end

    return ts

end

local function isEnemy(char)

    local pl=P:GetPlayerFromCharacter(char)

    if not pl then return true end

    local myT,plT=player.Team,pl.Team

    if myT and plT and not player.Neutral and not pl.Neutral then return myT~=plT end

    return true

end

local function espColorFor(char,base)

    if SET.espTeamColor then

        local pl=P:GetPlayerFromCharacter(char)

        local tm=pl and pl.Team and pl.Team.TeamColor.Color

        if tm then return tm end

    end

    return base

end

local function clearESP()

    for _,hl in pairs(espHighlights) do if hl and hl.Parent then hl:Destroy() end end

    espHighlights={}

    for _,t in pairs(espTags) do

        if t then

            if t.tag then pcall(function() t.tag:Destroy() end) end

            if t.box then pcall(function() t.box:Destroy() end) end

        end

    end

    espTags={}

end

local function refreshESP()

    clearESP()

    if not SET.espEnabled then return end

    local baseColor=SET.espColor

    for _,char in ipairs(getTargets()) do

        if (char==player.Character and SET.espShowSelf) or (char~=player.Character and isEnemy(char)) then

            local color=espColorFor(char,baseColor)

            if not char:FindFirstChildOfClass("Highlight") then

                local hl=Instance.new("Highlight")

                hl.Name="ESP_Highlight"

                hl.FillColor=color

                hl.OutlineColor=Color3.new(0,0,0)

                hl.FillTransparency=.4 hl.OutlineTransparency=.3

                hl.Parent=char

                espHighlights[char]=hl

            end

            local head=char:FindFirstChild("Head") or char.PrimaryPart

            if head and (SET.espNames or SET.espBoxes) then

                local tag={}

                local bg=Instance.new("BillboardGui")

                bg.Name="ESP_Tag"

                bg.AlwaysOnTop=true

                bg.Adornee=head

                bg.Size=UDim2.fromScale(3*head.Size.X,8)

                bg.StudsOffsetWorldSpace=Vector3.new(0,head.Size.Y*1.4,0)

                bg.ClipsDescendants=false

                if SET.espNames then

                    local nm=Instance.new("TextLabel")

                    local nmText=P:GetPlayerFromCharacter(char) and P:GetPlayerFromCharacter(char).Name or "Inimigo"

                    nm.Name="ESP_Name"

                    nm.Size=UDim2.fromScale(1,.5)

                    nm.BackgroundTransparency=1

                    nm.Text=nmText

                    nm.Font=Enum.Font.GothamBold

                    nm.TextSize=14

                    nm.TextColor3=Color3.new(1,1,1)

                    nm.TextStrokeTransparency=.1

                    nm.Parent=bg

                    tag.tag=nm

                end

                if SET.espBoxes then

                    local bx=Instance.new("Frame")

                    bx.Name="ESP_Box"

                    bx.Size=UDim2.new(1,0,2,0)

                    bx.Position=UDim2.new(0,-0.5,0.5,0)

                    bx.BackgroundTransparency=1

                    bx.BorderSizePixel=0

                    bx.Parent=bg

                    local s=N("UIStroke",{Parent=bx,Color=color,Thickness=1.5,Transparency=.2})

                    tag.box=bx

                    tag.stroke=s

                end

                bg.Parent=char

                espTags[char]=tag

            end

        end

    end

end

-- Tracers: linhas da tela ate o alvo

local tracerLines={}

local tracerLabels={}

local DrawingOK=pcall(function() local d=Drawing.new("Line") d:Destroy() return true end)

local DrawingTextOK=pcall(function() local d=Drawing.new("Text") d:Destroy() return true end)

local function clearTracers()

    for _,l in pairs(tracerLines) do if l then pcall(function() l:Destroy() end) end end

    tracerLines={}

    for _,t in pairs(tracerLabels) do if t then pcall(function() t:Destroy() end) end end

    tracerLabels={}

end

RunService.RenderStepped:Connect(function()

    if DrawingOK and SET.espEnabled and SET.espTracers then

        local cam=workspace.CurrentCamera

        if not cam then return end

        local cs,rs=cam.CFrame.Position,cam.ViewportSize

        local idx=0

        for _,char in ipairs(getTargets()) do

            if (char==player.Character and SET.espShowSelf) or (char~=player.Character and isEnemy(char)) then

                local pt=char.PrimaryPart or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")

                if pt then

                    local sp=pt.Position

                    local col=(isEnemy(char) and SET.espColor) or espColorFor(char,SET.espColor)

                    local line=tracerLines[idx]

                    if not line then

                        line=Drawing.new("Line")

                        line.Thickness=1.5

                        line.Transparency=1

                        line.Color=col

                        tracerLines[idx]=line

                    end

                    line.Visible=true

                    line.Color=col

                    local p2=Vector2.new(rs.X/2,rs.Y)

                    local screen,vis=cam:WorldToViewportPoint(sp)

                    line.From=p2

                    line.To=Vector2.new(screen.X,screen.Y)

                    local lbl=tracerLabels[idx]

                    if not lbl and DrawingTextOK then

                        local ok,l2=pcall(function()

                            local d=Drawing.new("Text")

                            d.Size=14

                            d.Center=true

                            d.Outline=true

                            d.OutlineColor=Color3.new(0,0,0)

                            d.Color=col

                            return d

                        end)

                        if ok and l2 then lbl=l2 tracerLabels[idx]=l2 end

                    end

                    if lbl then

                        lbl.Visible=vis

                        lbl.Text=math.floor((sp-cs).Magnitude).." studs"

                        lbl.Position=Vector2.new(screen.X,screen.Y-16)

                        lbl.Color=col

                    end

                    idx=idx+1

                end

            end

        end

        for i=idx,#tracerLines do

            local l=tracerLines[i]

            if l then l.Visible=false end

        end

        for i=idx,#tracerLabels do

            local t=tracerLabels[i]

            if t then t.Visible=false end

        end

    else

        for _,l in pairs(tracerLines) do if l then l.Visible=false end end

    end

end)



-- Fly (via BodyVelocity + gravidade desligada - levita e se move por impulso)

-- Nota: alguns executores/jogos nao tem todos os estados do enum; usa pcall p/ nao quebrar

local HST=Enum.HumanoidStateType

local function hstSafe(name)

    local ok,v=pcall(function() return HST[name] end)

    return ok and v or nil

end

local S_FALL=hstSafe("Falling")

local S_JUMP=hstSafe("Jumping")

local function setState(h,s,en)

    if not s then return end

    pcall(function() h:SetStateEnabled(s,en) end)

end

local flyBody=nil

local function ensureFlyBody(root)

    if flyBody and flyBody.Parent==root then return end

    if flyBody then flyBody:Destroy() end

    flyBody=Instance.new("BodyVelocity")

    flyBody.MaxForce=Vector3.new(9e9,9e9,9e9)

    flyBody.Velocity=Vector3.zero

    flyBody.Parent=root

end

local function toggleFly(on)

    if not on then

        if flyBody then pcall(function() flyBody:Destroy() end) flyBody=nil end

        local pl=player

        local char=pl and pl.Character

        local h=char and char:FindFirstChildOfClass("Humanoid")

        if h then

            setState(h,S_FALL,true)

            setState(h,S_JUMP,true)

        end

    end

end

-- Noclip

local function noclipping(char)

    char=char or player.Character

    if not char then return end

    for _,prt in ipairs(char:GetDescendants()) do

        if prt:IsA("BasePart") then prt.CanCollide=false end

    end

end

-- Loop principal: Fly + Noclip

RunService.Heartbeat:Connect(function()

    local char=player.Character

    local humanoid=char and char:FindFirstChildOfClass("Humanoid")

    local root=char and char:FindFirstChild("HumanoidRootPart")

    if SET.flyEnabled and root and humanoid then

        ensureFlyBody(root)

        setState(humanoid,S_FALL,false)

        setState(humanoid,S_JUMP,false)

        local up=0

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then up=1 end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then up=-1 end

        local cam=workspace.CurrentCamera

        local camDir=cam and cam.CFrame:VectorToWorldSpace(Vector3.new(0,0,-1)) or root.CFrame.LookVector

        local f2d=Vector3.new(camDir.X,0,camDir.Z).Unit

        local mv=Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv=mv+f2d end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv=mv-f2d end

        local hz=root.CFrame.RightVector

        hz=Vector3.new(hz.X,0,hz.Z).Unit

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv=mv-hz end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv=mv+hz end

        flyBody.Velocity=(mv*SET.flySpeed)+Vector3.new(0,up*SET.flySpeed,0)

    elseif flyBody and flyBody.Parent and flyBody.Parent.Parent==char then

        flyBody:Destroy() flyBody=nil

        if humanoid then

            setState(humanoid,S_FALL,true)

            setState(humanoid,S_JUMP,true)

        end

    end

    if SET.noclipEnabled and char and humanoid then noclipping(char) end

end)

-- Movimento (velocidade / pulo) + Infinite Jump + NoFallDamage

RunService.Heartbeat:Connect(function()

    local char=player.Character

    local humanoid=char and char:FindFirstChildOfClass("Humanoid")

    if not humanoid then return end

    pcall(function() humanoid.WalkSpeed=SET.walkSpeed end)

    pcall(function() humanoid.JumpPower=SET.jumpPower end)

    if SET.noFallDamage then

        pcall(function() humanoid:SetStateEnabled(S_FALL,true) end)

    end

    if SET.godMode then

        pcall(function()

            local max=humanoid.MaxHealth

            if humanoid.Health<max then humanoid.Health=max end

        end)

    end

end)

-- Hitbox expandido (HumanoidRootPart maior p/ acertar com mais facilidade)

RunService.Heartbeat:Connect(function()

    if not SET.hitboxExpand then return end

    local char=player.Character

    if not char then return end

    local selfRoot=char:FindFirstChild("HumanoidRootPart")

    if not selfRoot then return end

    for _,t in ipairs(getTargets()) do

        local isSelf=(t==char)

        if SET.espShowSelf or not isSelf then

            local hd=t:FindFirstChild("HumanoidRootPart")

            if hd then

                pcall(function() hd.Size=selfRoot.Size*SET.hitboxSize end)

            end

        end

    end

end)

-- Anti-afk (mantem o personagem ativo - mexe levemente para nao ser kickado)

task.spawn(function()

    local lastMove=os.clock()

    while true do

        task.wait(1)

        if SET.antiAfk then

            pcall(function()

                local r=player.Character and player.Character:FindFirstChild("HumanoidRootPart")

                if r then

                    r.Velocity=Vector3.new(r.Velocity.X,0,r.Velocity.Z)

                    lastMove=os.clock()

                end

            end)

        end

    end

end)

-- Zoom FOV da camera

RunService.RenderStepped:Connect(function()

    if SET.zoomFOV~=0 and SET.zoomFOV~=math.huge then

        local cam=workspace.CurrentCamera

        if cam then

            local targetFOV=math.clamp(70-SET.zoomFOV,40,70)

            pcall(function() cam.FieldOfView=cam.FieldOfView+(targetFOV-cam.FieldOfView)*.2 end)

        end

    end

end)

-- Aimbot (segue a mira: gruda em quem voce apontar e troca ao mirar em outro)

RunService.RenderStepped:Connect(function()

    if not SET.aimbotEnabled then return end

    local cam=workspace.CurrentCamera

    local char=player.Character

    local root=char and char:FindFirstChild("HumanoidRootPart")

    if not (cam and root) then return end

    local camPos=cam.CFrame.Position

    local camLook=cam.CFrame.LookVector

    local best,bestAng=nil,SET.aimFOV

    for _,t in ipairs(getTargets()) do

        if t==char then continue end

        if not isEnemy(t) then continue end

        local hd=t:FindFirstChild("Head") or t.PrimaryPart

        if hd then

            local hp=hd.Position

            local dir=(hp-camPos).Unit

            local ang=math.deg(math.acos(math.clamp(camLook:Dot(dir),-1,1)))

            if ang<=bestAng then best=hp bestAng=ang end

        end

    end

    if best then

        local alpha=1/(math.max(SET.aimSmooth,1)+1)

        cam.CFrame=cam.CFrame:Lerp(CFrame.lookAt(camPos,best),alpha)

    end

end)

-- Reaplica apos respawn

player.CharacterAdded:Connect(function()

    if SET.noclipEnabled then noclipping() end

    if SET.espEnabled then refreshESP() end

end)

P.PlayerAdded:Connect(function(pl) pl.CharacterAdded:Connect(function() if SET.espEnabled then refreshESP() end end) end)

-- HOME: license dashboard
local home=N("Frame",{Parent=ct,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1})
N("TextLabel",{Parent=home,Position=UDim2.fromOffset(22,18),Size=UDim2.new(1,-44,0,28),BackgroundTransparency=1,Text="Overview",Font=FONT,TextSize=22,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left})
N("TextLabel",{Parent=home,Position=UDim2.fromOffset(22,47),Size=UDim2.new(1,-44,0,18),BackgroundTransparency=1,Text="License, account and session status.",Font=Enum.Font.Gotham,TextSize=11,TextColor3=Color3.fromRGB(104,106,118),TextXAlignment=Enum.TextXAlignment.Left})
local cardHome=card(home,82,176)
local homeLogo=N("Frame",{Parent=cardHome,Position=UDim2.fromOffset(16,17),Size=UDim2.fromOffset(82,34),BackgroundTransparency=1})
local hp=N("ImageLabel",{Parent=homeLogo,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(15,17),Size=UDim2.fromOffset(29,22),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,Rotation=ROT})if PI then pcall(function()hp.ImageContent=Content.fromObject(PI)end)end
local hpl=N("ImageLabel",{Parent=homeLogo,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(46,17),Size=UDim2.fromOffset(22,22),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit})if LI then pcall(function()hpl.ImageContent=Content.fromObject(LI)end)end
local who=LIC.discord_name~=""and LIC.discord_name or(LIC.username~=""and LIC.username or P.LocalPlayer.Name)
N("TextLabel",{Parent=cardHome,Position=UDim2.fromOffset(96,14),Size=UDim2.new(1,-112,0,21),BackgroundTransparency=1,Text="License authenticated",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.fromRGB(232,232,238),TextXAlignment=Enum.TextXAlignment.Left})
N("TextLabel",{Parent=cardHome,Position=UDim2.fromOffset(96,35),Size=UDim2.new(1,-112,0,16),BackgroundTransparency=1,Text="Welcome, "..who..".",Font=Enum.Font.Gotham,TextSize=10,TextColor3=Color3.fromRGB(104,106,118),TextXAlignment=Enum.TextXAlignment.Left})
N("Frame",{Parent=cardHome,Position=UDim2.fromOffset(16,66),Size=UDim2.new(1,-32,0,1),BackgroundColor3=Color3.fromRGB(57,58,69),BackgroundTransparency=.48,BorderSizePixel=0})
local function chip(x,w,title,main,sub)local f=N("Frame",{Parent=cardHome,Position=UDim2.new(x,16,0,84),Size=UDim2.new(w,-22,0,70),BackgroundColor3=Color3.fromRGB(17,17,21),BackgroundTransparency=.05,BorderSizePixel=0})R(f,8)softStroke(f,Color3.fromRGB(51,52,62),.62,1)N("TextLabel",{Parent=f,Position=UDim2.fromOffset(11,7),Size=UDim2.new(1,-22,0,13),BackgroundTransparency=1,Text=title,Font=Enum.Font.GothamBold,TextSize=8,TextColor3=Color3.fromRGB(87,89,102),TextXAlignment=Enum.TextXAlignment.Left})N("TextLabel",{Parent=f,Position=UDim2.fromOffset(11,23),Size=UDim2.new(1,-22,0,18),BackgroundTransparency=1,Text=main,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Color3.fromRGB(205,206,215),TextXAlignment=Enum.TextXAlignment.Left})N("TextLabel",{Parent=f,Position=UDim2.fromOffset(11,43),Size=UDim2.new(1,-22,0,17),BackgroundTransparency=1,Text=sub,TextWrapped=true,Font=Enum.Font.Gotham,TextSize=8,TextColor3=Color3.fromRGB(89,91,103),TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top})end
chip(0,.34,"LICENSE",LIC.plan~=""and LIC.plan or"custom",LIC.tier~=""and("Tier: "..LIC.tier)or"Authorized")
chip(.34,.33,"EXPIRATION",LIC.expires~=""and LIC.expires:sub(1,10)or"Permanent",LIC.expires~=""and"Server controlled"or"No expiration")
chip(.67,.33,"SESSION",P.LocalPlayer.Name,"Place "..tostring(game.PlaceId))
local detail=card(home,270,72)
local function maskKey(k)k=trim(k)if #k<16 then return k end return k:sub(1,10).."••••"..k:sub(-5)end
N("TextLabel",{Parent=detail,Position=UDim2.fromOffset(15,10),Size=UDim2.new(1,-30,0,18),BackgroundTransparency=1,Text="Key  "..maskKey(LIC.key),Font=Enum.Font.Code,TextSize=9,TextColor3=Color3.fromRGB(151,153,166),TextXAlignment=Enum.TextXAlignment.Left})
N("TextLabel",{Parent=detail,Position=UDim2.fromOffset(15,31),Size=UDim2.new(1,-30,0,16),BackgroundTransparency=1,Text="Device  "..DEVICE_UUID.."  •  HW "..HARDWARE_HASH:sub(1,12).."...",Font=Enum.Font.Code,TextSize=8,TextColor3=Color3.fromRGB(86,88,101),TextXAlignment=Enum.TextXAlignment.Left})
N("TextLabel",{Parent=detail,Position=UDim2.fromOffset(15,49),Size=UDim2.new(1,-30,0,13),BackgroundTransparency=1,Text="License is revalidated automatically while Practice+ is open.",Font=Enum.Font.Gotham,TextSize=8,TextColor3=Color3.fromRGB(81,83,96),TextXAlignment=Enum.TextXAlignment.Left})

-- PLAYER: controles de Combate e Movimento em scrolling

local function mkScrollFrame()

    local sc=N("ScrollingFrame",{Parent=ct,Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(76,77,88),ScrollBarImageTransparency=.26,ScrollingDirection=Enum.ScrollingDirection.Y})

    local fr=N("Frame",{Parent=sc,Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y})

    fr:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() sc.CanvasSize=UDim2.fromOffset(0,fr.AbsoluteSize.Y+12) end)

    return sc,fr

end

local scroll,pframe=mkScrollFrame()

N("TextLabel",{Parent=pframe,Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(200,24),BackgroundTransparency=1,Text="Player",Font=FONT,TextSize=22,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left})

N("TextLabel",{Parent=pframe,Position=UDim2.fromOffset(14,42),Size=UDim2.new(1,-28,0,18),BackgroundTransparency=1,Text="Combat & movement controls",Font=Enum.Font.Gotham,TextSize=11,TextColor3=Color3.fromRGB(115,115,125),TextXAlignment=Enum.TextXAlignment.Left})

local y=72

local aimTog=mkToggle(pframe,y,"Aimbot","Aponta a cam para o inimigo mais proximo",function(on) SET.aimbotEnabled=on end) y=y+58

mkSlider(pframe,y,"FOV do Aimbot",30,360,0,"graus",SET.aimFOV,function(v) SET.aimFOV=v end) y=y+84

mkSlider(pframe,y,"Suavidade do Aimbot",1,30,0,"",SET.aimSmooth,function(v) SET.aimSmooth=math.round(v) end) y=y+84

mkSlider(pframe,y,"Forca do pulo",20,200,0,"",SET.jumpPower,function(v) SET.jumpPower=v end) y=y+84

local noFallTog=mkToggle(pframe,y,"Sem dano de queda","Nao toma dano ao cair",function(on) SET.noFallDamage=on end) y=y+58

local godTog=mkToggle(pframe,y,"God Mode","Imortal: nao toma dano nem morre",function(on) SET.godMode=on end) y=y+58

local hitboxTog=mkToggle(pframe,y,"Hitbox expandido","Inimigos com partes maiores",function(on) SET.hitboxExpand=on end) y=y+58

mkSlider(pframe,y,"Tamanho do Hitbox",1.2,3,1,"x",SET.hitboxSize,function(v) SET.hitboxSize=v end) y=y+84

local flyTog=mkToggle(pframe,y,"Fly","Voe segurando Espaco (sobe) / Shift (desce)",function(on) pcall(function() SET.flyEnabled=on toggleFly(on) end) end) y=y+58

mkSlider(pframe,y,"Velocidade do Fly",10,200,0,"studs/s",SET.flySpeed,function(v) SET.flySpeed=v end) y=y+84

local noclipTog=mkToggle(pframe,y,"Noclip","Atravessa paredes",function(on) SET.noclipEnabled=on end) y=y+58

pframe:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() scroll.CanvasSize=UDim2.fromOffset(0,pframe.AbsoluteSize.Y+12) end)

scroll.CanvasSize=UDim2.fromOffset(0,y+12)

-- VISUALS: ESP em scrolling

local vscroll,vframe=mkScrollFrame()

N("TextLabel",{Parent=vframe,Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(200,24),BackgroundTransparency=1,Text="Visuals",Font=FONT,TextSize=22,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left})

N("TextLabel",{Parent=vframe,Position=UDim2.fromOffset(14,42),Size=UDim2.new(1,-28,0,18),BackgroundTransparency=1,Text="ESP & rendering controls",Font=Enum.Font.Gotham,TextSize=11,TextColor3=Color3.fromRGB(104,106,118),TextXAlignment=Enum.TextXAlignment.Left})

local vy=72

local espTog=mkToggle(vframe,vy,"ESP","Destaca outros jogadores no mapa",function(on) SET.espEnabled=on refreshESP() end) vy=vy+58

local espColTog=mkToggle(vframe,vy,"ESP cor da equipe","Usa a cor da equipe do alvo",function(on) SET.espTeamColor=on refreshESP() end,true) vy=vy+58

local espNamesTog=mkToggle(vframe,vy,"Nomes acima da cabeca","Mostra o nome dos alvos",function(on) SET.espNames=on refreshESP() end) vy=vy+58

local espTracersTog=mkToggle(vframe,vy,"Tracers","Linhas da tela ate os alvos",function(on) SET.espTracers=on end) vy=vy+58

local espBoxesTog=mkToggle(vframe,vy,"Caixas (Boxes)","Caixa ao redor dos alvos",function(on) SET.espBoxes=on refreshESP() end) vy=vy+58

local espSelfTog=mkToggle(vframe,vy,"Mostrar voce no ESP","Marca o proprio personagem tambem",function(on) SET.espShowSelf=on refreshESP() end) vy=vy+58

N("TextLabel",{Parent=vframe,Position=UDim2.fromOffset(14,vy),Size=UDim2.new(1,-28,0,18),BackgroundTransparency=1,Text="Cor do ESP (RGB)",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Color3.fromRGB(220,220,225),TextXAlignment=Enum.TextXAlignment.Left}) vy=vy+24

mkSlider(vframe,vy,"Vermelho",0,255,0,"",SET.espColor.R*255,function(v) SET.espColor=Color3.fromRGB(math.round(v),math.round(SET.espColor.G*255),math.round(SET.espColor.B*255)) refreshESP() end) vy=vy+84

mkSlider(vframe,vy,"Verde",0,255,0,"",SET.espColor.G*255,function(v) SET.espColor=Color3.fromRGB(math.round(SET.espColor.R*255),math.round(v),math.round(SET.espColor.B*255)) refreshESP() end) vy=vy+84

mkSlider(vframe,vy,"Azul",0,255,0,"",SET.espColor.B*255,function(v) SET.espColor=Color3.fromRGB(math.round(SET.espColor.R*255),math.round(SET.espColor.G*255),math.round(v)) refreshESP() end) vy=vy+84

vframe:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() vscroll.CanvasSize=UDim2.fromOffset(0,vframe.AbsoluteSize.Y+12) end)

vscroll.CanvasSize=UDim2.fromOffset(0,vy+12)

-- SETTINGS

local sscroll,sframe=mkScrollFrame()

N("TextLabel",{Parent=sframe,Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(200,24),BackgroundTransparency=1,Text="Settings",Font=FONT,TextSize=22,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left})

N("TextLabel",{Parent=sframe,Position=UDim2.fromOffset(14,42),Size=UDim2.new(1,-28,0,18),BackgroundTransparency=1,Text="Interface & session preferences",Font=Enum.Font.Gotham,TextSize=11,TextColor3=Color3.fromRGB(104,106,118),TextXAlignment=Enum.TextXAlignment.Left})

local sy=72

local antiAfkTog=mkToggle(sframe,sy,"Anti-afk","Impede o kick por inatividade",function(on) SET.antiAfk=on end) sy=sy+58

mkSlider(sframe,sy,"Zoom da camera (FOV)",0,30,0,"",SET.zoomFOV,function(v) SET.zoomFOV=math.round(v) end) sy=sy+84

local themeBtn=N("TextButton",{Parent=sframe,Position=UDim2.fromOffset(14,sy),Size=UDim2.new(1,-28,0,52),BackgroundColor3=Color3.fromRGB(23,23,28),BorderSizePixel=0,Text="Tema: Padrao (clique p/ trocar)",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=W})

R(themeBtn,8)N("UIStroke",{Parent=themeBtn,Color=BD,Transparency=.45})

local themes={{"Padrao",Color3.fromRGB(99,130,246)},{"Verde",Color3.fromRGB(60,179,113)},{"Laranja",Color3.fromRGB(255,140,0)},{"Rosa",Color3.fromRGB(255,105,180)}}

local function applyTheme(idx)
    local c=themes[idx]
    SET.theme=idx
    ACCENT=c[2]
    themeBtn.Text="Tema: "..c[1].." (clique p/ trocar)"
    for _,r in ipairs(accentObjects)do
        local o,prop=r[1],r[2]
        if o and o.Parent then pcall(function()Q(o,D(.12),{[prop]=ACCENT},Enum.EasingStyle.Quad)end)end
    end
    for _,rf in ipairs(controlRefreshers)do pcall(rf)end
    Q(win,D(.1),{BackgroundColor3=SET.theme~=1 and Color3.fromRGB(20,20,24)or Color3.fromRGB(17,17,20)},Enum.EasingStyle.Quad)
end

themeBtn.MouseButton1Click:Connect(function() applyTheme((SET.theme%#themes)+1) end)

applyTheme(SET.theme)

sy=sy+58

local resetBtn=N("TextButton",{Parent=sframe,Position=UDim2.fromOffset(14,sy),Size=UDim2.new(1,-28,0,46),BackgroundColor3=Color3.fromRGB(120,45,45),BorderSizePixel=0,Text="Resetar todas as configs",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=W})

R(resetBtn,8)

resetBtn.MouseButton1Click:Connect(function()

    for _,t in ipairs({espTog,aimTog,noFallTog,godTog,hitboxTog,flyTog,noclipTog,espColTog,espNamesTog,espTracersTog,espBoxesTog,espSelfTog,antiAfkTog}) do t.set(false) end

    SET.aimFOV=150 SET.aimSmooth=4 SET.flySpeed=50 SET.walkSpeed=16 SET.jumpPower=50 SET.hitboxSize=1.5 SET.zoomFOV=0 SET.godMode=false

    SET.espColor=Color3.fromRGB(235,70,70)

    SET.espEnabled=false

    setState(player.Character and player.Character:FindFirstChildOfClass("Humanoid"),S_FALL,true)

    setState(player.Character and player.Character:FindFirstChildOfClass("Humanoid"),S_JUMP,true)

    refreshESP()

end)

sy=sy+58

sframe:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() sscroll.CanvasSize=UDim2.fromOffset(0,sframe.AbsoluteSize.Y+12) end)

sscroll.CanvasSize=UDim2.fromOffset(0,sy+12)

local col={Visuals=vscroll,Settings=sscroll}

-- ============================================================
-- TABS / SIDEBAR - FIX VISUAL
-- ============================================================

side.ZIndex=30
side.ClipsDescendants=false

local pages={
	Home=home,
	Player=scroll,
	Visuals=vscroll,
	Settings=sscroll
}

local allBtns={}
local activePage=nil

local function switchTab(name,tab)
	local target=pages[name]
	if not target then return end

	-- páginas
	for pageName,page in pairs(pages)do
		if page then
			page.Visible=(pageName==name)
		end
	end

	if activePage~=name then
		target.Position=UDim2.fromOffset(10,0)

		Q(
			target,
			D(.18),
			{Position=UDim2.fromOffset(0,0)},
			Enum.EasingStyle.Quint
		)
	end

	activePage=name

	-- aparência das abas
	for _,t in ipairs(allBtns)do
		local on=(t==tab)

		t.Button:SetAttribute("Active",on)

		Q(
			t.Button,
			D(.13),
			{
				BackgroundTransparency=on and .08 or 1,
				BackgroundColor3=on
					and Color3.fromRGB(29,29,36)
					or Color3.fromRGB(25,25,31)
			},
			Enum.EasingStyle.Quad
		)

		Q(
			t.Bar,
			D(.16),
			{
				BackgroundTransparency=on and 0 or 1,
				Size=on
					and UDim2.fromOffset(3,30)
					or UDim2.fromOffset(3,10)
			},
			Enum.EasingStyle.Quint
		)

		Q(
			t.Dot,
			D(.13),
			{
				BackgroundColor3=on
					and ACCENT
					or Color3.fromRGB(72,74,87),

				Size=on
					and UDim2.fromOffset(7,7)
					or UDim2.fromOffset(5,5)
			},
			Enum.EasingStyle.Quad
		)

		Q(
			t.Label,
			D(.13),
			{
				TextColor3=on
					and W
					or Color3.fromRGB(148,150,163)
			},
			Enum.EasingStyle.Quad
		)

		Q(
			t.Sub,
			D(.13),
			{
				TextColor3=on
					and Color3.fromRGB(112,114,128)
					or Color3.fromRGB(76,78,91)
			},
			Enum.EasingStyle.Quad
		)
	end
end

local function mkTab(name,sub,y,default)

	local b=N("TextButton",{
		Parent=side,

		Position=UDim2.fromOffset(12,y),
		Size=UDim2.new(1,-24,0,56),

		BackgroundColor3=Color3.fromRGB(29,29,36),
		BackgroundTransparency=default and .08 or 1,

		BorderSizePixel=0,

		Text="",

		AutoButtonColor=false,
		Active=true,
		Visible=true,

		ZIndex=50
	})

	R(b,10)

	-- linha lateral
	local bar=N("Frame",{
		Name="Accent",

		Parent=b,

		AnchorPoint=Vector2.new(0,.5),
		Position=UDim2.fromOffset(0,28),

		Size=default
			and UDim2.fromOffset(3,30)
			or UDim2.fromOffset(3,10),

		BackgroundColor3=ACCENT,
		BackgroundTransparency=default and 0 or 1,

		BorderSizePixel=0,

		Visible=true,

		ZIndex=53
	})

	R(bar,2)

	bindAccent(bar)

	-- bolinha da aba
	local dot=N("Frame",{
		Name="Dot",

		Parent=b,

		AnchorPoint=Vector2.new(.5,.5),
		Position=UDim2.fromOffset(18,28),

		Size=default
			and UDim2.fromOffset(7,7)
			or UDim2.fromOffset(5,5),

		BackgroundColor3=default
			and ACCENT
			or Color3.fromRGB(72,74,87),

		BorderSizePixel=0,

		Visible=true,

		ZIndex=54
	})

	R(dot,99)

	-- nome
	local lbl=N("TextLabel",{
		Name="Label",

		Parent=b,

		Position=UDim2.fromOffset(32,8),
		Size=UDim2.new(1,-42,0,20),

		BackgroundTransparency=1,

		Text=name,

		Font=Enum.Font.GothamMedium,
		TextSize=13,

		TextColor3=default
			and W
			or Color3.fromRGB(148,150,163),

		TextTransparency=0,

		TextXAlignment=Enum.TextXAlignment.Left,
		TextYAlignment=Enum.TextYAlignment.Center,

		Visible=true,

		ZIndex=55
	})

	-- descrição
	local sl=N("TextLabel",{
		Name="Sub",

		Parent=b,

		Position=UDim2.fromOffset(32,29),
		Size=UDim2.new(1,-42,0,15),

		BackgroundTransparency=1,

		Text=sub,

		Font=Enum.Font.Gotham,
		TextSize=9,

		TextColor3=default
			and Color3.fromRGB(112,114,128)
			or Color3.fromRGB(76,78,91),

		TextTransparency=0,

		TextXAlignment=Enum.TextXAlignment.Left,
		TextYAlignment=Enum.TextYAlignment.Center,

		Visible=true,

		ZIndex=55
	})

	b:SetAttribute("Active",default)

	local tab={
		Button=b,
		Bar=bar,
		Dot=dot,
		Label=lbl,
		Sub=sl,
		Name=name
	}

	allBtns[#allBtns+1]=tab

	b.MouseEnter:Connect(function()

		if b:GetAttribute("Active")then
			return
		end

		Q(
			b,
			D(.10),
			{
				BackgroundTransparency=.48,
				BackgroundColor3=Color3.fromRGB(27,27,34)
			},
			Enum.EasingStyle.Quad
		)

		Q(
			lbl,
			D(.10),
			{
				TextColor3=Color3.fromRGB(220,221,229)
			},
			Enum.EasingStyle.Quad
		)

		Q(
			dot,
			D(.10),
			{
				Size=UDim2.fromOffset(7,7)
			},
			Enum.EasingStyle.Quad
		)
	end)

	b.MouseLeave:Connect(function()

		if b:GetAttribute("Active")then
			return
		end

		Q(
			b,
			D(.10),
			{
				BackgroundTransparency=1
			},
			Enum.EasingStyle.Quad
		)

		Q(
			lbl,
			D(.10),
			{
				TextColor3=Color3.fromRGB(148,150,163)
			},
			Enum.EasingStyle.Quad
		)

		Q(
			dot,
			D(.10),
			{
				Size=UDim2.fromOffset(5,5)
			},
			Enum.EasingStyle.Quad
		)
	end)

	b.MouseButton1Click:Connect(function()
		switchTab(name,tab)
	end)

	return tab
end

local homeTab=mkTab(
	"Home",
	"Dashboard",
	42,
	true
)

local playerTab=mkTab(
	"Player",
	"Combat & movement",
	106,
	false
)

local visualsTab=mkTab(
	"Visuals",
	"ESP & rendering",
	170,
	false
)

local settingsTab=mkTab(
	"Settings",
	"Interface & session",
	234,
	false
)

switchTab("Home",homeTab)

-- IN

Q(win,D(.15),{GroupTransparency=0},Enum.EasingStyle.Quad)

Q(sc,D(.2),{Scale=1})

task.wait(D(.04))

Q(p,D(.15),{ImageTransparency=0},Enum.EasingStyle.Quad)

Q(plus,D(.15),{ImageTransparency=0},Enum.EasingStyle.Quad)

task.wait(D(.18))

-- OPEN

local F=G(OPEN)local DL=F*TDELAY local TD=F-DL

Q(p,F,{Position=UDim2.fromOffset(PX,CY+PYO),Rotation=0})

Q(ph,F,{Position=UDim2.fromOffset(LX,CY+LYO)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)

Q(plus,F,{Rotation=360},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)

task.delay(DL,function()

    Q(rev,TD,{Size=UDim2.fromOffset(TW+6,80)},Enum.EasingStyle.Quart)

    Q(wipe,TD*.78,{Position=UDim2.fromOffset(TX-WIPE-5,CY),Size=UDim2.fromOffset(0,88)},Enum.EasingStyle.Quart)

    for _,c in ipairs(corners)do Q(c[1],TD*.5,{Size=c[3],BackgroundTransparency=.04},Enum.EasingStyle.Quart)end

    shine.Position=UDim2.fromOffset(-60,CY)

    shine.BackgroundTransparency=1

    Q(shine,TD*.12,{BackgroundTransparency=SHA},Enum.EasingStyle.Quad)

    Q(shine,TD*.6,{Position=UDim2.fromOffset(HW+60,CY),BackgroundTransparency=1},Enum.EasingStyle.Linear)

end)

task.wait(F)

wipe.Visible=false

task.wait(D(HOLD))

-- REVERSE

local RF=F local LEAD=RF*.07

wipe.Visible=true

wipe.Position=UDim2.fromOffset(TX-10,CY)

wipe.Size=UDim2.fromOffset(0,88)

for _,c in ipairs(corners)do Q(c[1],RF*.28,{Size=c[2],BackgroundTransparency=1},Enum.EasingStyle.Quart,Enum.EasingDirection.In)end

Q(wipe,RF*.78,{Size=UDim2.fromOffset(TW+WIPE+20,88)},Enum.EasingStyle.Quart,Enum.EasingDirection.InOut)

task.wait(LEAD)

local MOVE=RF-LEAD

Q(p,MOVE,{Position=IP,Rotation=ROT},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)

Q(ph,MOVE,{Position=IL},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)

Q(plus,MOVE,{Rotation=0},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)

task.wait(MOVE)

rev.Size=UDim2.fromOffset(0,80)

wipe.Visible=false

-- LOAD (nao-bloqueante, com timeout de seguranca)

plus.Rotation=0

local loadTw=Q(plus,D(LOAD),{Rotation=360*TURNS},Enum.EasingStyle.Linear)

task.wait(D(LOAD)+.3)

plus.Rotation=0

-- MENU (abre via coroutine para nunca travar a GUI)

task.spawn(function()

    Q(logo,D(.14),{GroupTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)

    Q(sc,D(.12),{Scale=.98},Enum.EasingStyle.Quad)

    local winTw=Q(win,D(.38),{Size=UDim2.fromOffset(MW,MH)},Enum.EasingStyle.Quint)

    -- espera o tween OU um tempo maximo, o que vier primeiro

    task.wait(D(.38)+.2)

    logo.Visible=false

    for _,c in ipairs(corners)do c[1].Visible=false end

    menu.Visible=true

    Q(sc,D(.22),{Scale=1})

    Q(menu,D(.28),{GroupTransparency=0},Enum.EasingStyle.Quad)

end)
