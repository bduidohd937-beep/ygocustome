-- Isobar Spell/Trap: 210000210
Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetOperation(s.activate)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,3))
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetRange(LOCATION_FZONE)
 e2:SetCountLimit(1,id)
 e2:SetTarget(s.wxtg)
 e2:SetOperation(s.wxop)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetType(EFFECT_TYPE_FIELD)
 e3:SetCode(EFFECT_UPDATE_ATTACK)
 e3:SetRange(LOCATION_FZONE)
 e3:SetTargetRange(LOCATION_MZONE,0)
 e3:SetCondition(s.suncon)
 e3:SetTarget(s.monfilter)
 e3:SetValue(300)
 c:RegisterEffect(e3)
 local e4=e3:Clone()
 e4:SetCode(EFFECT_UPDATE_ATTACK)
 e4:SetTargetRange(0,LOCATION_MZONE)
 e4:SetCondition(s.raincon)
 e4:SetTarget(aux.TRUE)
 e4:SetValue(-300)
 c:RegisterEffect(e4)
 local e5=Effect.CreateEffect(c)
 e5:SetType(EFFECT_TYPE_FIELD)
 e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
 e5:SetCode(EFFECT_CANNOT_ACTIVATE)
 e5:SetRange(LOCATION_FZONE)
 e5:SetTargetRange(0,1)
 e5:SetCondition(s.stormcon)
 e5:SetValue(s.block)
 c:RegisterEffect(e5)
end
s.listed_series={ISOBAR.SET}
function s.activate(e,tp,eg,ep,ev,re,r,rp)
 ISOBAR.Change(tp,ISOBAR.SUN,e)
end
function s.wxtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return ISOBAR.State(tp)>0 end
end
function s.wxop(e,tp,eg,ep,ev,re,r,rp)
 local current=ISOBAR.State(tp)
 if current>0 then ISOBAR.Change(tp,ISOBAR.Choose(tp,current),e) end
end
function s.suncon(e) return ISOBAR.Is(e:GetHandlerPlayer(),ISOBAR.SUN) end
function s.raincon(e) return ISOBAR.Is(e:GetHandlerPlayer(),ISOBAR.RAIN) end
function s.stormcon(e) return ISOBAR.Is(e:GetHandlerPlayer(),ISOBAR.STORM) end
function s.monfilter(e,c) return c:IsSetCard(ISOBAR.SET) end
function s.block(e,re,tp)
 if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) or Duel.GetCurrentPhase()~=PHASE_DAMAGE then return false end
 local a=Duel.GetAttacker()
 local d=Duel.GetAttackTarget()
 local owner=e:GetHandlerPlayer()
 return (a and a:IsControler(owner) and a:IsSetCard(ISOBAR.SET) and d~=nil)
     or (d and d:IsControler(owner) and d:IsSetCard(ISOBAR.SET))
end
