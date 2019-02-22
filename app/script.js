import '@babel/polyfill'

import Aragon from '@aragon/client'

const app = new Aragon()

const initialState = {
  count: 0
}
app.store(async (state, event) => {
  if (state === null) state = initialState
  console.log(event)
  console.log(event.event)
  switch (event.event) {
    case 'IncrementCitations':
      return { count: await getValue() }
    case 'DecrementCitations':
      return { count: await getValue() }
    case 'CreatePaper':
      return { count: await getValue() }
    default:
      return state
  }
})

function getValue() {
  // Get current value from the contract by calling the public getter
  return new Promise(resolve => {
    app
      .call('value')
      .first()
      .map(value => parseInt(value, 10))
      .subscribe(resolve)
  })
}
