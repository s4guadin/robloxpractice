local BLOCKED_PLACE_ID=114234929420007
if game.PlaceId==BLOCKED_PLACE_ID then
warn("esse jogo tem proteção anti-menu do nosso sistema, não é possível usar neste jogo")
return
end

--[[
    PRACTICE+ - AI-FRIENDLY BUILD

    Organização do arquivo:
      1) Serviços, helpers e geração do logo procedural
      2) AUTH: key, Roblox account + HWID/device binding e cofre local da licença
      3) Intro e janela principal
      4) Componentes de UI (cards, toggles, sliders e abas)
      5) Features de gameplay/visual
      6) Router futuro de scripts por PlaceId
      7) Cleanup, minimize/restore e animações finais

    Notas importantes para manutenção:
      - O AUTH fica dentro de uma função/escopo próprio para evitar o limite de
        registradores locais do Luau ("Out of local registers", limite 200).
      - Não mova dezenas de locals do AUTH para o chunk principal sem necessidade.
      - device_uuid e hardware_hash são DERIVADOS novamente a cada execução.
        device.txt/hardware.txt servem apenas como cache/diagnóstico e NÃO são
        considerados fonte de verdade para o HWID.
      - Quando gethwid() não existe, o código tenta RbxAnalyticsService:GetClientId().
        Só usa seed.txt como último fallback de estabilidade.
      - license.dat contém a key protegida localmente. Isso dificulta leitura/cópia
        casual, mas não torna um segredo client-side impossível de recuperar.
      - A API/Worker continua sendo a fonte de verdade para bloqueio, expiração e bind.
      - A licença é vinculada também ao UserId da conta Roblox na primeira ativação.
        Trocar de conta faz o Worker responder roblox_user_mismatch.
      - Revalidação automática: 1 vez por hora enquanto o menu estiver aberto.
      - O client NÃO acessa o GitHub para resolver jogos. Ele envia apenas o
        PlaceId ao Worker junto da validação da key. O Worker consulta placeids.txt
        e, se houver match, entrega o conteúdo do módulo já autorizado.
      - Sem match, o modo continua Universal/Practice.lua.
]]

P,T,A,X=game:GetService("Players"),game:GetService("TweenService"),game:GetService("AssetService"),game:GetService("TextService")
local pg=P.LocalPlayer:WaitForChild("PlayerGui")
local o=pg:FindFirstChild("PracticeIntro")
if o then o:Destroy()end

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
local w,h=128,96
local im=A:CreateEditableImage({Size=Vector2.new(w,h)})
local b=buffer.create(w*h*4)

local O={{2,2},{88,2},{98,3},{108,7},{117,11},{123,19},{126,28},{125,36},{121,43},{115,49},{108,53},{99,55},{50,55},{41,78},{19,94},{26,55},{35,21},{20,21}}
local H={{52,22},{92,22},{98,24},{103,27},{104,32},{102,37},{98,40},{92,42},{47,42}}
local S={{.25,.25},{.75,.25},{.25,.75},{.75,.75}}

local function poly(x,y,p)
local z=false
local j=#p
for i=1,#p do
local a,b=p[i],p[j]
if((a[2]>y)~=(b[2]>y))and x<(b[1]-a[1])*(y-a[2])/((b[2]-a[2])+.0001)+a[1]then
z=not z
end
j=i
end
return z
end

for y=0,h-1 do
for x=0,w-1 do
local n=0

for _,s in ipairs(S)do
if poly(x+s[1],y+s[2],O)and not poly(x+s[1],y+s[2],H)then
n=n+1
end
end

local i=(y*w+x)*4
buffer.writeu8(b,i,249)
buffer.writeu8(b,i+1,249)
buffer.writeu8(b,i+2,250)
buffer.writeu8(b,i+3,math.floor(n/4*255))
end
end

im:WritePixelsBuffer(Vector2.zero,Vector2.new(w,h),b)
return im
end

local function mkPlus()
local w,h,c=96,96,48
local im=A:CreateEditableImage({Size=Vector2.new(w,h)})
local b=buffer.create(w*h*4)

local pts={
{-.82,-.05,.8,Color3.fromRGB(245,55,155)},
{-.55,.58,.72,Color3.fromRGB(125,60,235)},
{-.3,-.74,.68,Color3.fromRGB(255,105,32)},
{.14,-.8,.68,Color3.fromRGB(255,225,28)},
{.68,-.34,.68,Color3.fromRGB(140,255,45)},
{.82,.08,.72,Color3.fromRGB(35,235,95)},
{.48,.62,.72,Color3.fromRGB(15,220,220)},
{0,.82,.72,Color3.fromRGB(25,115,250)}
}

local function g(x,y,a,b,r)
local dx,dy=x-a,y-b
return math.exp(-((dx*dx+dy*dy)/(r*r))*2)
end

local function rb(x,y,sx,sy,r)
local qx,qy=math.abs(x)-sx+r,math.abs(y)-sy+r
local ox,oy=math.max(qx,0),math.max(qy,0)
return math.sqrt(ox*ox+oy*oy)+math.min(math.max(qx,qy),0)-r
end

for y=0,h-1 do
for x=0,w-1 do
local dx,dy=x-c,y-c
local al=math.clamp(-math.min(rb(dx,dy,39,13,10),rb(dx,dy,13,39,10))+1,0,1)*255
local nx,ny=dx/39,dy/39
local r,gg,bl,t=0,0,0,0

for _,p in ipairs(pts)do
local q=g(nx,ny,p[1],p[2],p[3])
r=r+p[4].R*q
gg=gg+p[4].G*q
bl=bl+p[4].B*q
t=t+q
end

r,gg,bl=r/t,gg/t,bl/t

local l=g(nx,ny,-.1,-.15,.65)*.07
r=r+(1-r)*l
gg=gg+(1-gg)*l
bl=bl+(1-bl)*l

local i=(y*w+x)*4
buffer.writeu8(b,i,math.floor(r*255))
buffer.writeu8(b,i+1,math.floor(gg*255))
buffer.writeu8(b,i+2,math.floor(bl*255))
buffer.writeu8(b,i+3,math.floor(al))
end
end

im:WritePixelsBuffer(Vector2.zero,Vector2.new(w,h),b)
return im
end

local PI,LI

local okA,errA=pcall(function()PI=mkP()end)
if not okA then warn("ESP mkP falhou: "..tostring(errA))end

local okB,errB=pcall(function()LI=mkPlus()end)
if not okB then warn("ESP mkPlus falhou: "..tostring(errB))end

-- Revalidação da licença: 60 minutos.
-- Mantido em uma constante única para ficar simples alterar depois.
local LICENSE_REVALIDATE_SECONDS=60*60

-- ============================================================
-- ROUTER DE JOGO ENTREGUE PELO WORKER
--
-- O client nunca consulta placeids.txt nem obfuscate_scripts no GitHub.
-- Ele envia place_id no POST /verify-key. Só depois de validar key, produto,
-- conta Roblox, device e hardware o Worker devolve roblox_module.
--
-- Resposta esperada do Worker:
--   roblox_module = {
--       matched = true/false,
--       mode = "Game-specific"/"Universal",
--       place_id = "123",
--       script_name = "bladeball.lua"/"Practice.lua",
--       script_source = "..." -- só no login inicial
--   }
-- ============================================================

local GAME_ROUTER=(function()
    local route={
        place_id=tostring(game.PlaceId),
        matched=false,
        mode="Universal",
        script_name="Practice.lua",
        script_source="",
        source="worker",
        error=nil
    }

    local function trim(s)
        return tostring(s or ""):gsub("^%s+",""):gsub("%s+$","")
    end

    local function applyServerRoute(data)
        if type(data)~="table" then
            return route
        end

        route.place_id=trim(data.place_id)~="" and trim(data.place_id) or tostring(game.PlaceId)
        route.matched=data.matched==true
        route.mode=route.matched and "Game-specific" or "Universal"

        local scriptName=trim(data.script_name)
        route.script_name=scriptName~="" and scriptName or "Practice.lua"

        -- A revalidação horária pede apenas metadados. Portanto, se o Worker
        -- não reenviar o source, preservamos o source recebido no login inicial.
        local deliveredSource=type(data.script_source)=="string" and data.script_source or ""
        if deliveredSource~="" then
            route.script_source=deliveredSource
        end

        route.error=trim(data.router_error)~="" and trim(data.router_error) or nil
        route.source="worker"
        return route
    end

    local function loadMatchedScript(api)
        if not route.matched then
            return false,"universal"
        end

        if route.script_source=="" then
            return false,route.error or "script_not_delivered"
        end

        if type(loadstring)~="function" then
            route.error="loadstring_unavailable"
            return false,route.error
        end

        local chunk,compileErr=loadstring(route.script_source,"@"..route.script_name)
        if not chunk then
            route.error="compile_error: "..tostring(compileErr)
            return false,route.error
        end

        local ok,result=pcall(chunk)
        if not ok then
            route.error="runtime_error: "..tostring(result)
            return false,route.error
        end

        -- Formato recomendado para Bladeball.lua e módulos futuros:
        --   return function(api,route) ... end
        -- ou
        --   return { BuildUI=function(api,route) ... end }
        if type(result)=="function" then
            local applied,applyErr=pcall(result,api,route)
            if not applied then
                route.error="module_apply_error: "..tostring(applyErr)
                return false,route.error
            end
        elseif type(result)=="table" and type(result.BuildUI)=="function" then
            local applied,applyErr=pcall(result.BuildUI,api,route)
            if not applied then
                route.error="module_apply_error: "..tostring(applyErr)
                return false,route.error
            end
        end

        return true
    end

    return {
        Route=route,
        ApplyServerRoute=applyServerRoute,
        LoadMatchedScript=loadMatchedScript
    }
end)()

-- ============================================================
-- 2) AUTH / KEY SYSTEM / LOCAL LICENSE VAULT
--
-- Mantido em escopo próprio (AUTH=(function() ... end)()) para reduzir a
-- quantidade de registradores locais no chunk principal do Luau.
-- ============================================================

local AUTH=(function()
local HS=game:GetService("HttpService")
local B=bit32

local KEY_API=
	"https://practice-discord-auth.lexlutorddnet.workers.dev/verify-key"

local KEY_DIR="PracticePlus"

-- NOVO:
-- não salva mais a key como texto puro
local KEY_FILE=KEY_DIR.."/license.dat"

-- arquivo antigo, apenas para migração
local LEGACY_KEY_FILE=KEY_DIR.."/key.txt"

local DEV_FILE=KEY_DIR.."/device.txt"
local HW_FILE=KEY_DIR.."/hardware.txt"

local CLIENT_NAME="Practice Client"
local CLIENT_VERSION="1.0.0"
local PRODUCT_ID="roblox_client" -- Worker multi-produto: DDNet / Roblox / Minecraft

-- UserId é estável mesmo se o jogador trocar o nome da conta.
-- O Worker usa este valor como uma terceira trava independente de device/HWID.
local ROBLOX_USER_ID=tostring(P.LocalPlayer.UserId)
local ROBLOX_USERNAME=tostring(P.LocalPlayer.Name)

local REQ=
	request
	or http_request
	or (
		syn
		and syn.request
	)

local LIC={
	authorized=false,
	key="",
	tier="",
	plan="",
	expires="",
	discord_id="",
	discord_name="",
	username="",
	avatar_url="",
	roblox_user_id=ROBLOX_USER_ID,
	roblox_module={
		matched=false,
		mode="Universal",
		place_id=tostring(game.PlaceId),
		script_name="Practice.lua",
		script_source=""
	},
	message=""
}

local function trim(s)
	return tostring(s or "")
		:gsub("^%s+","")
		:gsub("%s+$","")
end

local function ensureDir()
	if not makefolder then
		return
	end

	pcall(function()
		if
			not isfolder
			or
			not isfolder(KEY_DIR)
		then
			makefolder(KEY_DIR)
		end
	end)
end

local function fread(p)
	if not(readfile and isfile)then
		return nil
	end

	local ok,v=pcall(function()
		if not isfile(p)then
			return nil
		end

		return readfile(p)
	end)

	if ok then
		return v
	end

	return nil
end

local function fwrite(p,v)
	if not writefile then
		return false
	end

	ensureDir()

	local ok=pcall(function()
		writefile(
			p,
			tostring(v)
		)
	end)

	return ok
end

local function fdel(p)
	if not(delfile and isfile)then
		return
	end

	pcall(function()
		if isfile(p)then
			delfile(p)
		end
	end)
end

-- ============================================================
-- DEVICE
-- ============================================================

local function uuidok(s)
	s=trim(s):lower()

	return
		#s==36
		and s:sub(9,9)=="-"
		and s:sub(14,14)=="-"
		and s:sub(19,19)=="-"
		and s:sub(24,24)=="-"
		and s:gsub("-",""):match("^[0-9a-f]+$")
			~=nil
end

local function hex64(s)
	s=trim(s):lower()

	return
		#s==64
		and s:match("^[0-9a-f]+$")
			~=nil
end

-- hash antigo continua só para geração
-- compatível do device/hardware já existente.
local function h32(s,seed)
	local h=seed

	for i=1,#s do
		h=
			(
				h*33+
				s:byte(i)
			)%
			4294967296

		h=
			B.bxor(
				h,
				B.rshift(
					h,
					13
				)
			)
	end

	return string.format(
		"%08x",
		h
	)
end

local function hash64(s)
	local out=""

	for i=1,8 do
		out=
			out..
			h32(
				s.."|"..i,

				(
					5381+
					i*
					2654435761
				)%
				4294967296
			)
	end

	return out
end

local function uuidFromHash(h)
	return
		h:sub(1,8)..
		"-"..
		h:sub(9,12)..
		"-"..
		h:sub(13,16)..
		"-"..
		h:sub(17,20)..
		"-"..
		h:sub(21,32)
end

-- Retorna a melhor identidade estável disponível neste executor.
-- Ordem de preferência:
--   1) gethwid / get_hwid / syn.gethwid  -> vínculo mais próximo do executor/máquina
--   2) RbxAnalyticsService:GetClientId() -> fallback estável da instalação do Roblox
--   3) seed.txt                           -> último fallback persistente
--
-- O terceiro retorno informa a origem, útil para debug. O quarto diz se o valor
-- deve permanecer estável entre execuções.
local function rawDeviceSeed()
	local r=""
	local source="none"

	local getters={
		function()
			if type(gethwid)=="function" then return gethwid() end
		end,
		function()
			if type(get_hwid)=="function" then return get_hwid() end
		end,
		function()
			if syn and type(syn.gethwid)=="function" then return syn.gethwid() end
		end,
	}

	for _,getter in ipairs(getters) do
		local ok,v=pcall(getter)
		if ok and v and trim(v)~="" then
			r=trim(v)
			source="executor_hwid"
			break
		end
	end

	if r=="" then
		local ok,v=pcall(function()
			return game:GetService("RbxAnalyticsService"):GetClientId()
		end)

		if ok and v and trim(v)~="" then
			r=trim(v)
			source="roblox_client_id"
		end
	end

	if r=="" then
		r=trim(fread(KEY_DIR.."/seed.txt"))
		if r~="" then source="persistent_seed" end
	end

	if r=="" then
		r=HS:GenerateGUID(false):lower()
		local saved=fwrite(KEY_DIR.."/seed.txt",r)
		source=saved and "persistent_seed" or "ephemeral_seed"
	end

	return r,source,source~="ephemeral_seed"
end

-- IMPORTANTE:
-- Não confiamos mais em device.txt/hardware.txt como entrada. Se alguém copiar
-- esses dois arquivos para outro PC, eles não substituem o HWID atual. A cada
-- execução, device_uuid e hardware_hash são recalculados a partir da identidade
-- obtida acima. Os arquivos são sobrescritos apenas para cache/diagnóstico.
--
-- Mantivemos a mesma fórmula da versão anterior para não mudar o bind de quem já
-- tinha uma key vinculada, desde que gethwid()/ClientId continue retornando o mesmo
-- valor que retornava quando a licença foi ativada.
local function deviceIdentity()
	local raw,source,stable=rawDeviceSeed()

	local base=hash64("Practice+|"..raw)

	local d=uuidok(raw)
		and raw:lower()
		or uuidFromHash(hash64("device|"..raw))

	local h=hash64(
		"hardware|"..raw.."|"..d.."|"..base
	)

	-- Cache informativo. Nunca é lido como fonte de verdade do bind.
	fwrite(DEV_FILE,d)
	fwrite(HW_FILE,h)

	return d,h,source,stable
end

local DEVICE_UUID,HARDWARE_HASH,HARDWARE_SOURCE,HARDWARE_STABLE=
	deviceIdentity()

-- ============================================================
-- REAL SHA-256
-- ============================================================

