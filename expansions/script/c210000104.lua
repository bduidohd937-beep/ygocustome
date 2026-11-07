-- Deathfire Volt V2: 210000104
local s,id=GetID()
local COUNTER=0x1099
function s.initial_effect(c)
 Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
 c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_DAMAGE)
 e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetProperty(EFFECT_FLAG_DELAY)
 e1:SetCountLimit(1,id)
 e1:SetCondition(s.dmcon)
 e1:SetTarget(s.dmtg)
 e1:SetOperation(s.dmop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_DISABLE)
 e2:SetType(EFFECT_TYPE_QUICK_O)
 e2:SetCode(EVENT_FREE_CHAIN)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,id+1000)
 e2:SetCost(s.cost)
 e2:SetTarget(s.distg)
 e2:SetOperation(s.disop)
 c:RegisterEffect(e2)
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
 return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.amount(tp)
 return (Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)+Duel.GetFieldGroupCount(tp,0,LOCATION_HAND))*300
end
function s.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return s.amount(tp)>0 end
 Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,s.amount(tp))
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
 local damage=s.amount(tp)
 if damage>0 then Duel.Damage(1-tp,damage,REASON_EFFECT) end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,COUNTER,2,REASON_COST) end
 Duel.RemoveCounter(tp,1,0,COUNTER,2,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
 local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
 for tc in aux.Next(g) do
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_DISABLE)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  tc:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EFFECT_DISABLE_EFFECT)
  tc:RegisterEffect(e2)
  local e3=e1:Clone()
  e3:SetCode(EFFECT_SET_ATTACK_FINAL)
  e3:SetValue(0)
  tc:RegisterEffect(e3)
 end
end
