-- Pure normalization of the four calibration markers exported with every FBX.
local F={}
local function add(a,b)return {a[1]+b[1],a[2]+b[2],a[3]+b[3]}end
local function sub(a,b)return {a[1]-b[1],a[2]-b[2],a[3]-b[3]}end
local function dot(a,b)return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]end
local function cross(a,b)return {a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}end
function F.finite(v)return type(v)=='number' and v==v and math.abs(v)<1e8 end
local function vector(a)assert(type(a)=='table' and #a==3,'Vetor de importação inválido');for _,v in a do assert(F.finite(v),'Coordenada não finita')end;return a end
function F.basis(points)
 for _,name in {'O','X','Y','Z'}do vector(points[name])end
 local basis={Origin=points.O,Axes={},Scale=0};local lengths={}
 for i,name in {'X','Y','Z'}do
  local v=sub(points[name],points.O);local length=math.sqrt(dot(v,v));assert(length>.0001,'Marcadores coincidentes')
  lengths[i]=length;basis.Axes[i]={v[1]/length,v[2]/length,v[3]/length};basis.Scale+=length/3
 end
 for _,v in lengths do assert(math.abs(v/basis.Scale-1)<.01,'Escala não uniforme no FBX')end
 for i=1,3 do for j=i+1,3 do assert(math.abs(dot(basis.Axes[i],basis.Axes[j]))<.01,'Eixos da importação não são ortogonais')end end
 assert(dot(cross(basis.Axes[1],basis.Axes[2]),basis.Axes[3])>.99,'Importação espelhada; confira os eixos do FBX')
 return basis
end
function F.point(basis,position)
 local delta=sub(vector(position),basis.Origin);local p={}
 for i=1,3 do p[i]=dot(delta,basis.Axes[i])/basis.Scale end
 return add(p,{0,.5,0})
end
function F.direction(basis,direction)local out={};for i=1,3 do out[i]=dot(vector(direction),basis.Axes[i])end;return out end
function F.asset(id)
 if type(id)~='string' then return false end
 return id:match('^rbxassetid://[1-9]%d*$')~=nil or id:match('^https?://www%.roblox%.com/asset/%?id=[1-9]%d*$')~=nil
end
return F