local K256={
	0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,
	0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
	0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,
	0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
	0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,
	0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
	0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,
	0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
	0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,
	0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
	0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,
	0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
	0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,
	0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
	0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,
	0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
}

local function U32(x)
	return x%4294967296
end

local function SHA256(s)
	local bytes={
		s:byte(
			1,
			#s
		)
	}

	local bitlen=
		#bytes*8

	bytes[
		#bytes+1
	]=128

	while
		#bytes%64
		~=56
	do
		bytes[
			#bytes+1
		]=0
	end

	local hi=
		math.floor(
			bitlen/
			4294967296
		)

	local lo=
		bitlen%
		4294967296

	for sh=24,0,-8 do
		bytes[
			#bytes+1
		]=
			B.band(
				B.rshift(
					hi,
					sh
				),
				255
			)
	end

	for sh=24,0,-8 do
		bytes[
			#bytes+1
		]=
			B.band(
				B.rshift(
					lo,
					sh
				),
				255
			)
	end

	local h0=0x6a09e667
	local h1=0xbb67ae85
	local h2=0x3c6ef372
	local h3=0xa54ff53a
	local h4=0x510e527f
	local h5=0x9b05688c
	local h6=0x1f83d9ab
	local h7=0x5be0cd19

	for p=1,#bytes,64 do
		local w={}

		for i=0,15 do
			local j=
				p+
				i*4

			w[
				i+1
			]=
				bytes[j]*
				16777216
				+
				bytes[j+1]*
				65536
				+
				bytes[j+2]*
				256
				+
				bytes[j+3]
		end

		for i=17,64 do
			local a=
				w[i-15]

			local b=
				w[i-2]

			local s0=
				B.bxor(
					B.rrotate(
						a,
						7
					),

					B.rrotate(
						a,
						18
					),

					B.rshift(
						a,
						3
					)
				)

			local s1=
				B.bxor(
					B.rrotate(
						b,
						17
					),

					B.rrotate(
						b,
						19
					),

					B.rshift(
						b,
						10
					)
				)

			w[i]=
				U32(
					w[i-16]+
					s0+
					w[i-7]+
					s1
				)
		end

		local a=h0
		local b=h1
		local c=h2
		local d=h3
		local e=h4
		local f=h5
		local g=h6
		local h=h7

		for i=1,64 do
			local S1=
				B.bxor(
					B.rrotate(
						e,
						6
					),

					B.rrotate(
						e,
						11
					),

					B.rrotate(
						e,
						25
					)
				)

			local ch=
				B.bxor(
					B.band(
						e,
						f
					),

					B.band(
						B.bnot(e),
						g
					)
				)

			local t1=
				U32(
					h+
					S1+
					ch+
					K256[i]+
					w[i]
				)

			local S0=
				B.bxor(
					B.rrotate(
						a,
						2
					),

					B.rrotate(
						a,
						13
					),

					B.rrotate(
						a,
						22
					)
				)

			local maj=
				B.bxor(
					B.band(
						a,
						b
					),

					B.band(
						a,
						c
					),

					B.band(
						b,
						c
					)
				)

			local t2=
				U32(
					S0+
					maj
				)

			h=g
			g=f
			f=e
			e=
				U32(
					d+
					t1
				)

			d=c
			c=b
			b=a

			a=
				U32(
					t1+
					t2
				)
		end

		h0=U32(h0+a)
		h1=U32(h1+b)
		h2=U32(h2+c)
		h3=U32(h3+d)
		h4=U32(h4+e)
		h5=U32(h5+f)
		h6=U32(h6+g)
		h7=U32(h7+h)
	end

	return string.format(
		"%08x%08x%08x%08x%08x%08x%08x%08x",
		h0,h1,h2,h3,
		h4,h5,h6,h7
	)
end

local function unhex(h)
	return (
		h:gsub(
			"..",
			function(x)
				return string.char(
					tonumber(
						x,
						16
					)
				)
			end
		)
	)
end

-- ============================================================
-- HMAC-SHA256
-- ============================================================

local function HMAC256(key,msg)
	if #key>64 then
		key=
			unhex(
				SHA256(key)
			)
	end

	if #key<64 then
		key=
			key..
			string.rep(
				"\0",
				64-#key
			)
	end

	local ip={}
	local op={}

	for i=1,64 do
		local c=
			key:byte(i)

		ip[i]=
			string.char(
				B.bxor(
					c,
					0x36
				)
			)

		op[i]=
			string.char(
				B.bxor(
					c,
					0x5c
				)
			)
	end

	local inner=
		unhex(
			SHA256(
				table.concat(ip)..
				msg
			)
		)

	return
		unhex(
			SHA256(
				table.concat(op)..
				inner
			)
		)
end

-- ============================================================
-- BASE64
-- ============================================================

local B64=
	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local B64MAP={}

for i=1,#B64 do
	B64MAP[
		B64:sub(i,i)
	]=i-1
end

local function b64encode(data)
	local out={}

	for i=1,#data,3 do
		local a,b,c=
			data:byte(
				i,
				i+2
			)

		b=b or 0
		c=c or 0

		local n=
			a*65536+
			b*256+
			c

		local x1=
			math.floor(
				n/
				262144
			)%64

		local x2=
			math.floor(
				n/
				4096
			)%64

		local x3=
			math.floor(
				n/
				64
			)%64

		local x4=
			n%64

		out[
			#out+1
		]=
			B64:sub(
				x1+1,
				x1+1
			)

		out[
			#out+1
		]=
			B64:sub(
				x2+1,
				x2+1
			)

		if i+1<=#data then
			out[
				#out+1
			]=
				B64:sub(
					x3+1,
					x3+1
				)
		else
			out[
				#out+1
			]="="
		end

		if i+2<=#data then
			out[
				#out+1
			]=
				B64:sub(
					x4+1,
					x4+1
				)
		else
			out[
				#out+1
			]="="
		end
	end

	return
		table.concat(out)
end

local function b64decode(s)
	s=
		tostring(s or "")
		:gsub(
			"%s",
			""
		)

	if
		#s==0
		or
		#s%4~=0
	then
		return nil
	end

	local out={}

	for i=1,#s,4 do
		local c1=
			s:sub(i,i)

		local c2=
			s:sub(
				i+1,
				i+1
			)

		local c3=
			s:sub(
				i+2,
				i+2
			)

		local c4=
			s:sub(
				i+3,
				i+3
			)

		local a=
			B64MAP[c1]

		local b=
			B64MAP[c2]

		if
			a==nil
			or
			b==nil
		then
			return nil
		end

		local c=
			c3=="="
			and 0
			or B64MAP[c3]

		local d=
			c4=="="
			and 0
			or B64MAP[c4]

		if
			c==nil
			or
			d==nil
		then
			return nil
		end

		local n=
			a*262144+
			b*4096+
			c*64+
			d

		out[
			#out+1
		]=
			string.char(
				math.floor(
					n/
					65536
				)%256
			)

		if c3~="="then
			out[
				#out+1
			]=
				string.char(
					math.floor(
						n/
						256
					)%256
				)
		end

		if c4~="="then
			out[
				#out+1
			]=
				string.char(
					n%256
				)
		end
	end

	return
		table.concat(out)
end

-- ============================================================
-- SHA256 STREAM LAYER
--
-- Cada bloco recebe um keystream diferente:
--
-- SHA256(key || nonce || counter)
--
-- Aplicamos XOR 3 vezes com 3 chaves independentes.
-- ============================================================

local function counter4(n)
	return string.char(
		math.floor(
			n/
			16777216
		)%256,

		math.floor(
			n/
			65536
		)%256,

		math.floor(
			n/
			256
		)%256,

		n%256
	)
end

local function streamCrypt(
	data,
	key,
	nonce
)
	local out={}
	local pos=1
	local counter=0

	while pos<=#data do
		local stream=
			unhex(
				SHA256(
					key..
					nonce..
					counter4(
						counter
					)
				)
			)

		local amount=
			math.min(
				32,
				#data-
				pos+
				1
			)

		for i=1,amount do
			out[
				#out+1
			]=
				string.char(
					B.bxor(
						data:byte(
							pos+
							i-
							1
						),

						stream:byte(i)
					)
				)
		end

		pos+=amount

		counter=
			(
				counter+1
			)%
			4294967296
	end

	return
		table.concat(out)
end

-- ============================================================
-- VAULT
-- ============================================================

-- Não é uma "senha secreta".
-- Ela está no cliente e portanto pode ser descoberta.
-- Serve como domínio extra na derivação das chaves.
local VAULT_PEPPER=
	table.concat({
		"P",
		"r4",
		"ct",
		"1c",
		"3",
		"+",
		"::",
		"Local",
		"Vault",
		"::",
		"V3",
		"::",
		"7FD1",
		"9A4C",
		"B622",
		"E08F"
	})

local function vaultMaterial(salt)
	-- 256-bit master
	local master=
		unhex(
			SHA256(
				VAULT_PEPPER..
				"|"..
				DEVICE_UUID..
				"|"..
				HARDWARE_HASH
			)
		)

	local k1=
		unhex(
			SHA256(
				master..
				salt..
				"\1"
			)
		)

	local k2=
		unhex(
			SHA256(
				master..
				salt..
				"\2"
			)
		)

	local k3=
		unhex(
			SHA256(
				master..
				salt..
				"\3"
			)
		)

	local km=
		unhex(
			SHA256(
				master..
				salt..
				"\255"
			)
		)

	local n1=
		unhex(
			SHA256(
				"N1"..
				master..
				salt
			)
		):
		sub(
			1,
			16
		)

	local n2=
		unhex(
			SHA256(
				"N2"..
				master..
				salt
			)
		):
		sub(
			1,
			16
		)

	local n3=
		unhex(
			SHA256(
				"N3"..
				master..
				salt
			)
		):
		sub(
			1,
			16
		)

	return
		k1,k2,k3,
		km,
		n1,n2,n3
end

local function constantEqual(a,b)
	if
		type(a)~="string"
		or
		type(b)~="string"
		or
		#a~=#b
	then
		return false
	end

	local diff=0

	for i=1,#a do
		diff=
			B.bor(
				diff,
				B.bxor(
					a:byte(i),
					b:byte(i)
				)
			)
	end

	return diff==0
end

local function makeSalt()
	-- 32 bytes = 256 bits de salt
	return
		unhex(
			SHA256(
				HS:
				GenerateGUID(false)
				..
				"|"
				..
				tostring(
					os.clock()
				)
				..
				"|"
				..
				tostring(
					os.time()
				)
				..
				"|"
				..
				DEVICE_UUID
				..
				"|"
				..
				tostring(
					math.random()
				)
			)
		)
end

local function vaultEncrypt(key)
	key=trim(key)

	if key==""then
		return nil
	end

	local salt=
		makeSalt()

	local k1,k2,k3,
		km,n1,n2,n3=
			vaultMaterial(
				salt
			)

	-- prefixo permite detectar decrypt incorreto
	local plain=
		"PracticeKey\0"..
		key

	-- CAMADA 1
	local c1=
		streamCrypt(
			plain,
			k1,
			n1
		)

	-- CAMADA 2
	local c2=
		streamCrypt(
			c1,
			k2,
			n2
		)

	-- CAMADA 3
	local c3=
		streamCrypt(
			c2,
			k3,
			n3
		)

	local authenticated=
		"PV3"..
		salt..
		c3

	-- MAC 256-bit.
	-- Se alguém editar o arquivo,
	-- a leitura é recusada.
	local tag=
		HMAC256(
			km,
			authenticated
		)

	local package=
		"PV3"..
		salt..
		tag..
		c3

	return
		b64encode(
			package
		)
end

local function vaultDecrypt(blob)
	blob=
		trim(blob)

	if blob==""then
		return nil
	end

	local raw=
		b64decode(
			blob
		)

	if
		not raw
		or
		#raw<68
	then
		return nil
	end

	if raw:sub(1,3)~="PV3"then
		return nil
	end

	-- PV3 = 3 bytes
	-- salt = 32
	-- HMAC = 32
	local salt=
		raw:sub(
			4,
			35
		)

	local tag=
		raw:sub(
			36,
			67
		)

	local cipher=
		raw:sub(68)

	local k1,k2,k3,
		km,n1,n2,n3=
			vaultMaterial(
				salt
			)

	local expected=
		HMAC256(
			km,

			"PV3"..
			salt..
			cipher
		)

	if
		not constantEqual(
			tag,
			expected
		)
	then
		return nil
	end

	-- descriptografa na ordem inversa
	local p2=
		streamCrypt(
			cipher,
			k3,
			n3
		)

	local p1=
		streamCrypt(
			p2,
			k2,
			n2
		)

	local plain=
		streamCrypt(
			p1,
			k1,
			n1
		)

	local prefix=
		"PracticeKey\0"

	if
		plain:sub(
			1,
			#prefix
		)
		~=prefix
	then
		return nil
	end

	local key=
		trim(
			plain:sub(
				#prefix+1
			)
		)

	if key==""then
		return nil
	end

	return key
end

-- ============================================================
-- SECURE STORAGE
-- ============================================================

local function saveStoredKey(key)
	local encrypted=
		vaultEncrypt(key)

	if not encrypted then
		return false
	end

	local ok=
		fwrite(
			KEY_FILE,
			encrypted
		)

	if ok then
		-- remove versão antiga em texto puro
		fdel(
			LEGACY_KEY_FILE
		)
	end

	return ok
end

local function clearStoredKey()
	fdel(KEY_FILE)
	fdel(LEGACY_KEY_FILE)
end

local function savedKey()
	-- Primeiro tenta o cofre novo.
	local encrypted=
		trim(
			fread(
				KEY_FILE
			)
		)

	if encrypted~=""then
		local key=
			vaultDecrypt(
				encrypted
			)

		if
			key
			and
			key~=""
		then
			return key
		end
		fdel(KEY_FILE)
	end

	-- Migração automática:
	-- se ainda existir key.txt antiga,
	-- usa uma última vez.
	local legacy=
		trim(
			fread(
				LEGACY_KEY_FILE
			)
		)

	if legacy~=""then
		return legacy
	end

	return ""
end

-- ============================================================
-- API
-- ============================================================

local function executorName()
	if type(identifyexecutor)=="function"then
		local ok,a,b=
			pcall(
				identifyexecutor
			)

		if ok then
			return
				trim(a)..
				(
					b
					and
					(
						" "..
						trim(b)
					)
					or
					""
				)
		end
	end

	return "unknown"
end

local function decode(body)
	local ok,d=
		pcall(function()
			return
				HS:
				JSONDecode(
					body
					or
					""
				)
		end)

	if
		ok
		and
		type(d)=="table"
	then
		return d
	end

	return {}
end

local function applyLicense(k,d)
	local r=
		type(d.record)=="table"
		and d.record
		or {}

	LIC.authorized=
		d.authorized==true
		and
		d.ok==true

	LIC.key=k

	LIC.tier=
		trim(
			d.tier
			or
			r.tier
		)

	LIC.plan=
		trim(
			r.plan
		)

	LIC.expires=
		trim(
			r.expires_at
		)

	LIC.discord_id=
		trim(
			d.discord_id
			or
			r.discord_id
		)

	LIC.discord_name=
		trim(
			d.discord_name
			or
			r.discord_name
		)

	LIC.username=
		trim(
			d.username
			or
			r.username
		)

	LIC.avatar_url=
		trim(
			d.avatar_url
			or
			r.avatar_url
		)

	LIC.roblox_user_id=
		trim(
			d.roblox_user_id
			or
			r.roblox_user_id
			or
			ROBLOX_USER_ID
		)

	LIC.message=
		trim(
			d.message
		)

	local moduleData=
		type(d.roblox_module)=="table"
		and d.roblox_module
		or nil

	if moduleData then
		local previousSource=
			type(LIC.roblox_module)=="table"
			and tostring(LIC.roblox_module.script_source or "")
			or ""

		local deliveredSource=
			type(moduleData.script_source)=="string"
			and moduleData.script_source
			or ""

		LIC.roblox_module={
			matched=moduleData.matched==true,
			mode=trim(moduleData.mode),
			place_id=trim(moduleData.place_id)~=""and trim(moduleData.place_id)or tostring(game.PlaceId),
			script_name=trim(moduleData.script_name)~=""and trim(moduleData.script_name)or "Practice.lua",
			script_source=deliveredSource~=""and deliveredSource or previousSource,
			router_error=trim(moduleData.router_error)
		}
	end

	return
		LIC.authorized
end

