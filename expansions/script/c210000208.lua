-- Isobar Xyz: 210000208
Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 Xyz.AddProcedure(c,s.matfilter,4,2)
 c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e1:SetProperty(EFFECT_FLAG_DELAY)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetCountLimit(1,id)
 e1:SetCondition(s.wxcon)
 e1:SetTarget(s.wxtg)
 e1:SetOperation(s.wxop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_DISABLE)
 e2:SetType(EFFECT_TYPE_QUICK_O)
 e2:SetCode(EVENT_CHAINING)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,id+1000)
 e2:SetCondition(s.discon)
 e2:SetCost(s.discost)
 e2:SetTarget(s.distg)
 e2:SetOperation(s.disop)
 c:RegisterEffect(e2)
end
s.listed_series={ISOBAR.SET}
function s.matfilter(c) return c:IsRace(RACE_MACHINE) end
function s.wxcon(e,tp,eg,ep,ev,re,r,rp)
 return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and ISOBAR.Field(tp)~=nil
end
function s.wxtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return ISOBAR.State(tp)~=ISOBAR.RAIN end
end
function s.wxop(e,tp,eg,ep,ev,re,r,rp) ISOBAR.Change(tp,ISOBAR.RAIN,e) end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
 return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and ISOBAR.Is(tp,ISOBAR.RAIN) and Duel.IsChainNegatable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
 e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return true end
 Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
 Duel.NegateEffect(ev)
end
