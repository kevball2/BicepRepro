type freeType = {
  tier: 'free'
  freeValue1: string
  freeValue2: int
  freeValue3: string
}

type paidType = {
  tier: 'paid'
  freeValues: freeType
  paidValue1: string
  paidValue2: int
  paidValue3: string
}

@discriminator('tier')
type optionType = freeType | paidType

param freeOptions optionType

param paidOptions optionType

output outFreeOptions object = freeOptions
output outPaidOptions object = paidOptions


type freeType2 = {
  tier: 'free'
  freeValue1: string
  freeValue2: int
  freeValue3: string
}

type paidType2 = {
  tier: 'paid'
  freeValue1: string
  freeValue2: int
  freeValue3: string
  paidValue1: string
  paidValue2: int
  paidValue3: string
}

@discriminator('tier')
type optionType2 = freeType2 | paidType2

param freeOptions2 optionType2

param paidOptions2 optionType2

output outFreeOptions2 object = freeOptions2
output outPaidOptions2 object = paidOptions2