local ERRORS={
	invalid_key=
		"Key inválida.",

	blocked_key=
		"Esta key está bloqueada.",

	expired_key=
		"Esta key expirou.",

	device_mismatch=
		"Esta key já está vinculada a outro dispositivo.",

	hardware_mismatch=
		"O hardware desta key não corresponde a este PC.",

	roblox_user_required=
		"Não foi possível identificar a conta Roblox atual.",

	roblox_user_mismatch=
		"Esta key está vinculada a outra conta Roblox.",

	product_mismatch=
		"Esta key não está liberada para o Roblox.",

	invalid_product=
		"Produto inválido na autenticação.",

	hardware_fingerprint_weak=
		"Fingerprint de hardware insuficiente.",

	client_identity_required=
		"Identidade do cliente recusada pelo servidor.",

	client_version_not_allowed=
		"Esta versão do Practice+ não é permitida.",

	client_build_not_allowed=
		"Esta build do Practice+ não é permitida.",

	rate_limited=
		"Muitas tentativas. Aguarde um pouco.",

	server_error=
		"Erro interno no servidor de keys.",

	device_required=
		"Não foi possível gerar o Device ID.",

	hardware_required=
		"Não foi possível gerar o Hardware ID."
}

-- Faz uma validação real no Worker.
-- persist=true/omitido: grava/atualiza license.dat após sucesso.
-- persist=false: usado na revalidação periódica para não reescrever o cofre a cada 60 min.
local function verifyKey(k,persist)
	k=trim(k)

	if k==""then
		return
			false,
			"Digite uma key.",
			"invalid_key"
	end

	if not REQ then
		return
			false,
			"Seu executor não oferece request/http_request.",
			"network"
	end

	-- Sem uma origem estável, a key seria vinculada a um ID diferente no próximo
	-- boot. Melhor recusar explicitamente do que gerar um device mismatch depois.
	if not HARDWARE_STABLE then
		return false,
			"Seu executor não fornece HWID/ClientId nem armazenamento persistente para um Device ID estável.",
			"device_required"
	end

	local payload={
		key=k,
		product_id=PRODUCT_ID, -- força explicitamente o bind/validação do produto Roblox

		device_uuid=
			DEVICE_UUID,

		hardware_hash=
			HARDWARE_HASH,

		hardware_score=32,
		hardware_source=HARDWARE_SOURCE, -- campo extra de diagnóstico; Worker pode ignorar

		client_name=
			CLIENT_NAME,

		client_version=
			CLIENT_VERSION,

		-- ACCOUNT BIND: o Worker grava este UserId na primeira ativação e
		-- recusa a mesma key quando o script roda em outra conta Roblox.
		roblox_user_id=ROBLOX_USER_ID,
		roblox_username=ROBLOX_USERNAME,

		place_id=
			tostring(
				game.PlaceId
			),

		-- Login inicial: pede ao Worker o source do módulo específico.
		-- Revalidação horária (persist=false): só valida a licença/metadados.
		want_game_script=
			persist~=false,

		executor=
			executorName()
	}

	local ok,res=
		pcall(function()
			return REQ({
				Url=KEY_API,

				Method="POST",

				Headers={
					["Content-Type"]=
						"application/json",

					Accept=
						"application/json"
				},

				Body=
					HS:
					JSONEncode(
						payload
					)
			})
		end)

	if not ok then
		return
			false,
			"Falha ao conectar ao servidor de keys.",
			"network"
	end

	local code=
		tonumber(
			res.StatusCode
			or
			res.Status
			or
			0
		)
		or
		0

	local d=
		decode(
			res.Body
			or
			res.body
		)

	if code==429 then
		return
			false,
			ERRORS.rate_limited,
			"rate_limited"
	end

	if code>=500 then
		return
			false,
			ERRORS.server_error,
			"network"
	end

	if applyLicense(k,d)then
		-- ÚNICO local onde a key é persistida.
		-- Agora entra no cofre criptografado.
		if persist~=false then saveStoredKey(k)end

		return
			true,
			"Autorizado.",
			"authorized"
	end

	local m=
		trim(
			d.message
		)

	if m==""then
		m="invalid_key"
	end

	return
		false,
		ERRORS[m]
		or
		(
			"Acesso negado: "..
			m
		),
		m
end

-- ============================================================
-- KEY UI
-- ============================================================

local function keyGate(prefill,msg)
	local g=N("ScreenGui",{
		Name="PracticeKeyGate",

		Parent=pg,

		IgnoreGuiInset=true,

		ResetOnSpawn=false,

		DisplayOrder=1000000,

		ZIndexBehavior=
			Enum.ZIndexBehavior.Sibling
	})

	local shade=N("Frame",{
		Parent=g,

		Size=
			UDim2.fromScale(
				1,
				1
			),

		BackgroundColor3=
			Color3.fromRGB(
				5,
				5,
				7
			),

		BackgroundTransparency=.18,

		BorderSizePixel=0
	})

	local box=N("CanvasGroup",{
		Parent=g,

		AnchorPoint=
			Vector2.new(
				.5,
				.5
			),

		Position=
			UDim2.fromScale(
				.5,
				.5
			),

		Size=
			UDim2.fromOffset(
				430,
				254
			),

		BackgroundColor3=
			Color3.fromRGB(
				16,
				16,
				20
			),

		BorderSizePixel=0,

		GroupTransparency=1
	})

	R(box,12)

	N("UIStroke",{
		Parent=box,

		Color=
			Color3.fromRGB(
				66,
				67,
				79
			),

		Transparency=.28,

		Thickness=1
	})

	local bs=N("UIScale",{
		Parent=box,
		Scale=.95
	})

	local lg=N("Frame",{
		Parent=box,

		Position=
			UDim2.fromOffset(
				22,
				18
			),

		Size=
			UDim2.fromOffset(
				82,
				38
			),

		BackgroundTransparency=1
	})

	local lp=N("ImageLabel",{
		Parent=lg,

		AnchorPoint=
			Vector2.new(
				.5,
				.5
			),

		Position=
			UDim2.fromOffset(
				17,
				19
			),

		Size=
			UDim2.fromOffset(
				31,
				24
			),

		BackgroundTransparency=1,

		ScaleType=
			Enum.ScaleType.Fit,

		Rotation=ROT,

		ZIndex=4
	})

	if PI then
		pcall(function()
			lp.ImageContent=
				Content.fromObject(
					PI
				)
		end)
	end

	local lplus=N("ImageLabel",{
		Parent=lg,

		AnchorPoint=
			Vector2.new(
				.5,
				.5
			),

		Position=
			UDim2.fromOffset(
				49,
				19
			),

		Size=
			UDim2.fromOffset(
				25,
				25
			),

		BackgroundTransparency=1,

		ScaleType=
			Enum.ScaleType.Fit,

		ZIndex=5
	})

	if LI then
		pcall(function()
			lplus.ImageContent=
				Content.fromObject(
					LI
				)
		end)
	end

	N("TextLabel",{
		Parent=box,

		Position=
			UDim2.fromOffset(
				92,
				18
			),

		Size=
			UDim2.new(
				1,
				-115,
				0,
				23
			),

		BackgroundTransparency=1,

		Text="Practice+",

		Font=
			Enum.Font.GothamBold,

		TextSize=17,

		TextColor3=W,

		TextXAlignment=
			Enum.TextXAlignment.Left
	})

	N("TextLabel",{
		Parent=box,

		Position=
			UDim2.fromOffset(
				92,
				40
			),

		Size=
			UDim2.new(
				1,
				-115,
				0,
				14
			),

		BackgroundTransparency=1,

		Text="LICENSE ACCESS",

		Font=
			Enum.Font.GothamBold,

		TextSize=8,

		TextColor3=
			Color3.fromRGB(
				91,
				93,
				106
			),

		TextXAlignment=
			Enum.TextXAlignment.Left
	})

	N("Frame",{
		Parent=box,

		Position=
			UDim2.fromOffset(
				22,
				69
			),

		Size=
			UDim2.new(
				1,
				-44,
				0,
				1
			),

		BackgroundColor3=
			Color3.fromRGB(
				61,
				62,
				73
			),

		BackgroundTransparency=.45,

		BorderSizePixel=0
	})

	N("TextLabel",{
		Parent=box,

		Position=
			UDim2.fromOffset(
				23,
				86
			),

		Size=
			UDim2.new(
				1,
				-46,
				0,
				18
			),

		BackgroundTransparency=1,

		Text=
			"Insira sua key do Practice+",

		Font=
			Enum.Font.GothamMedium,

		TextSize=12,

		TextColor3=
			Color3.fromRGB(
				224,
				225,
				232
			),

		TextXAlignment=
			Enum.TextXAlignment.Left
	})

	local input=N("TextBox",{
		Parent=box,

		Position=
			UDim2.fromOffset(
				23,
				113
			),

		Size=
			UDim2.new(
				1,
				-46,
				0,
				42
			),

		BackgroundColor3=
			Color3.fromRGB(
				23,
				23,
				29
			),

		BorderSizePixel=0,

		Text=
			prefill
			or
			"",

		PlaceholderText=
			"Practice-...",

		PlaceholderColor3=
			Color3.fromRGB(
				76,
				78,
				91
			),

		Font=
			Enum.Font.Code,

		TextSize=11,

		TextColor3=W,

		TextXAlignment=
			Enum.TextXAlignment.Left,

		ClearTextOnFocus=false
	})

	R(input,8)

	N("UIPadding",{
		Parent=input,

		PaddingLeft=
			UDim.new(
				0,
				12
			),

		PaddingRight=
			UDim.new(
				0,
				12
			)
	})

	local ist=N("UIStroke",{
		Parent=input,

		Color=
			Color3.fromRGB(
				61,
				62,
				74
			),

		Transparency=.42,

		Thickness=1
	})

	local status=N("TextLabel",{
		Parent=box,

		Position=
			UDim2.fromOffset(
				24,
				165
			),

		Size=
			UDim2.new(
				1,
				-48,
				0,
				18
			),

		BackgroundTransparency=1,

		Text=
			msg
			or
			(
				"Dispositivo: "..
				DEVICE_UUID:
				sub(
					1,
					8
				)..
				"..."
			),

		Font=
			Enum.Font.Gotham,

		TextSize=9,

		TextColor3=
			Color3.fromRGB(
				104,
				106,
				118
			),

		TextXAlignment=
			Enum.TextXAlignment.Left
	})

	local enter=N("TextButton",{
		Parent=box,

		Position=
			UDim2.fromOffset(
				23,
				194
			),

		Size=
			UDim2.new(
				1,
				-46,
				0,
				39
			),

		BackgroundColor3=
			Color3.fromRGB(
				99,
				130,
				246
			),

		BorderSizePixel=0,

		Text="Authenticate",

		Font=
			Enum.Font.GothamBold,

		TextSize=11,

		TextColor3=W,

		AutoButtonColor=false
	})

	R(enter,8)

	local unlocked=false
	local busy=false
	local lastAttempt=0 -- pequeno cooldown anti-spam; busy já impede requests concorrentes

	local function setStatus(t,bad)
		status.Text=t

		status.TextColor3=
			bad
			and
			Color3.fromRGB(
				229,
				103,
				110
			)
			or
			Color3.fromRGB(
				104,
				210,
				151
			)
	end

	local function go()
		if busy then
			return
		end

		local now=os.clock()
		if now-lastAttempt<0.6 then
			return
		end
		lastAttempt=now

		local k=
			trim(
				input.Text
			)

		if k==""then
			setStatus(
				"Digite uma key.",
				true
			)

			return
		end

		busy=true

		enter.Text=
			"Verifying..."

		status.TextColor3=
			Color3.fromRGB(
				126,
				128,
				142
			)

		status.Text=
			"Validando licença..."

		task.spawn(function()
			local ok,text,kind=
				verifyKey(k)

			if ok then
				setStatus(
					"Acesso autorizado.",
					false
				)

				enter.Text=
					"Authorized"

				Q(
					lplus,
					D(.30),
					{
						Rotation=360
					},
					Enum.EasingStyle.Quint
				)

				task.wait(
					D(.18)
				)

				Q(
					box,
					D(.14),
					{
						GroupTransparency=1
					},
					Enum.EasingStyle.Quad
				)

				Q(
					bs,
					D(.14),
					{
						Scale=.96
					},
					Enum.EasingStyle.Quad
				)

				task.wait(
					D(.15)
				)

				unlocked=true

				g:Destroy()

			else
				setStatus(
					text,
					true
				)

				enter.Text=
					"Authenticate"

				Q(
					ist,
					D(.1),
					{
						Color=
							Color3.fromRGB(
								170,
								65,
								73
							),

						Transparency=.1
					},
					Enum.EasingStyle.Quad
				)

				task.delay(
					D(.35),
					function()
						if ist.Parent then
							Q(
								ist,
								D(.15),
								{
									Color=
										Color3.fromRGB(
											61,
											62,
											74
										),

									Transparency=.42
								},
								Enum.EasingStyle.Quad
							)
						end
					end
				)

				busy=false
			end
		end)
	end

	enter.MouseButton1Click:
	Connect(go)

	input.FocusLost:
	Connect(function(ep)
		if ep then
			go()
		end
	end)

	Q(
		box,
		D(.18),
		{
			GroupTransparency=0
		},
		Enum.EasingStyle.Quad
	)

	Q(
		bs,
		D(.25),
		{
			Scale=1
		},
		Enum.EasingStyle.Back
	)

	repeat
		task.wait()
	until
		unlocked
		or
		not g.Parent

	return unlocked
end
return {
	LIC=LIC,
	DEVICE_UUID=DEVICE_UUID,
	HARDWARE_HASH=HARDWARE_HASH,
	HARDWARE_SOURCE=HARDWARE_SOURCE,
	HARDWARE_STABLE=HARDWARE_STABLE,
	ROBLOX_USER_ID=ROBLOX_USER_ID,
	ROBLOX_USERNAME=ROBLOX_USERNAME,
	verifyKey=verifyKey,
	savedKey=savedKey,
	keyGate=keyGate,
	clearStoredKey=clearStoredKey,
}
end)()

local sk=AUTH.savedKey()
local access,why,kind=false,nil,nil
if sk~=""then
 access,why,kind=AUTH.verifyKey(sk)
 if not access and(kind=="invalid_key"or kind=="blocked_key"or kind=="expired_key"or kind=="device_mismatch"or kind=="hardware_mismatch"or kind=="roblox_user_mismatch"or kind=="product_mismatch"or kind=="invalid_product")then AUTH.clearStoredKey()sk=""end
end
if not access and not AUTH.keyGate(sk,why)then return end

-- A rota veio junto da resposta autenticada do Worker. Nenhuma leitura de GitHub
-- acontece no executor/client.
GAME_ROUTER.ApplyServerRoute(AUTH.LIC.roblox_module)

local gui=N("ScreenGui",{
Name="PracticeIntro",
Parent=pg,
IgnoreGuiInset=true,
ResetOnSpawn=false,
DisplayOrder=999999,
ZIndexBehavior=Enum.ZIndexBehavior.Sibling
})

task.spawn(function()
	while gui.Parent do
		task.wait(LICENSE_REVALIDATE_SECONDS)

		if not gui.Parent then
			break
		end

		local ok,msg,kind=AUTH.verifyKey(AUTH.LIC.key,false)

		if not ok and kind~="network" and kind~="rate_limited" then
			warn("[Practice+] licença recusada: "..tostring(msg))

			AUTH.clearStoredKey()

			if gui.Parent then
				gui:Destroy()
			end

			break
		end
	end
end)

local win=N("CanvasGroup",{
Parent=gui,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromScale(.5,.5),
Size=UDim2.fromOffset(WW,WH),
BackgroundColor3=BG,
BorderSizePixel=0,
GroupTransparency=1
})

R(win,10)

N("UIStroke",{
Parent=win,
Color=BD,
Transparency=.4,
Thickness=1
})

local sc=N("UIScale",{
Parent=win,
Scale=.97
})

local logo=N("CanvasGroup",{
Parent=win,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromScale(.5,.5),
Size=UDim2.fromOffset(HW,HH),
BackgroundTransparency=1
})

local TW=X:GetTextSize("ractice",FS,FONT,Vector2.new(1000,100)).X
local ST=(HW-(PW+GP+RPAD+TW+GPS+PS))/2
local PX,TX=ST+PW/2+PXO,ST+PW+GP+RPAD+TXO
local LX=TX+TW+GPS+PS/2+LXO

local IP=UDim2.fromOffset(HW/2-18,CY)
local IL=UDim2.fromOffset(HW/2+24,CY)

local rev=N("Frame",{
Parent=logo,
Position=UDim2.fromOffset(TX,4+TYO),
Size=UDim2.fromOffset(0,80),
BackgroundTransparency=1,
ClipsDescendants=true,
ZIndex=2
})

