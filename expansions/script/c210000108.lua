-- Deathfire Volt V2: 210000108
local s,id=GetID()
local SET,COUNTER=0x1df0,0x1099
local CHARGE=210000107
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetCategory(CATEGORY_LEAVE_GRAVE)
 e1:SetOperation(s.activate)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
 e2:SetCode(EVENT_DAMAGE)
 e2:SetRange(LOCATION_FZONE)
 e2:SetCondition(s.ctcon)
 e2:SetOperation(s.ctop)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,2))
 e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
 e3:SetCode(EFFECT_DESTROY_REPLACE)
 e3:SetRange(LOCATION_FZONE)
 e3:SetCountLimit(1,id)
 e3:SetTarget(s.reptg)
 e3:SetValue(s.repval)
 e3:SetOperation(s.repop)
 c:RegisterEffect(e3)
end
s.listed_names={CHARGE}
s.listed_series={SET}
s.mentioned_counter={[COUNTER]=true}
function s.chfilter(c)
 return c:IsCode(CHARGE) and c:IsType(TYPE_CONTINUOUS) and c:IsSpell()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
 if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
 local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_DECK,0,nil)
 if #g==0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
 local tc=g:Select(tp,1,1,nil):GetFirst()
 if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
function s.synfilter(c)
 return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(SET)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
 return ep==1-tp and (r&REASON_EFFECT)~=0 and
  Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_MZONE,0,1,nil) and
  Duel.IsExistingMatchingCard(s.chfilter,tp,LOCATION_SZONE,0,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
 local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_SZONE,0,nil)
 local tc=g:GetFirst()
 if tc and tc:IsFaceup() then tc:AddCounter(COUNTER,1) end
end
function s.repfilter(c,tp)
 return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_THUNDER) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and Duel.IsCanRemoveCounter(tp,1,0,COUNTER,3,REASON_EFFECT) end
 if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return false end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
 local g=eg:Filter(s.repfilter,nil,tp)
 local sg=g:Select(tp,1,1,nil)
 e:SetLabelObject(sg:GetFirst())
 return true
end
function s.repval(e,c)
 return c==e:GetLabelObject()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
 Duel.RemoveCounter(tp,1,0,COUNTER,3,REASON_EFFECT)
end
