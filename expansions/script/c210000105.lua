-- Deathfire Volt V2: 210000105
local s,id=GetID()
local SET,COUNTER=0x1df0,0x1099
function s.initial_effect(c)
 Synchro.AddProcedure(c,nil,1,1,s.nontuner,1,1)
 c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
 e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetProperty(EFFECT_FLAG_DELAY)
 e1:SetCountLimit(1,id)
 e1:SetCondition(s.syncon)
 e1:SetTarget(s.destg)
 e1:SetOperation(s.desop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_DESTROY)
 e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
 e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
 e2:SetCode(EVENT_DAMAGE)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCondition(s.dmcon)
 e2:SetTarget(s.dmtg)
 e2:SetOperation(s.dmop)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetType(EFFECT_TYPE_SINGLE)
 e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
 e3:SetRange(LOCATION_MZONE)
 e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
 e3:SetCondition(s.indcon)
 e3:SetValue(s.indval)
 c:RegisterEffect(e3)
end
s.listed_series={SET}
s.mentioned_counter={[COUNTER]=true}
function s.nontuner(c,sc,sumtype,tp)
 return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(SET) and not c:IsType(TYPE_TUNER)
end
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
 return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
 local c=e:GetHandler()
 if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
 local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
 Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
 local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
 local ct=Duel.Destroy(g,REASON_EFFECT)
 if ct>0 then
  Duel.Damage(1-tp,ct*300,REASON_EFFECT)
  if c:IsFaceup() and c:IsRelateToEffect(e) then
   local e1=Effect.CreateEffect(c)
   e1:SetType(EFFECT_TYPE_SINGLE)
   e1:SetCode(EFFECT_UPDATE_ATTACK)
   e1:SetValue(ct*200)
   e1:SetReset(RESET_EVENT+RESETS_STANDARD)
   c:RegisterEffect(e1)
  end
 end
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
 return ep==1-tp and (r&REASON_BATTLE)==0
end
function s.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
 local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
 if #g==0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
 local tc=g:Select(tp,1,1,nil):GetFirst()
 if tc then Duel.Destroy(tc,REASON_EFFECT) end
end
function s.indcon(e)
 return Duel.IsExistingMatchingCard(s.ctfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.ctfilter(c) return c:GetCounter(COUNTER)>0 end
function s.indval(e,re,rp) return rp~=e:GetHandlerPlayer() end
