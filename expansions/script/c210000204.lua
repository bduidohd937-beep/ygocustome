-- Isobar: 210000204
Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_TOGRAVE)
 e1:SetType(EFFECT_TYPE_IGNITION)
 e1:SetRange(LOCATION_MZONE)
 e1:SetCountLimit(1,id)
 e1:SetTarget(s.tgtg)
 e1:SetOperation(s.tgop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_RECOVER)
 e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e2:SetProperty(EFFECT_FLAG_DELAY)
 e2:SetCode(EVENT_TO_GRAVE)
 e2:SetCountLimit(1,id+1000)
 e2:SetCondition(s.reccon)
 e2:SetTarget(s.rectg)
 e2:SetOperation(s.recop)
 c:RegisterEffect(e2)
end
s.listed_series={ISOBAR.SET}
function s.other(c,sc) return c~=sc and c:IsFaceup() and ISOBAR.Monster(c) end
function s.tgfilter(c) return ISOBAR.Monster(c) and c:IsAbleToGrave() end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return ISOBAR.Is(tp,ISOBAR.SUN) and Duel.IsExistingMatchingCard(s.other,tp,LOCATION_MZONE,0,1,e:GetHandler(),e:GetHandler()) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
 local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
 if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
 return e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return true end
 Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp) Duel.Recover(tp,500,REASON_EFFECT) end
