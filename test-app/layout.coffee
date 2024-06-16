import { Component, Widget, Text } from "rayous";

export default class extends Component
  build: (props) ->
    new Widget children: [
      new Text 'hello'
      props.page
    ]