-- 오션 테일 - 고래 벨루
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetType(EFFECT_TYPE_IGNITION)
 e1:SetRange(LOCATION_HAND)
 e1:SetCountLimit(1,{id,1})
 e1:SetCondition(s.spcon)
 e1:SetTarget(s.sptg)
 e1:SetOperation(s.spop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_TOHAND)
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,{id,2})
 e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e2:SetTarget(s.saltg)
 e2:SetOperation(s.salop)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,2))
 e3:SetCategory(CATEGORY_TOHAND)
 e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
 e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
 e3:SetCode(EVENT_RELEASE)
 e3:SetCountLimit(1,{id,3})
 e3:SetCondition(function(e) return e:GetHandler():IsReason(REASON_RITUAL) end)
 e3:SetTarget(s.ritg)
 e3:SetOperation(s.riop)
 c:RegisterEffect(e3)
end
s.listed_series={ot.SET}
function s.spcon(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,ot.MARINA),tp,LOCATION_MZONE,0,1,nil) end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp)
 local c=e:GetHandler()
 if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
function s.salf(c) return ot.spell(c) and c:IsAbleToHand() end
function s.saltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.salf(chkc) end
 if chk==0 then return Duel.IsExistingTarget(s.salf,tp,LOCATION_GRAVE,0,1,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
 local g=Duel.SelectTarget(tp,s.salf,tp,LOCATION_GRAVE,0,1,1,nil)
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.salop(e,tp)
 local tc=Duel.GetFirstTarget()
 if tc and tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT);Duel.ConfirmCards(1-tp,tc) end
end
function s.rif(c) return ot.archetype(c) and c:IsAbleToHand() end
function s.ritg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rif(chkc) end
 if chk==0 then return Duel.IsExistingTarget(s.rif,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
 local g=Duel.SelectTarget(tp,s.rif,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.riop(e,tp) s.salop(e,tp) end
