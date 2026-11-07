Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e=Effect.CreateEffect(c)
 e:SetType(EFFECT_TYPE_ACTIVATE)
 e:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
 e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
 e:SetTarget(s.tg)
 e:SetOperation(s.op)
 c:RegisterEffect(e)
end
s.listed_series={ISOBAR.SET}
function s.f(c)
 return ISOBAR.Monster(c) and c:IsAbleToHand()
end
function s.g(c)
 return c:IsSetCard(ISOBAR.SET) and c:IsAbleToGrave()
end
function s.r(c,e,tp)
 return ISOBAR.Monster(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then
  return Duel.IsExistingMatchingCard(s.f,tp,LOCATION_DECK,0,1,nil)
 end
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
 local g=Duel.SelectMatchingCard(tp,s.f,tp,LOCATION_DECK,0,1,1,nil)
 if #g==0 then return end
 Duel.SendtoHand(g,nil,REASON_EFFECT)
 Duel.ConfirmCards(1-tp,g)
 if not Duel.IsExistingMatchingCard(s.g,tp,LOCATION_HAND,0,1,nil) then return end
 if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
 local sg=Duel.SelectMatchingCard(tp,s.g,tp,LOCATION_HAND,0,1,1,nil)
 if #sg==0 or Duel.SendtoGrave(sg,REASON_EFFECT)==0 then return end
 if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
 local rg=Duel.SelectMatchingCard(tp,s.r,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
 if #rg==0 then return end
 if Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
 local tc=rg:GetFirst()
 local d=Effect.CreateEffect(e:GetHandler())
 d:SetType(EFFECT_TYPE_SINGLE)
 d:SetCode(EFFECT_DISABLE)
 d:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
 tc:RegisterEffect(d)
 local d2=d:Clone()
 d2:SetCode(EFFECT_DISABLE_EFFECT)
 tc:RegisterEffect(d2)
 local d3=d:Clone()
 d3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
 d3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
 d3:SetReset(RESET_EVENT+RESETS_REDIRECT)
 d3:SetValue(LOCATION_REMOVED)
 tc:RegisterEffect(d3,true)
end
