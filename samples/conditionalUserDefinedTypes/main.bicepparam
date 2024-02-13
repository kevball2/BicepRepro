using './main.bicep'

param freeOptions = {
  freeValue1: 'someValue'
  freeValue2: 14
  freeValue3: 'anotherfreevalue'
  tier: 'free'
}

param paidOptions = {
  freeValues: {
    freeValue1: 'someValue'
    freeValue2: 14
    freeValue3: 'anotherfreevalue'
    tier: 'free'
  }
  paidValue1: 'paid1'
  paidValue2: 25
  paidValue3: 'paid3'
  tier: 'paid'
}

param freeOptions2 = {
  freeValue1: 'someValue'
  freeValue2: 14
  freeValue3: 'anotherfreevalue'
  tier: 'free'
}

param paidOptions2 = {
  freeValue1: 'someValue'
  freeValue2: 14
  freeValue3: 'anotherfreevalue'
  paidValue1: 'paid1'
  paidValue2: 25
  paidValue3: 'paid3'
  tier: 'paid'
}
