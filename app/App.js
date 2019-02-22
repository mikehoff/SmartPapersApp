import React from 'react'
import {
  AragonApp,
  Button,
  Text,

  observe
} from '@aragon/ui'
import Aragon, { providers } from '@aragon/client'
import styled from 'styled-components'

const AppContainer = styled(AragonApp)`
  display: flex;
  align-items: center;
  justify-content: center;
`

export default class App extends React.Component {
  render () {
    return (
      <AppContainer>
        <div>
          <h1>Smart Papers Aragon App</h1>
	  <h2>Debug:</h2>
          <ObservedCount observable={this.props.observable} />
        
	  <Button onClick={() => this.props.app.newPaper("test")}>Create Paper</Button>
	  <p></p> 
	   <Button onClick={() => this.props.app.decrementCitations(1)}>Decrement Citations</Button>
          <Button onClick={() => this.props.app.incrementCitations(1)}>Increment Citations</Button>
        </div>
      </AppContainer>
    )
  }
}

const ObservedCount = observe(
  (state$) => state$,
  { count: 0 }
)(
  ({ count }) => <Text.Block style={{ textAlign: 'center' }} size='xxlarge'>{count}</Text.Block>
)
