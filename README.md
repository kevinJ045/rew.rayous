# Rew X Rayous
This library adds a fetch/router that adds a [Rayous](https://github.com/kevinj045/guilib) router to render coffee files ready to render with rayous components.

```coffee
import { Component, Widget, Text } from "rayous";

export default class extends Component
  build: (props) ->
    new Widget children: [
      new Text 'Hello, Rew + Rayous!'
    ]
```