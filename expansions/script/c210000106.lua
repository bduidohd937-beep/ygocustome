-- Deathfire Volt V2: 210000106
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY+CATEGORY_RECOVER)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
 e1:SetTarget(s.target)
 e1:SetOperation(s.operation)
 c:RegisterEffect(e1)
end
function s.filter(c)
 return c:IsFaceup() and c:IsAttackAbove(1) and c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
 if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
 Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local tc=Duel.GetFirstTarget()
 if not tc or not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
 local dmg=math.floor(math.max(0,tc:GetAttack())/2)
 local dealt=0
 if dmg>0 then dealt=Duel.Damage(1-tp,dmg,REASON_EFFECT) end
 Duel.BreakEffect()
 if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
 if dealt>0 then Duel.Recover(tp,dealt,REASON_EFFECT) end
end