N("TextLabel",{
Parent=rev,
Size=UDim2.fromOffset(TW+6,80),
BackgroundTransparency=1,
Text="ractice",
Font=FONT,
TextSize=FS,
TextColor3=W,
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
ZIndex=2
})

local wipe=N("Frame",{
Parent=logo,
AnchorPoint=Vector2.new(0,.5),
Position=UDim2.fromOffset(TX-10,CY),
Size=UDim2.fromOffset(WIPE,88),
BackgroundColor3=BG,
BorderSizePixel=0,
Rotation=WA,
ZIndex=4
})

local p=N("ImageLabel",{
Parent=logo,
AnchorPoint=Vector2.new(.5,.5),
Position=IP,
Size=UDim2.fromOffset(PW,PH),
BackgroundTransparency=1,
ImageTransparency=1,
ScaleType=Enum.ScaleType.Fit,
Rotation=ROT,
ZIndex=5
})

if PI then
pcall(function()
p.ImageContent=Content.fromObject(PI)
end)
end

local ph=N("Frame",{
Parent=logo,
AnchorPoint=Vector2.new(.5,.5),
Position=IL,
Size=UDim2.fromOffset(PS,PS),
BackgroundTransparency=1,
ZIndex=5
})

local plus=N("ImageLabel",{
Parent=ph,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromScale(.5,.5),
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
ImageTransparency=1,
ScaleType=Enum.ScaleType.Fit,
ZIndex=5
})

if LI then
pcall(function()
plus.ImageContent=Content.fromObject(LI)
end)
end

local fx=N("Frame",{
Parent=logo,
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
ClipsDescendants=true,
ZIndex=7
})

local shine=N("Frame",{
Parent=fx,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromOffset(-60,CY),
Size=UDim2.fromOffset(SHW,120),
BackgroundColor3=W,
BackgroundTransparency=1,
BorderSizePixel=0,
Rotation=-18,
ZIndex=7
})

R(shine,99)

local corners={}

local function C(ax,ay,h)
local sx,sy=h and 0 or BTH,h and BTH or 0
local tx,ty=h and BLEN or BTH,h and BTH or BLEN

local f=N("Frame",{
Parent=win,
AnchorPoint=Vector2.new(ax,ay),
Position=UDim2.new(
ax,
ax==1 and-BPX or BPX,
ay,
ay==1 and-BPY or BPY
),
Size=UDim2.fromOffset(sx,sy),
BackgroundColor3=W,
BackgroundTransparency=1,
BorderSizePixel=0,
ZIndex=6
})

R(f,99)

corners[#corners+1]={
f,
UDim2.fromOffset(sx,sy),
UDim2.fromOffset(tx,ty)
}
end

C(0,0,true)
C(0,0,false)
C(1,0,true)
C(1,0,false)
C(0,1,true)
C(0,1,false)
C(1,1,true)
C(1,1,false)

local UI=game:GetService("UserInputService")
local runtimeConnections={}
local function RC(sig,fn)local c=sig:Connect(fn)runtimeConnections[#runtimeConnections+1]=c return c end
local ACCENT=Color3.fromRGB(99,130,246)
local accentObjects={}
local controlRefreshers={}

local function bindAccent(o,prop)
prop=prop or"BackgroundColor3"

o[prop]=ACCENT

accentObjects[#accentObjects+1]={
o,
prop
}

return o
end

local function softStroke(x,col,tr,th)
return N("UIStroke",{
Parent=x,
Color=col or BD,
Transparency=tr or .45,
Thickness=th or 1
})
end

local function grad(x,a,b,rot)
return N("UIGradient",{
Parent=x,
Rotation=rot or 90,
Color=ColorSequence.new(a,b)
})
end

local menu=N("CanvasGroup",{
Parent=win,
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
GroupTransparency=1,
Visible=false,
ZIndex=10
})

local top=N("Frame",{
Parent=menu,
Size=UDim2.new(1,0,0,TOPH),
BackgroundColor3=Color3.fromRGB(20,20,24),
BorderSizePixel=0,
ZIndex=20
})

R(top,10)

grad(
top,
Color3.fromRGB(27,27,32),
Color3.fromRGB(18,18,22),
0
)

N("Frame",{
Parent=top,
Position=UDim2.new(0,0,1,-10),
Size=UDim2.new(1,0,0,10),
BackgroundColor3=Color3.fromRGB(18,18,22),
BorderSizePixel=0,
ZIndex=20
})

local topLine=N("Frame",{
Parent=top,
AnchorPoint=Vector2.new(0,1),
Position=UDim2.new(0,0,1,0),
Size=UDim2.new(1,0,0,1),
BackgroundColor3=Color3.fromRGB(73,74,86),
BackgroundTransparency=.50,
BorderSizePixel=0,
ZIndex=24
})

N("UIGradient",{
Parent=topLine,
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,1),
NumberSequenceKeypoint.new(.12,.28),
NumberSequenceKeypoint.new(.45,.72),
NumberSequenceKeypoint.new(1,1)
})
})

local brand=N("TextButton",{
Parent=top,
Position=UDim2.fromOffset(16,7),
-- Hitbox acompanha o logo de verdade. Antes eram 185px e o hover disparava
-- muito longe do texto na horizontal.
Size=UDim2.fromOffset(126,44),
BackgroundTransparency=1,
Text="",
AutoButtonColor=false,
ZIndex=30
})

local BPW,BPH,BPS,BFS=28,22,22,16

local BTW=X:GetTextSize(
"ractice",
BFS,
Enum.Font.GothamBold,
Vector2.new(300,50)
).X

local brandP=N("ImageLabel",{
Parent=brand,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromOffset(24,22),
Size=UDim2.fromOffset(BPW,BPH),
BackgroundTransparency=1,
ImageTransparency=0,
ScaleType=Enum.ScaleType.Fit,
Rotation=ROT,
ZIndex=32
})

if PI then
pcall(function()
brandP.ImageContent=Content.fromObject(PI)
end)
end

local brandRev=N("Frame",{
Parent=brand,
Position=UDim2.fromOffset(37,4),
Size=UDim2.fromOffset(0,36),
BackgroundTransparency=1,
ClipsDescendants=true,
ZIndex=31
})

N("TextLabel",{
Parent=brandRev,
Size=UDim2.fromOffset(BTW+4,36),
BackgroundTransparency=1,
Text="ractice",
Font=Enum.Font.GothamBold,
TextSize=BFS,
TextColor3=W,
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
ZIndex=31
})

local brandPH=N("Frame",{
Parent=brand,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromOffset(53,22),
Size=UDim2.fromOffset(BPS,BPS),
BackgroundTransparency=1,
ZIndex=33
})

local brandPlus=N("ImageLabel",{
Parent=brandPH,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromScale(.5,.5),
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
ImageTransparency=0,
ScaleType=Enum.ScaleType.Fit,
ZIndex=33
})

if LI then
pcall(function()
brandPlus.ImageContent=Content.fromObject(LI)
end)
end

local brandToken=0

local function brandOpen(open)
brandToken+=1
local token=brandToken

if open then

Q(brandP,D(.22),{
Position=UDim2.fromOffset(21,22),
Rotation=0
},Enum.EasingStyle.Quint)

-- MAIS PRA DIREITA:
-- não invade o final de "ractice"
Q(brandPH,D(.28),{
Position=UDim2.fromOffset(55+BTW,22)
},Enum.EasingStyle.Quint)

Q(brandPlus,D(.28),{
Rotation=360
},Enum.EasingStyle.Quint)

task.delay(D(.035),function()
if token==brandToken then
Q(brandRev,D(.22),{
Size=UDim2.fromOffset(BTW+4,36)
},Enum.EasingStyle.Quart)
end
end)

else

Q(brandRev,D(.16),{
Size=UDim2.fromOffset(0,36)
},Enum.EasingStyle.Quart,Enum.EasingDirection.In)

Q(brandP,D(.24),{
Position=UDim2.fromOffset(24,22),
Rotation=ROT
},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)

Q(brandPH,D(.24),{
Position=UDim2.fromOffset(53,22)
},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)

Q(brandPlus,D(.24),{
Rotation=0
},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)

end
end

do
local brandScale=N("UIScale",{Parent=brand,Scale=1})

brand.MouseEnter:Connect(function()
brandOpen(true)
Q(brandScale,D(.12),{Scale=1.025},Enum.EasingStyle.Quad)
end)

brand.MouseLeave:Connect(function()
brandOpen(false)
Q(brandScale,D(.12),{Scale=1},Enum.EasingStyle.Quad)
end)
end

N("TextLabel",{
Parent=top,
Position=UDim2.fromOffset(205,19),
Size=UDim2.fromOffset(170,20),
BackgroundTransparency=1,
Text="CONTROL CENTER",
Font=Enum.Font.GothamMedium,
TextSize=9,
TextColor3=Color3.fromRGB(92,94,107),
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=23
})

local online=N("Frame",{
Parent=top,
AnchorPoint=Vector2.new(1,.5),
Position=UDim2.new(1,-103,.5,0),
Size=UDim2.fromOffset(80,26),
BackgroundColor3=Color3.fromRGB(24,31,29),
BorderSizePixel=0,
ZIndex=23
})

R(online,8)

softStroke(
online,
Color3.fromRGB(58,91,77),
.6,
1
)

local od=N("Frame",{
Parent=online,
AnchorPoint=Vector2.new(0,.5),
Position=UDim2.fromOffset(10,13),
Size=UDim2.fromOffset(6,6),
BackgroundColor3=Color3.fromRGB(81,209,142),
BorderSizePixel=0,
ZIndex=24
})

R(od,99)

N("TextLabel",{
Parent=online,
Position=UDim2.fromOffset(22,0),
Size=UDim2.new(1,-26,1,0),
BackgroundTransparency=1,
Text="READY",
Font=Enum.Font.GothamBold,
TextSize=9,
TextColor3=Color3.fromRGB(137,218,174),
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=24
})

local function topButton(x,text,col)
local b=N("TextButton",{
Parent=top,
AnchorPoint=Vector2.new(1,.5),
Position=UDim2.new(1,x,.5,0),
Size=UDim2.fromOffset(31,31),
BackgroundColor3=Color3.fromRGB(31,31,37),
BackgroundTransparency=.10,
BorderSizePixel=0,
Text=text,
Font=Enum.Font.GothamBold,
TextSize=15,
TextColor3=col or Color3.fromRGB(178,179,191),
AutoButtonColor=false,
ZIndex=32
})

R(b,8)

softStroke(
b,
Color3.fromRGB(63,64,75),
.46,
1
)

local bs=N("UIScale",{Parent=b,Scale=1})

b.MouseEnter:Connect(function()
Q(bs,D(.10),{Scale=1.06},Enum.EasingStyle.Quad)
end)

b.MouseLeave:Connect(function()
Q(bs,D(.10),{Scale=1},Enum.EasingStyle.Quad)
end)

b.MouseButton1Down:Connect(function()
Q(bs,D(.06),{Scale=.94},Enum.EasingStyle.Quad)
end)

b.MouseButton1Up:Connect(function()
Q(bs,D(.08),{Scale=1.06},Enum.EasingStyle.Back)
end)

return b
end

local close=topButton(
-15,
"×",
Color3.fromRGB(212,110,114)
)

local minBtn=topButton(
-53,
"—",
Color3.fromRGB(195,196,206)
)

minBtn.MouseEnter:Connect(function()
Q(minBtn,D(.10),{
BackgroundColor3=Color3.fromRGB(45,45,53),
TextColor3=W
},Enum.EasingStyle.Quad)
end)

minBtn.MouseLeave:Connect(function()
Q(minBtn,D(.10),{
BackgroundColor3=Color3.fromRGB(31,31,37),
TextColor3=Color3.fromRGB(195,196,206)
},Enum.EasingStyle.Quad)
end)

close.MouseEnter:Connect(function()
Q(close,D(.10),{
BackgroundColor3=Color3.fromRGB(74,34,39),
TextColor3=Color3.fromRGB(255,192,195)
},Enum.EasingStyle.Quad)
end)

close.MouseLeave:Connect(function()
Q(close,D(.10),{
BackgroundColor3=Color3.fromRGB(31,31,37),
TextColor3=Color3.fromRGB(212,110,114)
},Enum.EasingStyle.Quad)
end)

close.MouseButton1Click:Connect(function()
gui:Destroy()
end)

-- Mantemos os elementos extras de drag em uma única tabela para não aumentar
-- desnecessariamente a quantidade de locals do chunk principal (Luau tem limite).
local dragHandles={}

-- Área principal de drag: praticamente todo o espaço vazio do header.
-- Corrigido: InputObject.Position (Vector3) é convertido para Vector2 durante o drag.
-- Brand e botões possuem ZIndex maior, então continuam recebendo hover/click normalmente.
dragHandles.Area=N("Frame",{
Parent=top,
Position=UDim2.fromOffset(132,0),
Size=UDim2.new(1,-322,1,0),
BackgroundTransparency=1,
Active=true,
ZIndex=25
})

-- Faixa inferior do header: dá um segundo lugar fácil de "pegar" o menu sem
-- transformar o logo inteiro em uma hitbox gigante.
dragHandles.Strip=N("Frame",{
Parent=top,
Position=UDim2.fromOffset(0,43),
Size=UDim2.new(1,-92,0,15),
BackgroundTransparency=1,
Active=true,
ZIndex=25
})

dragHandles.Grip=N("Frame",{
Parent=top,
AnchorPoint=Vector2.new(.5,1),
Position=UDim2.new(.5,0,1,-4),
Size=UDim2.fromOffset(28,3),
BackgroundColor3=Color3.fromRGB(103,105,119),
BackgroundTransparency=.58,
BorderSizePixel=0,
ZIndex=26
})
R(dragHandles.Grip,99)

-- ============================================================
-- MINIMIZED
-- ============================================================

local floatShell=N("Frame",{
Parent=gui,
AnchorPoint=Vector2.new(1,1),
Position=UDim2.new(1,-22,1,-22),
Size=UDim2.fromOffset(60,60),
BackgroundTransparency=1,
BorderSizePixel=0,
Visible=false,
ZIndex=999999
})

local floatScale=N("UIScale",{
Parent=floatShell,
Scale=.84
})

local floatVisual=N("CanvasGroup",{
Parent=floatShell,
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
GroupTransparency=1,
ZIndex=1
})

local floatBg=N("Frame",{
Parent=floatVisual,
Size=UDim2.fromScale(1,1),
BackgroundColor3=Color3.fromRGB(19,19,24),
BorderSizePixel=0,
ZIndex=1
})

R(floatBg,30)

grad(
floatBg,
Color3.fromRGB(37,38,47),
Color3.fromRGB(16,16,20),
45
)

softStroke(
floatBg,
Color3.fromRGB(95,97,112),
.18,
1.35
)

local floatInner=N("Frame",{
Parent=floatVisual,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromScale(.5,.5),
Size=UDim2.fromOffset(49,49),
BackgroundColor3=Color3.fromRGB(13,13,17),
BackgroundTransparency=.10,
BorderSizePixel=0,
ZIndex=2
})

R(floatInner,25)

softStroke(
floatInner,
Color3.fromRGB(255,255,255),
.92,
1
)

-- ANTES ERA 13
-- agora P ficou um pouco mais pro centro
local floatP=N("ImageLabel",{
Parent=floatShell,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromOffset(18,30),
Size=UDim2.fromOffset(28,22),
BackgroundTransparency=1,
ImageTransparency=0,
ScaleType=Enum.ScaleType.Fit,
Rotation=ROT,
ZIndex=21,
Visible=true
})

if PI then
pcall(function()
floatP.ImageContent=Content.fromObject(PI)
end)
end

-- ANTES ERA 43
-- agora + ficou mais perto do P
local floatPlus=N("ImageLabel",{
Parent=floatShell,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromOffset(44,30),
Size=UDim2.fromOffset(22,22),
BackgroundTransparency=1,
ImageTransparency=0,
ScaleType=Enum.ScaleType.Fit,
ZIndex=22,
Visible=true
})

if LI then
pcall(function()
floatPlus.ImageContent=Content.fromObject(LI)
end)
end

local floatHit=N("TextButton",{
Parent=floatShell,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromScale(.5,.5),
-- 6px de margem invisível em cada lado deixa o ícone flutuante muito mais
-- fácil de agarrar sem aumentar o desenho visível.
Size=UDim2.fromOffset(72,72),
BackgroundTransparency=1,
Text="",
AutoButtonColor=false,
Active=true,
ZIndex=100
})

local function makeDrag(handle,target,onMove,onState)
local dragging=false
local startInput,startPos
local activeTouch=nil
local goalPos=nil
local smoothActive=false

local function point2(input)
return Vector2.new(input.Position.X,input.Position.Y)
end

