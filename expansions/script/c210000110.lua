-- Deathfire Volt V2: 210000110
local s,id=GetID()
local COUNTER=0x1099
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
 e1:SetCondition(s.condition)
 e1:SetTarget(s.target)
 e1:SetOperation(s.operation)
 c:RegisterEffect(e1)
end
s.mentioned_counter={[COUNTER]=true}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
 return Duel.GetCounter(tp,1,0,COUNTER)>=3
end
function s.filter(c)
 return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
 if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
 Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
 Duel.SetChainLimit(aux.FALSE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local tc=Duel.GetFirstTarget()
 if not tc or not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
 local atk=math.max(0,tc:GetAttack())
 local e1=Effect.CreateEffect(e:GetHandler())
 e1:SetType(EFFECT_TYPE_SINGLE)
 e1:SetCode(EFFECT_DISABLE)
 e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
 tc:RegisterEffect(e1)
 local e2=e1:Clone()
 e2:SetCode(EFFECT_DISABLE_EFFECT)
 tc:RegisterEffect(e2)
 if atk>0 then Duel.Damage(1-tp,atk,REASON_EFFECT) end
end
