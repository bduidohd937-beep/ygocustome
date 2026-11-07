-- Deathfire Volt V2: 210000109
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DRAW)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
 e1:SetCondition(s.condition)
 e1:SetTarget(s.target)
 e1:SetOperation(s.operation)
 c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
 return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
 Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*300)
 Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
 if ct>0 then Duel.Damage(1-tp,ct*300,REASON_EFFECT) end
 Duel.BreakEffect()
 if Duel.IsPlayerCanDraw(tp,1) then Duel.Draw(tp,1,REASON_EFFECT) end
end