-- Mantém a mesma combinação Scale/Offset que o alvo já usa. Isso evita o
-- "teleporte" de alguns pixels no primeiro movimento causado por converter
-- AbsolutePosition de volta para UDim2.fromOffset().
local function positionWithDelta(base,delta)
return UDim2.new(
base.X.Scale,
base.X.Offset+delta.X,
base.Y.Scale,
base.Y.Offset+delta.Y
)
end

local function clampToViewport(pos)
local cam=workspace.CurrentCamera
local vp=cam and cam.ViewportSize or Vector2.new(1920,1080)
local sz=target.AbsoluteSize
local ap=target.AnchorPoint
local margin=10

-- Como win/floatShell vivem direto no ScreenGui (IgnoreGuiInset=true), o ponto
-- de âncora em pixels pode ser calculado diretamente do UDim2 sem misturar
-- coordenadas de input com AbsolutePosition.
local anchorX=vp.X*pos.X.Scale+pos.X.Offset
local anchorY=vp.Y*pos.Y.Scale+pos.Y.Offset

local minX=margin+sz.X*ap.X
local maxX=vp.X-margin-sz.X*(1-ap.X)
local minY=margin+sz.Y*ap.Y
local maxY=vp.Y-margin-sz.Y*(1-ap.Y)

if maxX<minX then
minX,maxX=vp.X*.5,vp.X*.5
end
if maxY<minY then
minY,maxY=vp.Y*.5,vp.Y*.5
end

local clampedX=math.clamp(anchorX,minX,maxX)
local clampedY=math.clamp(anchorY,minY,maxY)

return UDim2.new(
pos.X.Scale,
pos.X.Offset+(clampedX-anchorX),
pos.Y.Scale,
pos.Y.Offset+(clampedY-anchorY)
)
end

handle.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch then

dragging=true
activeTouch=i.UserInputType==Enum.UserInputType.Touch and i or nil
startInput=point2(i)
startPos=target.Position
goalPos=startPos
smoothActive=true

if onMove then
onMove(false)
end

if onState then
onState(true)
end
end
end)

RC(UI.InputChanged,function(i)
if not dragging then
return
end

local isMouse=i.UserInputType==Enum.UserInputType.MouseMovement
local isTouch=i.UserInputType==Enum.UserInputType.Touch

if not isMouse and not isTouch then
return
end

if activeTouch and isTouch and i~=activeTouch then
return
end

local current=point2(i)
local d=current-startInput

if onMove and d.Magnitude>6 then
onMove(true)
end

goalPos=clampToViewport(positionWithDelta(startPos,d))
smoothActive=true
end)

-- Movimento "macio": em vez de colar a janela 1:1 no mouse em cada evento,
-- aproxima o alvo do ponto desejado a cada frame. O fator exponencial deixa a
-- sensação consistente em 60/120/144 Hz e ainda responde rápido.
RC(game:GetService("RunService").RenderStepped,function(dt)
if not smoothActive or not goalPos then
return
end

local current=target.Position
local alpha=1-math.exp(-18*math.min(dt,.05))
local nextPos=current:Lerp(goalPos,alpha)
target.Position=nextPos

local dx=math.abs(nextPos.X.Offset-goalPos.X.Offset)
local dy=math.abs(nextPos.Y.Offset-goalPos.Y.Offset)
local dsx=math.abs(nextPos.X.Scale-goalPos.X.Scale)
local dsy=math.abs(nextPos.Y.Scale-goalPos.Y.Scale)

if not dragging and dx<.35 and dy<.35 and dsx<.0001 and dsy<.0001 then
target.Position=goalPos
smoothActive=false
end
end)

RC(UI.InputEnded,function(i)
if not dragging then
return
end

local endedMouse=i.UserInputType==Enum.UserInputType.MouseButton1
local endedTouch=i.UserInputType==Enum.UserInputType.Touch
and(activeTouch==nil or i==activeTouch)

if endedMouse or endedTouch then
dragging=false
activeTouch=nil
-- smoothActive fica ligado por alguns frames para terminar o movimento sem
-- aquela parada seca assim que solta o botão.
if onState then
onState(false)
end
end
end)
end

dragHandles.State=function(on)
Q(dragHandles.Grip,D(.10),{
Size=on and UDim2.fromOffset(38,3) or UDim2.fromOffset(28,3),
BackgroundTransparency=on and .16 or .58,
BackgroundColor3=on and ACCENT or Color3.fromRGB(103,105,119)
},Enum.EasingStyle.Quad)
end

makeDrag(dragHandles.Area,win,nil,dragHandles.State)
makeDrag(dragHandles.Strip,win,nil,dragHandles.State)

local floatMoved=false

makeDrag(floatHit,floatShell,function(moved)
floatMoved=moved
end,function(on)
Q(floatScale,D(.09),{Scale=on and 1.035 or 1.07},Enum.EasingStyle.Quad)
Q(floatPlus,D(.11),{Rotation=on and 45 or 90},Enum.EasingStyle.Quint)
if not on then
task.delay(.10,function()
floatMoved=false
end)
end
end)

local function minimize()
brandOpen(false)

Q(win,D(.14),{
GroupTransparency=1
},Enum.EasingStyle.Quad,Enum.EasingDirection.In)

Q(sc,D(.14),{
Scale=.985
},Enum.EasingStyle.Quad,Enum.EasingDirection.In)

task.wait(D(.14))

win.Visible=false
floatShell.Visible=true
floatVisual.GroupTransparency=1
floatScale.Scale=.84
floatP.Visible=true
floatPlus.Visible=true
floatP.ImageTransparency=1
floatPlus.ImageTransparency=1
Q(floatVisual,D(.15),{GroupTransparency=0},Enum.EasingStyle.Quad)
Q(floatP,D(.15),{ImageTransparency=0},Enum.EasingStyle.Quad)
Q(floatPlus,D(.15),{ImageTransparency=0},Enum.EasingStyle.Quad)

