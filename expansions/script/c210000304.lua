-- 심해의 적 - 레비아탄 (오션 테일 카드가 아님)
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 c:SetUniqueOnField(1,1,id)
 for _,code in ipairs({EFFECT_CANNOT_BE_FUSION_MATERIAL,EFFECT_CANNOT_BE_SYNCHRO_MATERIAL,
  EFFECT_CANNOT_BE_XYZ_MATERIAL,EFFECT_CANNOT_BE_LINK_MATERIAL,
  EFFECT_CANNOT_BE_RITUAL_MATERIAL}) do
  if code then
   local e=Effect.CreateEffect(c);e:SetType(EFFECT_TYPE_SINGLE)
   e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE);e:SetCode(code);e:SetValue(1);c:RegisterEffect(e)
  end
 end
 local et=Effect.CreateEffect(c);et:SetType(EFFECT_TYPE_SINGLE);et:SetCode(EFFECT_UNRELEASABLE_SUM);et:SetValue(1);c:RegisterEffect(et)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,0))
 e2:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetRange(LOCATION_HAND)
 e2:SetCountLimit(1,{id,2})
 e2:SetCost(s.dcost)
 e2:SetTarget(s.stg)
 e2:SetOperation(s.sop)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,1))
 e3:SetType(EFFECT_TYPE_FIELD)
 e3:SetCode(EFFECT_ACTIVATE_COST)
 e3:SetRange(LOCATION_MZONE)
 e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
 e3:SetTargetRange(1,0)
 e3:SetCost(s.acost)
 e3:SetOperation(s.aop)
 c:RegisterEffect(e3)
 local e4=Effect.CreateEffect(c)
 e4:SetDescription(aux.Stringid(id,2))
 e4:SetCategory(CATEGORY_DRAW|CATEGORY_HANDES|CATEGORY_DAMAGE)
 e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
 e4:SetCode(EVENT_LEAVE_FIELD)
 e4:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CANNOT_NEGATE)
 e4:SetCountLimit(1,{id,4})
 e4:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
 e4:SetOperation(s.leaveop)
 c:RegisterEffect(e4)
end
function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():IsDiscardable() end
 Duel.SendtoGrave(e:GetHandler(),REASON_COST|REASON_DISCARD)
end
function s.stf(c) return ot.archetype(c) and c:IsAbleToHand() end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.stf,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sop(e,tp) ot.search(tp,s.stf) end
function s.acost(e,te,tp) return tp==e:GetHandlerPlayer() and te:GetHandler()~=e:GetHandler() end
function s.aop(e,tp,eg,ep,ev,re,r,rp)
 if Duel.CheckLPCost(tp,500) then Duel.PayLPCost(tp,500) end
end
function s.leaveop(e,tp)
 local c=e:GetHandler();local owner=c:GetOwner();local previous=c:GetPreviousControler()
 if not Duel.IsPlayerCanDraw(owner,4) then return end
 Duel.Draw(owner,4,REASON_EFFECT)
 if Duel.GetFieldGroupCount(owner,LOCATION_HAND,0)>=2 then
  Duel.DiscardHand(owner,nil,2,2,REASON_EFFECT|REASON_DISCARD)
 end
 Duel.Damage(previous,Duel.GetFieldGroupCount(owner,LOCATION_HAND,0)*500,REASON_EFFECT)
end
