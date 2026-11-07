-- 오션 테일 - 거센 파도
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_ATKCHANGE)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetCountLimit(1,id)
 e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e1:SetTarget(s.tg)
 e1:SetOperation(s.op)
 c:RegisterEffect(e1)
end
s.listed_series={ot.SET}
function s.f(c) return ot.monster(c) and c:IsFaceup() end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.f(chkc) end
 if chk==0 then return Duel.IsExistingTarget(s.f,tp,LOCATION_MZONE,0,1,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
 local g=Duel.SelectTarget(tp,s.f,tp,LOCATION_MZONE,0,1,1,nil)
 Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,1000)
end
function s.op(e,tp)
 local tc=Duel.GetFirstTarget()
 if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
 local e1=Effect.CreateEffect(e:GetHandler())
 e1:SetType(EFFECT_TYPE_SINGLE);e1:SetCode(EFFECT_UPDATE_ATTACK);e1:SetValue(1000)
 e1:SetReset(RESETS_STANDARD_PHASE_END);tc:RegisterEffect(e1)
 local e2=e1:Clone();e2:SetCode(EFFECT_IMMUNE_EFFECT);e2:SetValue(ot.immune);tc:RegisterEffect(e2)
end