Q(floatScale,D(.20),{
Scale=1
},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
end

local function restore()
Q(floatScale,D(.10),{
Scale=.90
},Enum.EasingStyle.Quad,Enum.EasingDirection.In)

Q(floatVisual,D(.10),{GroupTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
Q(floatP,D(.10),{ImageTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
Q(floatPlus,D(.10),{ImageTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
task.wait(D(.10))

floatShell.Visible=false
floatP.ImageTransparency=0
floatPlus.ImageTransparency=0
win.Visible=true
win.GroupTransparency=1
sc.Scale=.985

Q(win,D(.16),{
GroupTransparency=0
},Enum.EasingStyle.Quad)

Q(sc,D(.20),{
Scale=1
},Enum.EasingStyle.Quint)
end

minBtn.MouseButton1Click:Connect(minimize)

floatHit.Activated:Connect(function()
if floatMoved then
floatMoved=false
return
end

restore()
end)

floatHit.MouseEnter:Connect(function()
Q(floatScale,D(.11),{
Scale=1.07
},Enum.EasingStyle.Quad)

Q(floatPlus,D(.18),{
Rotation=90
},Enum.EasingStyle.Quint)

Q(floatP,D(.14),{Rotation=0},Enum.EasingStyle.Quad)
Q(floatInner,D(.14),{BackgroundTransparency=0},Enum.EasingStyle.Quad)
end)

floatHit.MouseLeave:Connect(function()
if floatShell.Visible then

Q(floatScale,D(.11),{
Scale=1
},Enum.EasingStyle.Quad)

Q(floatPlus,D(.18),{
Rotation=0
},Enum.EasingStyle.Quint)

Q(floatP,D(.14),{Rotation=ROT},Enum.EasingStyle.Quad)
Q(floatInner,D(.14),{BackgroundTransparency=.10},Enum.EasingStyle.Quad)

end
end)

-- ============================================================
-- SIDEBAR
-- ============================================================

local side=N("Frame",{
Parent=menu,
Position=UDim2.fromOffset(0,TOPH),
Size=UDim2.new(0,SW,1,-TOPH),
BackgroundColor3=Color3.fromRGB(13,13,16),
BorderSizePixel=0,
ZIndex=30,
ClipsDescendants=false
})

grad(
side,
Color3.fromRGB(17,17,21),
Color3.fromRGB(11,11,14),
90
)

N("Frame",{
Parent=side,
AnchorPoint=Vector2.new(1,0),
Position=UDim2.fromScale(1,0),
Size=UDim2.new(0,1,1,0),
BackgroundColor3=Color3.fromRGB(58,59,69),
BackgroundTransparency=.45,
BorderSizePixel=0,
ZIndex=31
})

N("TextLabel",{
Parent=side,
Position=UDim2.fromOffset(16,15),
Size=UDim2.fromOffset(135,14),
BackgroundTransparency=1,
Text="WORKSPACE",
Font=Enum.Font.GothamBold,
TextSize=8,
TextColor3=Color3.fromRGB(82,84,96),
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=32
})

local sideStatus=N("Frame",{
Parent=side,
AnchorPoint=Vector2.new(.5,1),
Position=UDim2.new(.5,0,1,-14),
Size=UDim2.new(1,-24,0,42),
BackgroundColor3=Color3.fromRGB(18,18,22),
BorderSizePixel=0,
ZIndex=35
})

R(sideStatus,9)

softStroke(
sideStatus,
Color3.fromRGB(54,55,65),
.58,
1
)

local sd=bindAccent(N("Frame",{
Parent=sideStatus,
AnchorPoint=Vector2.new(0,.5),
Position=UDim2.fromOffset(12,21),
Size=UDim2.fromOffset(7,7),
BackgroundColor3=ACCENT,
BorderSizePixel=0,
ZIndex=36
}))

R(sd,99)

N("TextLabel",{
Parent=sideStatus,
Position=UDim2.fromOffset(29,7),
Size=UDim2.new(1,-36,0,14),
BackgroundTransparency=1,
Text="Practice+",
Font=Enum.Font.GothamBold,
TextSize=10,
TextColor3=Color3.fromRGB(203,204,213),
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=36
})

N("TextLabel",{
Parent=sideStatus,
Position=UDim2.fromOffset(29,21),
Size=UDim2.new(1,-36,0,12),
BackgroundTransparency=1,
Text="Local session",
Font=Enum.Font.Gotham,
TextSize=8,
TextColor3=Color3.fromRGB(85,87,99),
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=36
})

do
local sideScale=N("UIScale",{Parent=sideStatus,Scale=1})
sideStatus.MouseEnter:Connect(function()
Q(sideScale,D(.11),{Scale=1.02},Enum.EasingStyle.Quad)
end)
sideStatus.MouseLeave:Connect(function()
Q(sideScale,D(.11),{Scale=1},Enum.EasingStyle.Quad)
end)
end

local contentBG=N("Frame",{
Parent=menu,
Position=UDim2.fromOffset(SW,TOPH),
Size=UDim2.new(1,-SW,1,-TOPH),
BackgroundColor3=Color3.fromRGB(16,16,20),
BorderSizePixel=0,
ZIndex=0
})

grad(
contentBG,
Color3.fromRGB(18,18,22),
Color3.fromRGB(14,14,18),
90
)

local SET={
espEnabled=false,
espTeamColor=true,
espNames=false,
espTracers=false,
espBoxes=false,
espShowSelf=false,
espColor=Color3.fromRGB(235,70,70),
aimbotEnabled=false,
aimFOV=150,
aimSmooth=4,
flyEnabled=false,
flySpeed=50,
noclipEnabled=false,
walkSpeed=16,
jumpPower=50,
noFallDamage=false,
godMode=false,
hitboxExpand=false,
hitboxSize=1.5,
antiAfk=false,
zoomFOV=0,
theme=1
}

local ESP_FOLDERS={
"Zombie",
"Zombies",
"Creeper",
"Enemies",
"Mobs"
}

local ct=N("Frame",{
Parent=menu,
Position=UDim2.fromOffset(SW,TOPH),
Size=UDim2.new(1,-SW,1,-TOPH),
BackgroundTransparency=1,
ZIndex=2
})

local function card(parent,y,h)
local f=N("Frame",{
Parent=parent,
Position=UDim2.fromOffset(18,y),
Size=UDim2.new(1,-36,0,h),
BackgroundColor3=Color3.fromRGB(21,21,26),
BorderSizePixel=0
})

R(f,10)

grad(
f,
Color3.fromRGB(26,26,32),
Color3.fromRGB(19,19,24),
90
)

local st=softStroke(
f,
Color3.fromRGB(58,59,69),
.48,
1
)

-- Movimento curto e sem loop: só responde ao ponteiro para o menu não parecer
-- completamente estático.
f.MouseEnter:Connect(function()
Q(f,D(.11),{
Position=UDim2.fromOffset(20,y),
BackgroundColor3=Color3.fromRGB(24,24,30)
},Enum.EasingStyle.Quad)
Q(st,D(.11),{Transparency=.28},Enum.EasingStyle.Quad)
end)

f.MouseLeave:Connect(function()
Q(f,D(.12),{
Position=UDim2.fromOffset(18,y),
BackgroundColor3=Color3.fromRGB(21,21,26)
},Enum.EasingStyle.Quad)
Q(st,D(.12),{Transparency=.48},Enum.EasingStyle.Quad)
end)

return f
end

local function mkToggle(parent,y,title,sub,onChange,def)
local c=card(parent,y,58)

local titleL=N("TextLabel",{
Parent=c,
Position=UDim2.fromOffset(15,9),
Size=UDim2.new(1,-92,0,19),
BackgroundTransparency=1,
Text=title,
Font=Enum.Font.GothamMedium,
TextSize=13,
TextColor3=Color3.fromRGB(229,229,235),
TextXAlignment=Enum.TextXAlignment.Left
})

N("TextLabel",{
Parent=c,
Position=UDim2.fromOffset(15,30),
Size=UDim2.new(1,-92,0,15),
BackgroundTransparency=1,
Text=sub or"",
Font=Enum.Font.Gotham,
TextSize=10,
TextColor3=Color3.fromRGB(102,104,116),
TextXAlignment=Enum.TextXAlignment.Left
})

local state=def or false

local btn=N("TextButton",{
Parent=c,
AnchorPoint=Vector2.new(1,.5),
Position=UDim2.new(1,-15,.5,0),
Size=UDim2.fromOffset(46,25),
BackgroundColor3=Color3.fromRGB(36,36,43),
BorderSizePixel=0,
Text="",
AutoButtonColor=false
})

R(btn,13)

softStroke(
btn,
Color3.fromRGB(66,67,78),
.54,
1
)

local knob=N("Frame",{
Parent=btn,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromOffset(12.5,12.5),
Size=UDim2.fromOffset(18,18),
BackgroundColor3=Color3.fromRGB(184,185,195),
BorderSizePixel=0
})

R(knob,9)

local function refresh(instant)
local pos=state
and UDim2.fromOffset(33.5,12.5)
or UDim2.fromOffset(12.5,12.5)

local bg=state
and ACCENT
or Color3.fromRGB(36,36,43)

local kc=state
and W
or Color3.fromRGB(184,185,195)

if instant then
btn.BackgroundColor3=bg
knob.Position=pos
knob.BackgroundColor3=kc

else
Q(btn,D(.14),{
BackgroundColor3=bg
},Enum.EasingStyle.Quad)

Q(knob,D(.17),{
Position=pos,
BackgroundColor3=kc
},Enum.EasingStyle.Quint)

end
end

controlRefreshers[#controlRefreshers+1]=function()
refresh(true)
end

refresh(true)

c.MouseEnter:Connect(function()
Q(titleL,D(.10),{
TextColor3=W
},Enum.EasingStyle.Quad)
end)

c.MouseLeave:Connect(function()
Q(titleL,D(.10),{
TextColor3=Color3.fromRGB(229,229,235)
},Enum.EasingStyle.Quad)
end)

btn.MouseButton1Click:Connect(function()
state=not state
refresh(false)

onChange(state)
end)

return {
set=function(v)
state=v
refresh(false)
end,

get=function()
return state
end
}
end

local sliderSetters={}
local function mkSlider(parent,y,title,minV,maxV,decimals,suffix,val,onChange)
local c=card(parent,y,82)

N("TextLabel",{
Parent=c,
Position=UDim2.fromOffset(15,10),
Size=UDim2.new(1,-112,0,18),
BackgroundTransparency=1,
Text=title,
Font=Enum.Font.GothamMedium,
TextSize=13,
TextColor3=Color3.fromRGB(229,229,235),
TextXAlignment=Enum.TextXAlignment.Left
})

local pill=N("Frame",{
Parent=c,
AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-15,0,8),
Size=UDim2.fromOffset(82,23),
BackgroundColor3=Color3.fromRGB(29,29,35),
BorderSizePixel=0
})

R(pill,7)

softStroke(
pill,
Color3.fromRGB(58,59,70),
.56,
1
)

local vl=N("TextLabel",{
Parent=pill,
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
TextColor3=Color3.fromRGB(217,218,226),
Font=Enum.Font.GothamBold,
TextSize=10,
TextXAlignment=Enum.TextXAlignment.Center
})

local rail=N("Frame",{
Parent=c,
Position=UDim2.fromOffset(15,53),
Size=UDim2.new(1,-30,0,5),
BackgroundColor3=Color3.fromRGB(34,34,41),
BorderSizePixel=0
})

R(rail,3)

local fill=bindAccent(N("Frame",{
Parent=rail,
Size=UDim2.new(0,0,1,0),
BackgroundColor3=ACCENT,
BorderSizePixel=0
}))

R(fill,3)

local thumb=N("TextButton",{
Parent=rail,
AnchorPoint=Vector2.new(.5,.5),
Size=UDim2.fromOffset(15,15),
BackgroundColor3=W,
Text="",
BorderSizePixel=0,
AutoButtonColor=false
})

R(thumb,8)

bindAccent(N("UIStroke",{
Parent=thumb,
Color=ACCENT,
Thickness=2,
Transparency=.18
}),"Color")

local dragging=false

local function update(frac,silent)
frac=math.clamp(frac,0,1)

local value=minV+frac*(maxV-minV)

local step=10^decimals
value=math.round(value*step)/step

vl.Text=tostring(value)..(
suffix
and suffix~=""
and" "..suffix
or""
)

fill.Size=UDim2.fromScale(frac,1)
thumb.Position=UDim2.fromScale(frac,.5)

if not silent then
onChange(value)
end
end

local function setByValue(v)
update((v-minV)/(maxV-minV),true)
end

local function dragTo(pos)
update(
(pos.X-rail.AbsolutePosition.X)/
math.max(rail.AbsoluteSize.X,1)
)
end

local function beginDrag(input)
if input.UserInputType==Enum.UserInputType.MouseButton1
or input.UserInputType==Enum.UserInputType.Touch then

dragging=true
dragTo(input.Position)

Q(thumb,D(.08),{
Size=UDim2.fromOffset(18,18)
},Enum.EasingStyle.Quad)

end
end

local function endDrag(input)
if input.UserInputType==Enum.UserInputType.MouseButton1
or input.UserInputType==Enum.UserInputType.Touch then

dragging=false

Q(thumb,D(.10),{
Size=UDim2.fromOffset(15,15)
},Enum.EasingStyle.Quad)

end
end

thumb.InputBegan:Connect(beginDrag)
rail.InputBegan:Connect(beginDrag)
thumb.InputEnded:Connect(endDrag)
rail.InputEnded:Connect(endDrag)

RC(UI.InputChanged,function(input)
if dragging
and(
input.UserInputType==Enum.UserInputType.MouseMovement
or input.UserInputType==Enum.UserInputType.Touch
)then

dragTo(input.Position)
end
end)

RC(UI.InputEnded,function(input)
if dragging then
endDrag(input)
end
end)

update((val-minV)/(maxV-minV))
sliderSetters[title]=setByValue
return {
set=setByValue,

get=function()
return minV+(fill.Size.X.Scale)*(maxV-minV)
end,

frame=c
}
end

-- ============================================================
-- 4) RUNTIME / GAMEPLAY SERVICES
-- Daqui para baixo ficam ESP, tracers, fly, noclip, movimento e aimbot.
-- Alterações temporárias devem ser restauradas no cleanup/reset sempre que possível.
-- ============================================================
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local player=P.LocalPlayer

local espHighlights={}
local espTags={}

local function getTargets()
local ts={}

if SET.espShowSelf
and player.Character
and(player.Character:FindFirstChild("HumanoidRootPart")or player.Character.PrimaryPart)then

ts[#ts+1]=player.Character
end

for _,pl in ipairs(P:GetPlayers())do
if pl~=player
and pl.Character
and(pl.Character:FindFirstChild("HumanoidRootPart")or pl.Character.PrimaryPart)then

ts[#ts+1]=pl.Character
end
end

for _,fn in ipairs(ESP_FOLDERS)do
local f=workspace:FindFirstChild(fn)

if f then
for _,child in ipairs(f:GetChildren())do
if child:IsA("Model")
and(child:FindFirstChild("HumanoidRootPart")or child.PrimaryPart)then

ts[#ts+1]=child
end
end
end
end

return ts
end

local function isEnemy(char)
local pl=P:GetPlayerFromCharacter(char)

if not pl then
return true
end

local myT,plT=player.Team,pl.Team

if myT
and plT
and not player.Neutral
and not pl.Neutral then

return myT~=plT
end

return true
end

local function espColorFor(char,base)
if SET.espTeamColor then
local pl=P:GetPlayerFromCharacter(char)
local tm=pl and pl.Team and pl.Team.TeamColor.Color

if tm then
return tm
end
end

return base
end

local function clearESP()
for char,hl in pairs(espHighlights)do if hl and hl.Parent then hl:Destroy()end espHighlights[char]=nil end
for char,bg in pairs(espTags)do if bg and bg.Parent then bg:Destroy()end espTags[char]=nil end
for _,char in ipairs(getTargets())do
 local hl=char:FindFirstChild("PracticeESP_Highlight")if hl then hl:Destroy()end
 local bg=char:FindFirstChild("PracticeESP_Tag")if bg then bg:Destroy()end
end
end
local function refreshESP()
clearESP()if not SET.espEnabled then return end
for _,char in ipairs(getTargets())do
 if(char==player.Character and SET.espShowSelf)or(char~=player.Character and isEnemy(char))then
  local color=espColorFor(char,SET.espColor)
  local hl=Instance.new("Highlight")hl.Name="PracticeESP_Highlight"hl.FillColor=color hl.OutlineColor=Color3.new(0,0,0)hl.FillTransparency=.4 hl.OutlineTransparency=.3 hl.Parent=char espHighlights[char]=hl
  local head=char:FindFirstChild("Head")or char:FindFirstChild("HumanoidRootPart")or char.PrimaryPart
  if head and(SET.espNames or SET.espBoxes)then
   local bg=Instance.new("BillboardGui")bg.Name="PracticeESP_Tag"bg.AlwaysOnTop=true bg.Adornee=head bg.Size=UDim2.fromScale(3*math.max(head.Size.X,1),8)bg.StudsOffsetWorldSpace=Vector3.new(0,head.Size.Y*1.4,0)bg.ClipsDescendants=false
   if SET.espNames then local nm=Instance.new("TextLabel")local pl=P:GetPlayerFromCharacter(char)nm.Size=UDim2.fromScale(1,.5)nm.BackgroundTransparency=1 nm.Text=pl and pl.Name or "Inimigo"nm.Font=Enum.Font.GothamBold nm.TextSize=14 nm.TextColor3=Color3.new(1,1,1)nm.TextStrokeTransparency=.1 nm.Parent=bg end
   if SET.espBoxes then local bx=Instance.new("Frame")bx.Size=UDim2.new(1,0,2,0)bx.Position=UDim2.new(0,-.5,.5,0)bx.BackgroundTransparency=1 bx.BorderSizePixel=0 bx.Parent=bg N("UIStroke",{Parent=bx,Color=color,Thickness=1.5,Transparency=.2})end
   bg.Parent=char espTags[char]=bg
  end
 end
end
end
local tracerLines={}
local tracerLabels={}

local DrawingOK=pcall(function()
local d=Drawing.new("Line")
d:Destroy()
return true
end)

local DrawingTextOK=pcall(function()
local d=Drawing.new("Text")
d:Destroy()
return true
end)

local function clearTracers()
for _,l in pairs(tracerLines)do
if l then
pcall(function()
l:Destroy()
end)
end
end

tracerLines={}

for _,t in pairs(tracerLabels)do
if t then
pcall(function()
t:Destroy()
end)
end
end

tracerLabels={}
end

RC(RunService.RenderStepped,function()
if DrawingOK
and SET.espEnabled
and SET.espTracers then

local cam=workspace.CurrentCamera

if not cam then
return
end

local cs=cam.CFrame.Position
local rs=cam.ViewportSize
local idx=1

for _,char in ipairs(getTargets())do
if(
char==player.Character
and SET.espShowSelf
)
or(
char~=player.Character
and isEnemy(char)
)then

local pt=char.PrimaryPart
or char:FindFirstChild("Head")
or char:FindFirstChild("HumanoidRootPart")

if pt then
local sp=pt.Position

local col=espColorFor(char,SET.espColor)

local line=tracerLines[idx]

if not line then
line=Drawing.new("Line")
line.Thickness=1.5
line.Transparency=1
line.Color=col

tracerLines[idx]=line
end

line.Color=col
local p2=Vector2.new(rs.X/2,rs.Y)
local screen,vis=cam:WorldToViewportPoint(sp)
line.Visible=vis

line.From=p2
line.To=Vector2.new(screen.X,screen.Y)

local lbl=tracerLabels[idx]

if not lbl
and DrawingTextOK then

local ok,l2=pcall(function()
local d=Drawing.new("Text")

d.Size=14
d.Center=true
d.Outline=true
d.OutlineColor=Color3.new(0,0,0)
d.Color=col

return d
end)

if ok and l2 then
lbl=l2
tracerLabels[idx]=l2
end
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
if l then
l.Visible=false
end
end

for i=idx,#tracerLabels do
local t=tracerLabels[i]
if t then
t.Visible=false
end
end

else

for _,l in pairs(tracerLines)do if l then l.Visible=false end end
for _,t in pairs(tracerLabels)do if t then t.Visible=false end end
end
end)

local HST=Enum.HumanoidStateType

local function hstSafe(name)
local ok,v=pcall(function()
return HST[name]
end)

return ok and v or nil
end

local S_FALL=hstSafe("Freefall")
local S_JUMP=hstSafe("Jumping")

local function setState(h,s,en)
if not h or not s then
return
end

pcall(function()
h:SetStateEnabled(s,en)
end)
end

local flyBody=nil

local function ensureFlyBody(root)
if flyBody and flyBody.Parent==root then
return
end

if flyBody then
flyBody:Destroy()
end

flyBody=Instance.new("BodyVelocity")
flyBody.MaxForce=Vector3.new(9e9,9e9,9e9)
flyBody.Velocity=Vector3.zero
flyBody.Parent=root
end

local function toggleFly(on)
if not on then
if flyBody then
pcall(function()
flyBody:Destroy()
end)

flyBody=nil
end

local pl=player
local char=pl and pl.Character
local h=char and char:FindFirstChildOfClass("Humanoid")

if h then
setState(h,S_FALL,true)
setState(h,S_JUMP,true)
end
end
end

local noclipOriginal=setmetatable({},{__mode="k"})
local function noclipping(char)
char=char or player.Character if not char then return end
for _,prt in ipairs(char:GetDescendants())do if prt:IsA("BasePart")then if noclipOriginal[prt]==nil then noclipOriginal[prt]=prt.CanCollide end prt.CanCollide=false end end
end
local function restoreNoclip()for prt,v in pairs(noclipOriginal)do if prt and prt.Parent then pcall(function()prt.CanCollide=v end)end noclipOriginal[prt]=nil end end

RC(RunService.Heartbeat,function()
local char=player.Character
local humanoid=char and char:FindFirstChildOfClass("Humanoid")
local root=char and char:FindFirstChild("HumanoidRootPart")

if SET.flyEnabled
and root
and humanoid then

ensureFlyBody(root)

setState(humanoid,S_FALL,false)
setState(humanoid,S_JUMP,false)

local up=0

if UserInputService:IsKeyDown(Enum.KeyCode.Space)then
up=1
end

if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)then
up=-1
end

local cam=workspace.CurrentCamera

local camDir=cam
and cam.CFrame:VectorToWorldSpace(Vector3.new(0,0,-1))
or root.CFrame.LookVector

local flat=Vector3.new(camDir.X,0,camDir.Z)

local f2d=flat.Magnitude>.001
and flat.Unit
or Vector3.zero

local mv=Vector3.zero

if UserInputService:IsKeyDown(Enum.KeyCode.W)then
mv=mv+f2d
end

if UserInputService:IsKeyDown(Enum.KeyCode.S)then
mv=mv-f2d
end

local hz=root.CFrame.RightVector
local hzFlat=Vector3.new(hz.X,0,hz.Z)

hz=hzFlat.Magnitude>.001
and hzFlat.Unit
or Vector3.zero

if UserInputService:IsKeyDown(Enum.KeyCode.A)then
mv=mv-hz
end

if UserInputService:IsKeyDown(Enum.KeyCode.D)then
mv=mv+hz
end

flyBody.Velocity=
(mv*SET.flySpeed)
+
Vector3.new(0,up*SET.flySpeed,0)

elseif flyBody
and flyBody.Parent
and flyBody.Parent.Parent==char then

flyBody:Destroy()
flyBody=nil

if humanoid then
setState(humanoid,S_FALL,true)
setState(humanoid,S_JUMP,true)
end
end

if SET.noclipEnabled
and char
and humanoid then

noclipping(char)
end
end)

RC(RunService.Heartbeat,function()
local char=player.Character
local humanoid=char and char:FindFirstChildOfClass("Humanoid")

if not humanoid then
return
end

pcall(function()
humanoid.WalkSpeed=SET.walkSpeed
end)

pcall(function()
humanoid.JumpPower=SET.jumpPower
end)

if SET.noFallDamage then
pcall(function()
if S_FALL then
humanoid:SetStateEnabled(S_FALL,true)
end
end)
end

if SET.godMode then
pcall(function()
local max=humanoid.MaxHealth

if humanoid.Health<max then
humanoid.Health=max
end
end)
end
end)

local hitboxOriginal=setmetatable({},{__mode="k"})
local function restoreHitboxes()for prt,sz in pairs(hitboxOriginal)do if prt and prt.Parent then pcall(function()prt.Size=sz end)end hitboxOriginal[prt]=nil end end
RC(RunService.Heartbeat,function()
if not SET.hitboxExpand then
return
end

local char=player.Character

if not char then
return
end

local selfRoot=char:FindFirstChild("HumanoidRootPart")

if not selfRoot then
return
end

for _,t in ipairs(getTargets())do
local isSelf=(t==char)

if SET.espShowSelf or not isSelf then
local hd=t:FindFirstChild("HumanoidRootPart")

if hd then
if not hitboxOriginal[hd]then hitboxOriginal[hd]=hd.Size end
pcall(function()hd.Size=hitboxOriginal[hd]*SET.hitboxSize end)
end
end
end
end)

local VU=game:GetService("VirtualUser")
task.spawn(function()while gui.Parent do task.wait(45)if SET.antiAfk and gui.Parent then pcall(function()local cam=workspace.CurrentCamera VU:CaptureController()VU:Button2Down(Vector2.zero,cam and cam.CFrame or CFrame.new())task.wait(.1)VU:Button2Up(Vector2.zero,cam and cam.CFrame or CFrame.new())end)end end end)
local baseFOV=workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70
RC(RunService.RenderStepped,function()
if SET.zoomFOV~=0
and SET.zoomFOV~=math.huge then

local cam=workspace.CurrentCamera

if cam then
local targetFOV=math.clamp(
baseFOV-SET.zoomFOV,
40,
70
)

pcall(function()
cam.FieldOfView=
cam.FieldOfView+
(targetFOV-cam.FieldOfView)*.2
end)
end
end
end)

RC(RunService.RenderStepped,function()
if not SET.aimbotEnabled then
return
end

local cam=workspace.CurrentCamera
local char=player.Character
local root=char and char:FindFirstChild("HumanoidRootPart")

if not(cam and root)then
return
end

local camPos=cam.CFrame.Position
local camLook=cam.CFrame.LookVector

local best=nil
local bestAng=SET.aimFOV

for _,t in ipairs(getTargets())do
if t==char then
continue
end

if not isEnemy(t)then
continue
end

local hd=t:FindFirstChild("Head")or t.PrimaryPart

if hd then
local delta=hd.Position-camPos

if delta.Magnitude>.001 then
local dir=delta.Unit

local ang=math.deg(
math.acos(
math.clamp(
camLook:Dot(dir),
-1,
1
)
)
)

if ang<=bestAng then
best=hd.Position
bestAng=ang
end
end
end
end

if best then
local alpha=
1/
(
math.max(
SET.aimSmooth,
1
)+
1
)

cam.CFrame=
cam.CFrame:Lerp(
CFrame.lookAt(
camPos,
best
),
alpha
)
end
end)

RC(player.CharacterAdded,function()
if SET.noclipEnabled then
noclipping()
end

if SET.espEnabled then
refreshESP()
end
end)

RC(P.PlayerAdded,function(pl)
RC(pl.CharacterAdded,function()
if SET.espEnabled then
refreshESP()
end
end)
end)

-- UI polish: drag ampliado, hitboxes ajustadas e microinterações sem animação em loop.

-- ============================================================
-- HOME
-- ============================================================

local function setupPages()
local home=N("Frame",{
Parent=ct,
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
ZIndex=3
})

local route=GAME_ROUTER.Route
local routeMode=route.matched and "Game-specific" or "Universal"
local routeScript=route.script_name or "Practice.lua"

N("TextLabel",{
Parent=home,
Position=UDim2.fromOffset(22,16),
Size=UDim2.new(1,-44,0,28),
BackgroundTransparency=1,
Text="Practice+",
Font=FONT,
TextSize=22,
TextColor3=W,
TextXAlignment=Enum.TextXAlignment.Left
})

N("TextLabel",{
Parent=home,
Position=UDim2.fromOffset(22,45),
Size=UDim2.new(1,-44,0,18),
BackgroundTransparency=1,
Text="Roblox  •  "..routeMode.."  •  PlaceId "..tostring(game.PlaceId),
Font=Enum.Font.Gotham,
TextSize=10,
TextColor3=Color3.fromRGB(104,106,118),
TextXAlignment=Enum.TextXAlignment.Left
})

local cardHome=card(home,76,188)

local homeLogo=N("Frame",{
Parent=cardHome,
Position=UDim2.fromOffset(16,16),
Size=UDim2.fromOffset(88,34),
BackgroundTransparency=1
})

local hp=N("ImageLabel",{
Parent=homeLogo,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromOffset(16,17),
Size=UDim2.fromOffset(29,22),
BackgroundTransparency=1,
ScaleType=Enum.ScaleType.Fit,
Rotation=ROT
})

if PI then
pcall(function()
hp.ImageContent=Content.fromObject(PI)
end)
end

local hpl=N("ImageLabel",{
Parent=homeLogo,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromOffset(46,17),
Size=UDim2.fromOffset(22,22),
BackgroundTransparency=1,
ScaleType=Enum.ScaleType.Fit
})

if LI then
pcall(function()
hpl.ImageContent=Content.fromObject(LI)
end)
end

local who=
AUTH.LIC.discord_name~=""
and AUTH.LIC.discord_name
or(
AUTH.LIC.username~=""
and AUTH.LIC.username
or P.LocalPlayer.Name
)

N("TextLabel",{
Parent=cardHome,
Position=UDim2.fromOffset(100,13),
Size=UDim2.new(1,-116,0,21),
BackgroundTransparency=1,
Text="Autenticado",
Font=Enum.Font.GothamBold,
TextSize=14,
TextColor3=Color3.fromRGB(232,232,238),
TextXAlignment=Enum.TextXAlignment.Left
})

N("TextLabel",{
Parent=cardHome,
Position=UDim2.fromOffset(100,34),
Size=UDim2.new(1,-116,0,16),
BackgroundTransparency=1,
Text=who,
Font=Enum.Font.Gotham,
TextSize=10,
TextColor3=Color3.fromRGB(104,106,118),
TextXAlignment=Enum.TextXAlignment.Left
})

N("Frame",{
Parent=cardHome,
Position=UDim2.fromOffset(16,63),
Size=UDim2.new(1,-32,0,1),
BackgroundColor3=Color3.fromRGB(57,58,69),
BackgroundTransparency=.48,
BorderSizePixel=0
})

local function formatExpiration(iso)
iso=tostring(iso or ""):gsub("^%s+",""):gsub("%s+$","")

if iso=="" then
return "Sem expiração","Licença permanente"
end

local year,month,day=iso:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)")
local dateText=
(day and month and year)
and(day.."/"..month.."/"..year)
or iso:sub(1,10)

local ok,expiresAt=pcall(function()
return DateTime.fromIsoDate(iso)
end)

if not ok or not expiresAt then
return "Expiração definida","Expira em "..dateText
end

local seconds=expiresAt.UnixTimestamp-DateTime.now().UnixTimestamp

if seconds<=0 then
return "Expirada","Data: "..dateText
end

local days=math.max(1,math.ceil(seconds/86400))

if days==1 then
return "1 dia faltando pra expirar","Expira em "..dateText
end

return tostring(days).." dias faltando pra expirar","Expira em "..dateText
end

local expirationMain,expirationSub=formatExpiration(AUTH.LIC.expires)

local function chip(x,w,title,main,sub)
local f=N("Frame",{
Parent=cardHome,
Position=UDim2.new(x,16,0,80),
Size=UDim2.new(w,-22,0,84),
BackgroundColor3=Color3.fromRGB(17,17,21),
BackgroundTransparency=.05,
BorderSizePixel=0
})

R(f,8)

local chipStroke=softStroke(
f,
Color3.fromRGB(51,52,62),
.62,
1
)

local chipScale=N("UIScale",{Parent=f,Scale=1})

f.MouseEnter:Connect(function()
Q(chipScale,D(.11),{Scale=1.018},Enum.EasingStyle.Quad)
Q(chipStroke,D(.11),{Transparency=.38},Enum.EasingStyle.Quad)
end)

f.MouseLeave:Connect(function()
Q(chipScale,D(.11),{Scale=1},Enum.EasingStyle.Quad)
Q(chipStroke,D(.11),{Transparency=.62},Enum.EasingStyle.Quad)
end)

N("TextLabel",{
Parent=f,
Position=UDim2.fromOffset(11,9),
Size=UDim2.new(1,-22,0,13),
BackgroundTransparency=1,
Text=title,
Font=Enum.Font.GothamBold,
TextSize=8,
TextColor3=Color3.fromRGB(87,89,102),
TextXAlignment=Enum.TextXAlignment.Left
})

N("TextLabel",{
Parent=f,
Position=UDim2.fromOffset(11,28),
Size=UDim2.new(1,-22,0,20),
BackgroundTransparency=1,
Text=main,
TextTruncate=Enum.TextTruncate.AtEnd,
Font=Enum.Font.GothamBold,
TextSize=11,
TextColor3=Color3.fromRGB(213,214,223),
TextXAlignment=Enum.TextXAlignment.Left
})

N("TextLabel",{
Parent=f,
Position=UDim2.fromOffset(11,53),
Size=UDim2.new(1,-22,0,18),
BackgroundTransparency=1,
Text=sub,
TextWrapped=true,
Font=Enum.Font.Gotham,
TextSize=8,
TextColor3=Color3.fromRGB(92,94,107),
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Top
})
end

chip(
0,
.34,
"LICENSE",
AUTH.LIC.plan~=""and AUTH.LIC.plan or"custom",
AUTH.LIC.tier~=""and AUTH.LIC.tier or"authorized"
)

chip(
.34,
.33,
"EXPIRAÇÃO",
expirationMain,
expirationSub
)

chip(
.67,
.33,
"MÓDULO",
routeMode,
routeScript
)

local detail=card(home,278,76)

local function maskKey(k)
k=tostring(k or ""):gsub("^%s+",""):gsub("%s+$","")

if #k<16 then
return k
end

return k:sub(1,10).."••••"..k:sub(-5)
end

N("TextLabel",{
Parent=detail,
Position=UDim2.fromOffset(15,9),
Size=UDim2.new(1,-30,0,18),
BackgroundTransparency=1,
Text="Key  "..maskKey(AUTH.LIC.key),
Font=Enum.Font.Code,
TextSize=9,
TextColor3=Color3.fromRGB(151,153,166),
TextXAlignment=Enum.TextXAlignment.Left
})

N("TextLabel",{
Parent=detail,
Position=UDim2.fromOffset(15,31),
Size=UDim2.new(1,-30,0,16),
BackgroundTransparency=1,
Text="Roblox "..AUTH.ROBLOX_USER_ID.."  •  Device "..AUTH.DEVICE_UUID:sub(1,8).."  •  HW "..AUTH.HARDWARE_HASH:sub(1,10),
Font=Enum.Font.Code,
TextSize=8,
TextColor3=Color3.fromRGB(86,88,101),
TextXAlignment=Enum.TextXAlignment.Left
})

N("TextLabel",{
Parent=detail,
Position=UDim2.fromOffset(15,52),
Size=UDim2.new(1,-30,0,14),
BackgroundTransparency=1,
Text="Revalidação: 60 min  •  "..routeScript,
Font=Enum.Font.Gotham,
TextSize=8,
TextColor3=Color3.fromRGB(81,83,96),
TextXAlignment=Enum.TextXAlignment.Left
})

local function mkScrollFrame()
local sf=N("ScrollingFrame",{
Parent=ct,
Position=UDim2.fromOffset(0,0),
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
BorderSizePixel=0,
ScrollBarThickness=3,
ScrollBarImageColor3=Color3.fromRGB(76,77,88),
ScrollBarImageTransparency=.26,
ScrollingDirection=Enum.ScrollingDirection.Y,
ZIndex=3
})

local fr=N("Frame",{
Parent=sf,
Size=UDim2.new(1,0,0,0),
BackgroundTransparency=1,
AutomaticSize=Enum.AutomaticSize.Y,
ZIndex=3
})

fr:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
sf.CanvasSize=UDim2.fromOffset(0,fr.AbsoluteSize.Y+12)
end)

return sf,fr
end

local scroll,pframe=mkScrollFrame()

N("TextLabel",{
Parent=pframe,
Position=UDim2.fromOffset(14,12),
Size=UDim2.fromOffset(200,24),
BackgroundTransparency=1,
Text="Player",
Font=FONT,
TextSize=22,
TextColor3=W,
TextXAlignment=Enum.TextXAlignment.Left
})

N("TextLabel",{
Parent=pframe,
Position=UDim2.fromOffset(14,42),
Size=UDim2.new(1,-28,0,18),
BackgroundTransparency=1,
Text="Combat & movement controls",
Font=Enum.Font.Gotham,
TextSize=11,
TextColor3=Color3.fromRGB(115,115,125),
TextXAlignment=Enum.TextXAlignment.Left
})

local y=72

local aimTog=mkToggle(
pframe,
y,
"Aimbot",
"Aponta a cam para o inimigo mais proximo",
function(on)
SET.aimbotEnabled=on
end
)

y=y+58

mkSlider(
pframe,
y,
"FOV do Aimbot",
30,
360,
0,
"graus",
SET.aimFOV,
function(v)
SET.aimFOV=v
end
)

y=y+84

mkSlider(
pframe,
y,
"Suavidade do Aimbot",
1,
30,
0,
"",
SET.aimSmooth,
function(v)
SET.aimSmooth=math.round(v)
end
)

y=y+84

mkSlider(
pframe,
y,
"Velocidade",
8,
100,
0,
"",
SET.walkSpeed,
function(v)
SET.walkSpeed=v
end
)

y=y+84

mkSlider(
pframe,
y,
"Forca do pulo",
20,
200,
0,
"",
SET.jumpPower,
function(v)
SET.jumpPower=v
end
)

y=y+84

local noFallTog=mkToggle(
pframe,
y,
"Sem dano de queda",
"Nao toma dano ao cair",
function(on)
SET.noFallDamage=on
end
)

y=y+58

local godTog=mkToggle(
pframe,
y,
"God Mode",
"Imortal: nao toma dano nem morre",
function(on)
SET.godMode=on
end
)

y=y+58

local hitboxTog=mkToggle(
pframe,
y,
"Hitbox expandido",
"Inimigos com partes maiores",
function(on)
SET.hitboxExpand=on if not on then restoreHitboxes()end
end
)

y=y+58

mkSlider(
pframe,
y,
"Tamanho do Hitbox",
1.2,
3,
1,
"x",
SET.hitboxSize,
function(v)
SET.hitboxSize=v
end
)

y=y+84

local flyTog=mkToggle(
pframe,
y,
"Fly",
"Voe segurando Espaco (sobe) / Shift (desce)",
function(on)
pcall(function()
SET.flyEnabled=on
toggleFly(on)
end)
end
)

y=y+58

mkSlider(
pframe,
y,
"Velocidade do Fly",
10,
200,
0,
"studs/s",
SET.flySpeed,
function(v)
SET.flySpeed=v
end
)

y=y+84

local noclipTog=mkToggle(
pframe,
y,
"Noclip",
"Atravessa paredes",
function(on)
SET.noclipEnabled=on if not on then restoreNoclip()end
end
)

y=y+58

pframe:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
scroll.CanvasSize=UDim2.fromOffset(0,pframe.AbsoluteSize.Y+12)
end)

scroll.CanvasSize=UDim2.fromOffset(0,y+12)

local vscroll,vframe=mkScrollFrame()

N("TextLabel",{
Parent=vframe,
Position=UDim2.fromOffset(14,12),
Size=UDim2.fromOffset(200,24),
BackgroundTransparency=1,
Text="Visuals",
Font=FONT,
TextSize=22,
TextColor3=W,
TextXAlignment=Enum.TextXAlignment.Left
})

N("TextLabel",{
Parent=vframe,
Position=UDim2.fromOffset(14,42),
Size=UDim2.new(1,-28,0,18),
BackgroundTransparency=1,
Text="ESP & rendering controls",
Font=Enum.Font.Gotham,
TextSize=11,
TextColor3=Color3.fromRGB(104,106,118),
TextXAlignment=Enum.TextXAlignment.Left
})

local vy=72

local espTog=mkToggle(
vframe,
vy,
"ESP",
"Destaca outros jogadores no mapa",
function(on)
SET.espEnabled=on
refreshESP()
end
)

vy=vy+58

local espColTog=mkToggle(
vframe,
vy,
"ESP cor da equipe",
"Usa a cor da equipe do alvo",
function(on)
SET.espTeamColor=on
refreshESP()
end,
true
)

vy=vy+58

local espNamesTog=mkToggle(
vframe,
vy,
"Nomes acima da cabeca",
"Mostra o nome dos alvos",
function(on)
SET.espNames=on
refreshESP()
end
)

vy=vy+58

local espTracersTog=mkToggle(
vframe,
vy,
"Tracers",
"Linhas da tela ate os alvos",
function(on)
SET.espTracers=on
end
)

vy=vy+58

local espBoxesTog=mkToggle(
vframe,
vy,
"Caixas (Boxes)",
"Caixa ao redor dos alvos",
function(on)
SET.espBoxes=on
refreshESP()
end
)

vy=vy+58

local espSelfTog=mkToggle(
vframe,
vy,
"Mostrar voce no ESP",
"Marca o proprio personagem tambem",
function(on)
SET.espShowSelf=on
refreshESP()
end
)

vy=vy+58

N("TextLabel",{
Parent=vframe,
Position=UDim2.fromOffset(14,vy),
Size=UDim2.new(1,-28,0,18),
BackgroundTransparency=1,
Text="Cor do ESP (RGB)",
Font=Enum.Font.GothamMedium,
TextSize=13,
TextColor3=Color3.fromRGB(220,220,225),
TextXAlignment=Enum.TextXAlignment.Left
})

vy=vy+24

mkSlider(
vframe,
vy,
"Vermelho",
0,
255,
0,
"",
SET.espColor.R*255,
function(v)
SET.espColor=Color3.fromRGB(
math.round(v),
math.round(SET.espColor.G*255),
math.round(SET.espColor.B*255)
)

refreshESP()
end
)

vy=vy+84

mkSlider(
vframe,
vy,
"Verde",
0,
255,
0,
"",
SET.espColor.G*255,
function(v)
SET.espColor=Color3.fromRGB(
math.round(SET.espColor.R*255),
math.round(v),
math.round(SET.espColor.B*255)
)

refreshESP()
end
)

vy=vy+84

mkSlider(
vframe,
vy,
"Azul",
0,
255,
0,
"",
SET.espColor.B*255,
function(v)
SET.espColor=Color3.fromRGB(
math.round(SET.espColor.R*255),
math.round(SET.espColor.G*255),
math.round(v)
)

refreshESP()
end
)

vy=vy+84

vframe:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
vscroll.CanvasSize=UDim2.fromOffset(0,vframe.AbsoluteSize.Y+12)
end)

vscroll.CanvasSize=UDim2.fromOffset(0,vy+12)

local sscroll,sframe=mkScrollFrame()

N("TextLabel",{
Parent=sframe,
Position=UDim2.fromOffset(14,12),
Size=UDim2.fromOffset(200,24),
BackgroundTransparency=1,
Text="Settings",
Font=FONT,
TextSize=22,
TextColor3=W,
TextXAlignment=Enum.TextXAlignment.Left
})

N("TextLabel",{
Parent=sframe,
Position=UDim2.fromOffset(14,42),
Size=UDim2.new(1,-28,0,18),
BackgroundTransparency=1,
Text="Interface & session preferences",
Font=Enum.Font.Gotham,
TextSize=11,
TextColor3=Color3.fromRGB(104,106,118),
TextXAlignment=Enum.TextXAlignment.Left
})

local sy=72

local antiAfkTog=mkToggle(
sframe,
sy,
"Anti-afk",
"Impede o kick por inatividade",
function(on)
SET.antiAfk=on
end
)

sy=sy+58

mkSlider(
sframe,
sy,
"Zoom da camera (FOV)",
0,
30,
0,
"",
SET.zoomFOV,
function(v)
SET.zoomFOV=math.round(v)local cam=workspace.CurrentCamera if SET.zoomFOV==0 and cam then cam.FieldOfView=baseFOV end
end
)

sy=sy+84

local themeBtn=N("TextButton",{
Parent=sframe,
Position=UDim2.fromOffset(14,sy),
Size=UDim2.new(1,-28,0,52),
BackgroundColor3=Color3.fromRGB(23,23,28),
BorderSizePixel=0,
Text="Tema: Padrao (clique p/ trocar)",
Font=Enum.Font.GothamMedium,
TextSize=13,
TextColor3=W
})

R(themeBtn,8)

N("UIStroke",{
Parent=themeBtn,
Color=BD,
Transparency=.45
})

local themes={
{"Padrao",Color3.fromRGB(99,130,246)},
{"Verde",Color3.fromRGB(60,179,113)},
{"Laranja",Color3.fromRGB(255,140,0)},
{"Rosa",Color3.fromRGB(255,105,180)}
}

local function applyTheme(idx)
local c=themes[idx]

SET.theme=idx
ACCENT=c[2]

themeBtn.Text=
"Tema: "..
c[1]..
" (clique p/ trocar)"

for _,r in ipairs(accentObjects)do
local ob,prop=r[1],r[2]

if ob and ob.Parent then
pcall(function()
Q(ob,D(.12),{
[prop]=ACCENT
},Enum.EasingStyle.Quad)
end)
end
end

for _,rf in ipairs(controlRefreshers)do
pcall(rf)
end

Q(win,D(.1),{
BackgroundColor3=
SET.theme~=1
and Color3.fromRGB(20,20,24)
or Color3.fromRGB(17,17,20)
},Enum.EasingStyle.Quad)
end

themeBtn.MouseButton1Click:Connect(function()
applyTheme((SET.theme%#themes)+1)
end)

applyTheme(SET.theme)

sy=sy+58

local resetBtn=N("TextButton",{
Parent=sframe,
Position=UDim2.fromOffset(14,sy),
Size=UDim2.new(1,-28,0,46),
BackgroundColor3=Color3.fromRGB(120,45,45),
BorderSizePixel=0,
Text="Resetar todas as configs",
Font=Enum.Font.GothamBold,
TextSize=13,
TextColor3=W
})

R(resetBtn,8)

resetBtn.MouseButton1Click:Connect(function()
for _,t in ipairs({
espTog,
aimTog,
noFallTog,
godTog,
hitboxTog,
flyTog,
noclipTog,
espColTog,
espNamesTog,
espTracersTog,
espBoxesTog,
espSelfTog,
antiAfkTog
})do

t.set(false)
end

SET.aimFOV=150
SET.aimSmooth=4
SET.flySpeed=50
SET.walkSpeed=16
SET.jumpPower=50
SET.hitboxSize=1.5
SET.zoomFOV=0
SET.godMode=false

SET.espColor=Color3.fromRGB(235,70,70)
SET.espEnabled=false
local defaults={['FOV do Aimbot']=150,['Suavidade do Aimbot']=4,['Velocidade']=16,['Forca do pulo']=50,['Tamanho do Hitbox']=1.5,['Velocidade do Fly']=50,['Vermelho']=235,['Verde']=70,['Azul']=70,['Zoom da camera (FOV)']=0}
for title,v in pairs(defaults)do if sliderSetters[title]then sliderSetters[title](v)end end
applyTheme(1)
local resetCam=workspace.CurrentCamera if resetCam then resetCam.FieldOfView=baseFOV end
restoreNoclip()restoreHitboxes()

setState(
player.Character
and player.Character:FindFirstChildOfClass("Humanoid"),
S_FALL,
true
)

setState(
player.Character
and player.Character:FindFirstChildOfClass("Humanoid"),
S_JUMP,
true
)

refreshESP()
end)

sy=sy+58

sframe:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
sscroll.CanvasSize=UDim2.fromOffset(
0,
sframe.AbsoluteSize.Y+12
)
end)

sscroll.CanvasSize=UDim2.fromOffset(0,sy+12)

-- ============================================================
-- 5) SIDEBAR / TABS
-- Cada botão guarda referências para seus elementos visuais. switchTab() só
-- alterna Visible e anima a página selecionada; ZIndex alto evita abas invisíveis.
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

if not target then
return
end

for pageName,page in pairs(pages)do
if page then
page.Visible=(pageName==name)
end
end

if activePage~=name then
target.Position=UDim2.fromOffset(12,0)

local motionScale=target:FindFirstChild("PracticePageMotionScale")
if not motionScale then
motionScale=N("UIScale",{
Name="PracticePageMotionScale",
Parent=target,
Scale=1
})
end
motionScale.Scale=.986

Q(target,D(.20),{
Position=UDim2.fromOffset(0,0)
},Enum.EasingStyle.Quint)

Q(motionScale,D(.22),{
Scale=1
},Enum.EasingStyle.Quint)
end

activePage=name

for _,t in ipairs(allBtns)do
local on=(t==tab)

t.Button:SetAttribute("Active",on)

Q(t.Scale,D(.13),{Scale=on and 1.01 or 1},Enum.EasingStyle.Quad)

Q(t.Button,D(.13),{
BackgroundTransparency=on and .08 or 1,
BackgroundColor3=
on
and Color3.fromRGB(29,29,36)
or Color3.fromRGB(25,25,31)
},Enum.EasingStyle.Quad)

Q(t.Bar,D(.16),{
BackgroundTransparency=on and 0 or 1,
Size=
on
and UDim2.fromOffset(3,30)
or UDim2.fromOffset(3,10)
},Enum.EasingStyle.Quint)

Q(t.Dot,D(.13),{
BackgroundColor3=
on
and ACCENT
or Color3.fromRGB(72,74,87),

Size=
on
and UDim2.fromOffset(7,7)
or UDim2.fromOffset(5,5),
Position=on and UDim2.fromOffset(20,28) or UDim2.fromOffset(18,28)
},Enum.EasingStyle.Quad)

Q(t.Label,D(.13),{
Position=on and UDim2.fromOffset(35,8) or UDim2.fromOffset(32,8),
TextColor3=
on
and W
or Color3.fromRGB(148,150,163)
},Enum.EasingStyle.Quad)

Q(t.Sub,D(.13),{
Position=on and UDim2.fromOffset(35,29) or UDim2.fromOffset(32,29),
TextColor3=
on
and Color3.fromRGB(112,114,128)
or Color3.fromRGB(76,78,91)
},Enum.EasingStyle.Quad)
end
end

local function mkTab(name,sub,y,on)
local b=N("TextButton",{
Parent=side,
Position=UDim2.fromOffset(12,y),
Size=UDim2.new(1,-24,0,56),
BackgroundColor3=Color3.fromRGB(29,29,36),
BackgroundTransparency=on and .08 or 1,
BorderSizePixel=0,
Text="",
AutoButtonColor=false,
Active=true,
Visible=true,
ZIndex=50
})

R(b,10)

local bar=bindAccent(N("Frame",{
Name="Accent",
Parent=b,
AnchorPoint=Vector2.new(0,.5),
Position=UDim2.fromOffset(0,28),
Size=
on
and UDim2.fromOffset(3,30)
or UDim2.fromOffset(3,10),
BackgroundColor3=ACCENT,
BackgroundTransparency=on and 0 or 1,
BorderSizePixel=0,
Visible=true,
ZIndex=53
}))

R(bar,2)

local dot=N("Frame",{
Name="Dot",
Parent=b,
AnchorPoint=Vector2.new(.5,.5),
Position=UDim2.fromOffset(18,28),
Size=
on
and UDim2.fromOffset(7,7)
or UDim2.fromOffset(5,5),
BackgroundColor3=
on
and ACCENT
or Color3.fromRGB(72,74,87),
BorderSizePixel=0,
Visible=true,
ZIndex=54
})

R(dot,99)

local lbl=N("TextLabel",{
Name="Label",
Parent=b,
Position=UDim2.fromOffset(32,8),
Size=UDim2.new(1,-42,0,20),
BackgroundTransparency=1,
Text=name,
Font=Enum.Font.GothamMedium,
TextSize=13,
TextColor3=
on
and W
or Color3.fromRGB(148,150,163),
TextTransparency=0,
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
Visible=true,
ZIndex=55
})

local sl=N("TextLabel",{
Name="Sub",
Parent=b,
Position=UDim2.fromOffset(32,29),
Size=UDim2.new(1,-42,0,15),
BackgroundTransparency=1,
Text=sub,
Font=Enum.Font.Gotham,
TextSize=9,
TextColor3=
on
and Color3.fromRGB(112,114,128)
or Color3.fromRGB(76,78,91),
TextTransparency=0,
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
Visible=true,
ZIndex=55
})

local tabScale=N("UIScale",{Parent=b,Scale=1})

b:SetAttribute("Active",on)

local tab={
Button=b,
Bar=bar,
Dot=dot,
Label=lbl,
Sub=sl,
Scale=tabScale,
Name=name
}

allBtns[#allBtns+1]=tab

b.MouseEnter:Connect(function()
if b:GetAttribute("Active")then
return
end

Q(b,D(.10),{
BackgroundTransparency=.48,
BackgroundColor3=Color3.fromRGB(27,27,34)
},Enum.EasingStyle.Quad)

Q(tabScale,D(.10),{Scale=1.015},Enum.EasingStyle.Quad)

Q(lbl,D(.10),{
Position=UDim2.fromOffset(35,8),
TextColor3=Color3.fromRGB(220,221,229)
},Enum.EasingStyle.Quad)

Q(sl,D(.10),{
Position=UDim2.fromOffset(35,29)
},Enum.EasingStyle.Quad)

Q(dot,D(.10),{
Position=UDim2.fromOffset(20,28),
Size=UDim2.fromOffset(7,7)
},Enum.EasingStyle.Quad)
end)

b.MouseLeave:Connect(function()
if b:GetAttribute("Active")then
return
end

Q(b,D(.10),{
BackgroundTransparency=1
},Enum.EasingStyle.Quad)

Q(tabScale,D(.10),{Scale=1},Enum.EasingStyle.Quad)

Q(lbl,D(.10),{
Position=UDim2.fromOffset(32,8),
TextColor3=Color3.fromRGB(148,150,163)
},Enum.EasingStyle.Quad)

Q(sl,D(.10),{
Position=UDim2.fromOffset(32,29)
},Enum.EasingStyle.Quad)

Q(dot,D(.10),{
Position=UDim2.fromOffset(18,28),
Size=UDim2.fromOffset(5,5)
},Enum.EasingStyle.Quad)
end)

b.MouseButton1Down:Connect(function()
Q(tabScale,D(.06),{Scale=.975},Enum.EasingStyle.Quad)
end)

b.MouseButton1Up:Connect(function()
Q(tabScale,D(.09),{Scale=1.015},Enum.EasingStyle.Back)
end)

b.MouseButton1Click:Connect(function()
switchTab(name,tab)
end)

return tab
end

local homeTab=mkTab("Home","Overview",39,true)
mkTab("Player","Combat & movement",103,false)
mkTab("Visuals","ESP & rendering",167,false)
mkTab("Settings","Interface & session",231,false)
switchTab("Home",homeTab)

-- API mínima entregue aos módulos específicos futuros.
-- bladeball.lua, por exemplo, pode retornar uma função(api,route) e usar:
--   api.Pages, api.CreateTab, api.SwitchTab, api.Content, api.Sidebar,
--   api.New, api.Card e api.Settings.
return {
    Pages=pages,
    CreateTab=mkTab,
    SwitchTab=switchTab,
    Content=ct,
    Sidebar=side,
    New=N,
    Card=card,
    Settings=SET,
    Accent=function()return ACCENT end,
    Window=win,
    Gui=gui
}
end

local PAGE_API=setupPages()

-- Se o Worker entregou um módulo específico para este PlaceId, executa o source
-- recebido da API. O client não sabe nem precisa saber a URL do GitHub.
task.spawn(function()
    local ok,err=GAME_ROUTER.LoadMatchedScript(PAGE_API)
    if not ok and err~="universal" and err~="not_configured" then
        warn("[Practice+] game router: "..tostring(err))
    end
end)

gui.Destroying:Connect(function()
SET.flyEnabled=false SET.noclipEnabled=false SET.hitboxExpand=false SET.espEnabled=false SET.espTracers=false
if flyBody then pcall(function()flyBody:Destroy()end)flyBody=nil end
restoreNoclip()restoreHitboxes()clearESP()clearTracers()
local cam=workspace.CurrentCamera if cam then pcall(function()cam.FieldOfView=baseFOV end)end
for _,c in ipairs(runtimeConnections)do pcall(function()c:Disconnect()end)end table.clear(runtimeConnections)
end)

-- ============================================================
-- 7) INTRO / TRANSIÇÃO PARA O MENU
-- Esta animação foi mantida separada das features para facilitar manutenção.
-- ============================================================

Q(win,D(.15),{
GroupTransparency=0
},Enum.EasingStyle.Quad)

Q(sc,D(.2),{
Scale=1
})

task.wait(D(.04))

Q(p,D(.15),{
ImageTransparency=0
},Enum.EasingStyle.Quad)

Q(plus,D(.15),{
ImageTransparency=0
},Enum.EasingStyle.Quad)

task.wait(D(.18))

local F=G(OPEN)
local DL=F*TDELAY
local TD=F-DL

Q(p,F,{
Position=UDim2.fromOffset(
PX,
CY+PYO
),
Rotation=0
})

Q(ph,F,{
Position=UDim2.fromOffset(
LX,
CY+LYO
)
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)

Q(plus,F,{
Rotation=360
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)

task.delay(DL,function()
Q(rev,TD,{
Size=UDim2.fromOffset(TW+6,80)
},Enum.EasingStyle.Quart)

Q(wipe,TD*.78,{
Position=UDim2.fromOffset(
TX-WIPE-5,
CY
),
Size=UDim2.fromOffset(0,88)
},Enum.EasingStyle.Quart)

for _,c in ipairs(corners)do
Q(c[1],TD*.5,{
Size=c[3],
BackgroundTransparency=.04
},Enum.EasingStyle.Quart)
end

shine.Position=UDim2.fromOffset(-60,CY)
shine.BackgroundTransparency=1

Q(shine,TD*.12,{
BackgroundTransparency=SHA
},Enum.EasingStyle.Quad)

Q(shine,TD*.6,{
Position=UDim2.fromOffset(
HW+60,
CY
),
BackgroundTransparency=1
},Enum.EasingStyle.Linear)
end)

task.wait(F)

wipe.Visible=false

task.wait(D(HOLD))

local RF=F
local LEAD=RF*.07

wipe.Visible=true
wipe.Position=UDim2.fromOffset(TX-10,CY)
wipe.Size=UDim2.fromOffset(0,88)

for _,c in ipairs(corners)do
Q(c[1],RF*.28,{
Size=c[2],
BackgroundTransparency=1
},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
end

Q(wipe,RF*.78,{
Size=UDim2.fromOffset(
TW+WIPE+20,
88
)
},Enum.EasingStyle.Quart,Enum.EasingDirection.InOut)

task.wait(LEAD)

local MOVE=RF-LEAD

Q(p,MOVE,{
Position=IP,
Rotation=ROT
},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)

Q(ph,MOVE,{
Position=IL
},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)

Q(plus,MOVE,{
Rotation=0
},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)

task.wait(MOVE)

rev.Size=UDim2.fromOffset(0,80)
wipe.Visible=false

plus.Rotation=0

Q(plus,D(LOAD),{
Rotation=360*TURNS
},Enum.EasingStyle.Linear)

task.wait(D(LOAD)+.3)

plus.Rotation=0

task.spawn(function()
Q(logo,D(.14),{
GroupTransparency=1
},Enum.EasingStyle.Quad,Enum.EasingDirection.In)

Q(sc,D(.12),{
Scale=.98
},Enum.EasingStyle.Quad)

Q(win,D(.38),{
Size=UDim2.fromOffset(MW,MH)
},Enum.EasingStyle.Quint)

task.wait(D(.38)+.2)

logo.Visible=false

for _,c in ipairs(corners)do
c[1].Visible=false
end

menu.Visible=true

Q(sc,D(.22),{
Scale=1
})

Q(menu,D(.28),{
GroupTransparency=0
},Enum.EasingStyle.Quad)
end)